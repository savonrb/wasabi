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
      @endpoints ||= endpoints!
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
        # find the binding
        binding_name   = port["binding"].split(":").last
        binding        = @sax.bindings[binding_name]

        # find the port type
        port_type_name = binding["type"].split(":").last
        port_type      = @sax.port_types[port_type_name]

        binding["operations"].each do |operation_name, binding_operation|
          # find the port type operation
          port_type_operation = port_type["operations"][operation_name]

          # XXX: this does not support multiple messages!
          input  = port_type_operation["input"].first
          output = port_type_operation["output"].first

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

    def endpoints!
      ports!.inject({}) do |endpoints, port|
        endpoints.merge(port["namespace"] => port["location"])
      end
    end

    def ports!
      ports = []

      @sax.services.each do |service_name, port_map|
        port_map.each do |port_name, details|
          ports << details
        end
      end

      ports
    end

  end
end