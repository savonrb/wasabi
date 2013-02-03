module Wasabi

  # = Wasabi::Definition
  #
  # Purpose:
  #   Interprets the parser's WSDL definition.
  class Definition

    def initialize(definition)
      @definition = definition
    end

    def target_namespace
      @definition[:target_namespace]
    end

    def namespaces
      @definition[:namespaces]
    end

    def endpoints
      @endpoints ||= endpoints!
    end

    def operations
      @operations ||= operations!
    end

    def input_for(operation_name)
      message_for(operation_name, "input")
    end

    def output_for(operation_name)
      message_for(operation_name, "output")
    end

    def soap_action_for(operation_name)
      binding_operation = operations[operation_name][:binding_operation]
      binding_operation["soap_action"].to_s
    end

    def types
      @types = {}

      @definition[:schemas].each do |schema|
        schema[:elements].each do |element_name, element|
          complex_type = element["complexType"]
          process_type(element_name, schema, complex_type) if complex_type
        end

        schema[:complex_types].each do |complex_type_name, complex_type|
          process_type(complex_type_name, schema, complex_type)
        end
      end

      resolve_deferred_types
      @types
    end

    def deferred_types
      @deferred_types ||= []
    end

    def resolve_deferred_types
      deferred_types.each(&:call)
    end

    def type_map
      type_map = {}

      @definition[:schemas].each do |schema|
        schema[:elements].each do |name, type|
          if complex_type = type["complexType"]
            type_map_element(type_map, name, schema, complex_type)
          end
        end

        schema[:complex_types].each do |name, type|
          type_map_element(type_map, name, schema, type)
        end

        schema[:simple_types].each do |name, type|
          type_map_element(type_map, name, schema, type)
        end
      end

      type_map
    end

    private

    def endpoints!
      ports.inject({}) do |endpoints, port|
        endpoints.merge(port["namespace"] => port["location"])
      end
    end

    def operations!
      operations = {}

      soap_port = ports.find { |port|
        port["namespace"] == Wasabi::NAMESPACES["soap"] ||
        port["namespace"] == Wasabi::NAMESPACES["soap2"]
      }

      binding = find_binding(soap_port)
      raise_binding_error!(soap_port) unless binding

      port_type = find_port_type(binding)
      raise_port_type_error!(binding) unless port_type

      binding["operations"].each do |operation_name, binding_operation|
        port_type_operation = find_port_type_operation(operation_name, port_type)

        operations[operation_name.snakecase.to_sym] = {
          :binding_operation   => binding_operation,
          :port_type_operation => port_type_operation
        }
      end

      operations
    end

    def ports
      @ports ||= ports!
    end

    def ports!
      ports = []

      @definition[:services].each do |_, port_map|
        port_map.each do |_, details|
          ports << details
        end
      end

      ports
    end

    def find_binding(port)
      binding_name = port["binding"].split(":").last
      @definition[:bindings][binding_name]
    end

    def find_port_type(binding)
      port_type_name = binding["type"].split(":").last
      @definition[:port_types][port_type_name]
    end

    def find_port_type_operation(operation_name, port_type)
      port_type["operations"][operation_name]
    end

    def messages
      @messages ||= { "input" => {}, "output" => {} }
    end

    def message_for(operation_name, type)
      messages[type][operation_name] ||= message_for!(operation_name, type)
    end

    def message_for!(operation_name, type)
      input_output = operations[operation_name][:port_type_operation]
      message_name = input_output[type].first.last["message"].to_s

      port_message_nsid, port_message_type = message_name.split(":")
      message_nsid = nil
      message_type = nil

      port_message_part = @definition[:messages][port_message_type]
      if port_message_part && port_message_part.first
        port_message_part_element = port_message_part.first["element"]
        if port_message_part_element
          message_nsid, message_type = port_message_part_element.to_s.split(":")
        end
      end

      if message_type
        [message_nsid, message_type]
      else
        [port_message_nsid, port_message_type]
      end
    end

    def raise_binding_error!(soap_port)
      raise DefinitionError, "Unable to find binding for soap port:\n" + soap_port.inspect
    end

    def raise_port_type_error!(binding)
      raise DefinitionError, "Unable to find port type for binding:\n" + binding.inspect
    end

    def process_type(name, schema, type)
      @types[name] ||= { :namespace => schema[:namespace] }

      if type["sequence"] && type["sequence"]["element"]
        type["sequence"]["element"].each do |element|
          @types[name][element["name"]] = { :type => element["type"] }
        end
      elsif type["complexContent"] && type["complexContent"]["extension"]
        extension  = type["complexContent"]["extension"]
        elements   = extension["sequence"] && extension["sequence"]["element"]
        elements ||= []

        elements.each do |element|
          @types[name][element["name"]] = { :type => element["type"] }
        end

        if extension["base"]
          base = extension["base"].match(/\w+$/).to_s

          if @types[base]
            @types[name].merge! @types[base]
          else
            deferred_types << Proc.new { @types[name].merge! @types[base] }
          end
        end
      end
    end

    def type_map_element(type_map, name, schema, type)
      type_map[name] ||= type_element = {}  # { :namespace => schema[:namespace] }

      #
      # { :sequence => [
      #   {
      #     "minOccurs" => "1",
      #     "maxOccurs" => "1",
      #     "name"      => "CreditCardType",
      #     "type"      => "tns:CCType"
      #   }
      # ]}
      #
      if type["sequence"]
        sequence = type["sequence"]["element"]
        type_element[:sequence] = sequence

      #
      # { :extension => "ReturnValue",          # optional
      #   :sequence  => [                       # optional
      #     {
      #       "minOccurs" => "1",
      #       "maxOccurs" => "1",
      #       "name"      => "CreditCardType",
      #       "type"      => "tns:CCType"
      #     }
      #   ]
      # }
      #
      elsif type["complexContent"] && type["complexContent"]["extension"]
        extension = type["complexContent"]["extension"]

        if extension["base"]
          base = extension["base"].match(/\w+$/).to_s
          type_element[:extension] = base
        end

        if extension["sequence"]
          elements = extension["sequence"]["element"]
          type_element[:sequence] = elements
        end

        other_keys = extension.keys - %w(base sequence)
        raise "other keys!" unless other_keys.empty?

      #
      # { :restriction => {
      #   :base        => "xsd:string",
      #   :enumeration => ["OK", "API_ERROR"]
      # }}
      #
      elsif type["restriction"]
        type_element.merge! type

      #
      # { :empty => true }
      #
      elsif type.empty?
        type_element[:empty] = true

      elsif type["annotation"]
        nil  # ignore

      else
        raise "else!"
      end

      type_map[name] = type_element
    end

  end
end
