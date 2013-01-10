require "wasabi/sax"

module Wasabi
  class Interpreter

    def initialize(sax)
      @sax = sax
    end

    def soap_endpoint
      # XXX: should we check for the soap 1.2 namespace as well?
      #      are there services with only a soap 1.2 endpoint?
      soap_namespace = Wasabi::NAMESPACES["soap"]
      endpoints[soap_namespace]
    end

    def endpoints
      ports!.inject({}) do |endpoints, port|
        endpoints.merge(port["namespace"] => port["location"])
      end
    end

    def target_namespace
      @sax.target_namespace
    end

    def element_form_default
      @sax.element_form_default.to_sym
    end

    def operations
      operations = {}

      ports!.each do |port|
        binding   = find_binding(port)
        port_type = find_port_type(binding)

        binding["operations"].each do |operation_name, binding_operation|
          port_type_operation = find_port_type_operation(operation_name, port_type)

          input  = input_for(operation_name, port_type_operation)
          output = output_for(operation_name, port_type_operation)

          operations.update(
            operation_name.snakecase.to_sym => {
              :soap_action => binding_operation["soap_action"],
              :input       => input.last["message"],
              :output      => output.last["message"]
            }
          )
        end
      end

      operations
    end

    private

    def ports!
      ports = []

      @sax.services.each do |service_name, port_map|
        port_map.each do |port_name, details|
          ports << details
        end
      end

      ports
    end

    def find_port_type(binding)
      port_type_name = binding["type"].split(":").last
      @sax.port_types[port_type_name]
    end

    def find_binding(port)
      binding_name = port["binding"].split(":").last
      @sax.bindings[binding_name]
    end

    def find_port_type_operation(operation_name, port_type)
      port_type["operations"][operation_name]
    end

    def input_for(operation_name, port_type_operation)
      port_type_operation["input"].first
    end

    def output_for(operation_name, port_type_operation)
      port_type_operation["output"].first
    end

  end
end