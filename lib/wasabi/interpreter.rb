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

    def namespaces
      @sax.namespaces
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

    def types
      @types = {}

      @sax.schemas.each do |schema|
        schema.elements.each do |element_name, element|
          complex_type = element["complexType"]
          process_type(element_name, schema, complex_type) if complex_type
        end

        schema.complex_types.each do |complex_type_name, complex_type|
          process_type(complex_type_name, schema, complex_type)
        end
      end

      @types
    end

    def process_type(name, schema, type)
      @types[name] ||= { :namespace => schema.namespace }

      if type["sequence"] && type["sequence"]["element"]
        type["sequence"]["element"].each do |element|
          @types[name][element["name"]] = { :type => element["type"] }
        end
      elsif type["complexContent"] && type["complexContent"]["extension"]
        # type.xpath("./xs:complexContent/xs:extension/xs:sequence/xs:element",
        #   "xs" => "http://www.w3.org/2001/XMLSchema"
        # ).each do |inner_element|
        #   @types[name][inner_element.attribute('name').to_s] = {
        #     :type => inner_element.attribute('type').to_s
        #   }
        # end
        #
        # type.xpath('./xs:complexContent/xs:extension[@base]',
        #   "xs" => "http://www.w3.org/2001/XMLSchema"
        # ).each do |inherits|
        #   base = inherits.attribute('base').value.match(/\w+$/).to_s
        #   if @types[base]
        #     @types[name].merge! @types[base]
        #   else
        #     deferred_types << Proc.new { @types[name].merge! @types[base] }
        #   end
        # end
        raise "implement!"
      else
        raise "what else?!"
      end
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