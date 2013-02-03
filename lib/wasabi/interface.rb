require "wasabi/sax"
require "wasabi/interface_shim"
require "wasabi/core_ext/string"

module Wasabi

  # = Wasabi::Interface
  #
  # Purpose:
  #   Interprets the SAX information.
  class Interface

    def initialize(source, http_request = nil)
      @source = source
      @http_request = @http_request
    end

    def shim?
      false
    end

    def soap_endpoint
      return @soap_endpoint if @soap_endpoint

      soap_namespace  = Wasabi::NAMESPACES["soap"]
      soap2_namespace = Wasabi::NAMESPACES["soap2"]

      @soap_endpoint  = definition.endpoints[soap_namespace] ||
                        definition.endpoints[soap2_namespace]
    end

    attr_writer :soap_endpoint

    def namespaces
      definition.namespaces
    end

    def target_namespace
      definition.target_namespace
    end

    attr_writer :target_namespace

    def element_form_default
      raise "TODO: REMOVE!"
      #@element_form_default ||= sax[:schemas].first[:element_form_default].to_sym
    end

    attr_writer :element_form_default

    def operations
      @operations ||= operations!
    end

    def operations!
      operations = {}

      definition.operations.each do |operation_name, _|
        operations[operation_name] = {
          :input       => definition.input_for(operation_name),
          :output      => definition.output_for(operation_name),
          :soap_action => definition.soap_action_for(operation_name)
        }
      end

      operations
    end

    def type_map
      @type_map ||= type_map!
    end

    def types
      @types = {}

      definition.sax[:schemas].each do |schema|
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

    def type_namespaces
      namespaces = []

      types.each do |type, info|
        namespaces << [[type], info[:namespace]]

        subtypes = (info.keys - [:namespace])
        subtypes.each { |field| namespaces << [[type, field], info[:namespace]] }
      end

      namespaces
    end

    def type_definitions
      result = []

      types.each do |type, info|
        (info.keys - [:namespace]).each do |field|
          field_type = info[field][:type]
          next unless field_type

          tag, namespace = field_type.split(":").reverse

          result << [[type, field], tag] if user_defined? namespace
        end
      end

      result
    end

    def user_defined?(namespace)
      uri = namespaces["xmlns:#{namespace}"]
      !(uri =~ %r{^http://schemas.xmlsoap.org} || uri =~ %r{^http://www.w3.org})
    end

    private

    def definition
       @definition ||= begin
         sax = Wasabi.sax(@source, @http_request)
         Wasabi.definition(sax.definition)
       end
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

    def resolve_deferred_types
      deferred_types.each(&:call)
    end

    def type_map!
      type_map = {}

      definition.sax[:schemas].each do |schema|
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
