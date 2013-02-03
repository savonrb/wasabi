module Wasabi

  # = Wasabi::Definition
  #
  # Purpose:
  #   Interprets the parser's WSDL definition.
  class Definition

    def initialize(definition)
      @definition = definition
    end

    # TODO: find a better way to support the interpreter's type_map
    #       than exposing the definition. [dh, 2013-02-03]
    attr_reader :definition

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

  end
end
