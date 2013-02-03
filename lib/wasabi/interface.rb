require "wasabi/parser"
require "wasabi/interface_shim"
require "wasabi/core_ext/string"

module Wasabi

  # = Wasabi::Interface
  #
  # Purpose:
  #   Interface for the parser's definition.
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

    def operations
      @operations ||= operations!
    end

    def type_map
      @type_map ||= definition.type_map
    end

    def types
      @types ||= definition.types
    end

    # XXX: legacy method. convert specs and remove! [dh, 2013-02-03]
    def type_namespaces
      namespaces = []

      types.each do |type, info|
        namespaces << [[type], info[:namespace]]

        subtypes = (info.keys - [:namespace])
        subtypes.each { |field| namespaces << [[type, field], info[:namespace]] }
      end

      namespaces
    end

    # XXX: legacy method. convert specs and remove! [dh, 2013-02-03]
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

    # XXX: legacy method. convert specs and remove! [dh, 2013-02-03]
    def user_defined?(namespace)
      uri = namespaces["xmlns:#{namespace}"]
      !(uri =~ %r{^http://schemas.xmlsoap.org} || uri =~ %r{^http://www.w3.org})
    end

    private

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

    def definition
       @definition ||= begin
         parser = Wasabi.parser(@source, @http_request)
         Wasabi.definition(parser.definition)
       end
    end

  end
end
