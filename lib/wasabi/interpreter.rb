require "wasabi/sax"
require "wasabi/interpreter_shim"
require "wasabi/core_ext/string"

module Wasabi

  # = Wasabi::Interpreter
  #
  # Purpose:
  #   Interprets the SAX information.
  class Interpreter

    def initialize(wsdl, http_request)
      @wsdl = wsdl
      @http_request = http_request
    end

    def shim?
      false
    end

    def soap_endpoint
      return @soap_endpoint if @soap_endpoint

      soap_namespace  = Wasabi::NAMESPACES["soap"]
      soap2_namespace = Wasabi::NAMESPACES["soap2"]

      @soap_endpoint  = endpoints[soap_namespace] ||
                        endpoints[soap2_namespace]
    end

    attr_writer :soap_endpoint

    def endpoints
      ports!.inject({}) do |endpoints, port|
        endpoints.merge(port["namespace"] => port["location"])
      end
    end

    def namespaces
      sax.namespaces
    end

    def target_namespace
      @target_namespace ||= sax.target_namespace
    end

    attr_writer :target_namespace

    def element_form_default
      @element_form_default ||= sax.element_form_default.to_sym
    end

    attr_writer :element_form_default

    def operations
      return @operations if @operations
      operations = {}

      soap_port = ports!.find { |port|
        port["namespace"] == Wasabi::NAMESPACES["soap"] ||
        port["namespace"] == Wasabi::NAMESPACES["soap2"]
      }

      binding   = find_binding(soap_port)
      port_type = find_port_type(binding)

      binding["operations"].each do |operation_name, binding_operation|
        port_type_operation = find_port_type_operation(operation_name, port_type)

        operations.update(
          operation_name.snakecase.to_sym => {
            :input       => input_for(operation_name, port_type_operation),
            :output      => output_for(operation_name, port_type_operation),
            :soap_action => soap_action_for(operation_name, binding_operation)
          }
        )
      end

      @operations = operations
    end

    def types
      @types = {}

      sax.schemas.each do |schema|
        schema.elements.each do |element_name, element|
          complex_type = element["complexType"]
          process_type(element_name, schema, complex_type) if complex_type
        end

        schema.complex_types.each do |complex_type_name, complex_type|
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

    def sax
      return @sax if @sax

      wsdl   = Resolver.new(@wsdl, @http_request).xml
      sax    = SAX.new
      parser = Nokogiri::XML::SAX::Parser.new(sax)

      parser.parse(wsdl)
      @sax = sax
    end

    def ports!
      ports = []

      sax.services.each do |service_name, port_map|
        port_map.each do |port_name, details|
          ports << details
        end
      end

      ports
    end

    def find_port_type(binding)
      port_type_name = binding["type"].split(":").last
      sax.port_types[port_type_name]
    end

    def find_binding(port)
      binding_name = port["binding"].split(":").last
      sax.bindings[binding_name]
    end

    def find_port_type_operation(operation_name, port_type)
      port_type["operations"][operation_name]
    end

    def input_for(operation_name, port_type_operation)
      message_for(operation_name, port_type_operation, "input")
    end

    def output_for(operation_name, port_type_operation)
      message_for(operation_name, port_type_operation, "output")
    end

    def message_for(operation_name, input_output, type)
      message_name = input_output[type].first.last["message"].to_s

      port_message_nsid, port_message_type = message_name.split(":")
      message_nsid = nil
      message_type = nil

      # TODO: support multiple 'part' elements in the message
      port_message_part = sax.messages[port_message_type]
      if port_message_part && port_message_part.first
        port_message_part_element = port_message_part.first["element"]
        if port_message_part_element
          message_nsid, message_type = port_message_part_element.to_s.split(":")
        end
      end

      if message_type
        [message_nsid, message_type]
      else
        fallback_name = type == "input" ? operation_name : port_message_type
        [port_message_nsid, fallback_name]
      end
    end

    def soap_action_for(operation_name, binding_operation)
      soap_action = binding_operation["soap_action"].to_s

      if !soap_action.empty?
        soap_action
      else
        operation_name
      end
    end

    def process_type(name, schema, type)
      @types[name] ||= { :namespace => schema.namespace }

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

  end
end