# frozen_string_literal: true

require "nokogiri"
require "wasabi/resolver"
require "wasabi/parser"

module Wasabi
  # Raised when the document to parse is not a WSDL, like an HTML page or an empty body.
  class InvalidDocumentError < StandardError
  end

  # = Wasabi::Document
  #
  # Represents a WSDL document.
  class Document
    ELEMENT_FORM_DEFAULTS = [:unqualified, :qualified]

    # Validates if a given +value+ is a valid elementFormDefault value.
    # Raises an +ArgumentError+ if the value is not valid.
    def self.validate_element_form_default!(value)
      return if ELEMENT_FORM_DEFAULTS.include?(value)

      raise ArgumentError, "Invalid value for elementFormDefault: #{value}\n" \
        "Must be one of: #{ELEMENT_FORM_DEFAULTS.inspect}"
    end

    # Accepts a WSDL +document+ to parse.
    def initialize(document = nil, adapter = nil)
      self.document = document
      self.adapter = adapter
    end

    attr_accessor :document, :request, :adapter

    attr_writer :xml

    alias_method :document?, :document

    # Returns the SOAP endpoint.
    def endpoint
      @endpoint ||= parser.endpoint
    end

    # Sets the SOAP endpoint.
    attr_writer :endpoint

    # Returns the SOAP endpoint of the port serving the given SOAP operation.
    #
    # Walks operation -> portType -> binding -> port, so WSDLs exposing
    # several ports resolve to the address of the port that actually serves
    # the operation instead of the first port's address. When +soap_version+
    # is given, a port for that SOAP version is preferred; otherwise the
    # first SOAP port for the operation is returned. Non-SOAP ports are
    # never returned. Returns +nil+ when the operation has no SOAP ports,
    # so callers can fall back to #endpoint.
    def endpoint_for_operation(operation_name, soap_version: nil)
      service_ports.endpoint_for_operation(operation_name, soap_version: soap_version)
    end

    # Returns the target namespace.
    def namespace
      @namespace ||= parser.namespace
    end

    # Sets the target namespace.
    attr_writer :namespace

    # Returns the value of elementFormDefault.
    def element_form_default
      @element_form_default ||= document ? parser.element_form_default : :unqualified
    end

    # Sets the elementFormDefault value.
    def element_form_default=(value)
      self.class.validate_element_form_default!(value)
      @element_form_default = value
    end

    # Returns a list of available SOAP actions.
    def soap_actions
      @soap_actions ||= parser.operations.keys
    end

    # Returns the SOAP action for a given +key+.
    def soap_action(key)
      operations[key][:action] if operations[key]
    end

    # Returns the SOAP input for a given +key+.
    def soap_input(key)
      operations[key][:input] if operations[key]
    end

    # Returns a map of SOAP operations.
    def operations
      @operations ||= parser.operations
    end

    # Returns the service name.
    def service_name
      @service_name ||= parser.service_name
    end

    attr_writer :service_name

    # Returns a list of parameter names for a given +key+
    def soap_action_parameters(key)
      params = operation_input_parameters(key)
      params&.keys
    end

    # Returns a list of input parameters for a given +key+.
    def operation_input_parameters(key)
      parser.operations[key][:parameters] if operations[key]
    end

    def type_namespaces
      @type_namespaces ||= begin
        namespaces = []

        if document
          parser.types.each do |ns, types|
            types.each do |type, info|
              namespaces << [[type], info[:namespace]]

              each_element([type], info) do |path, _definition|
                namespaces << [path, info[:namespace]]
              end
            end
          end
        end

        namespaces
      end
    end

    def type_definitions
      @type_definitions ||= begin
        result = []

        if document
          parser.types.each do |ns, types|
            types.each do |type, info|
              each_element([type], info) do |path, definition|
                tag, namespace = definition[:type].split(":").reverse

                result << [path, tag] if user_defined(namespace)
              end
            end
          end
        end

        result
      end
    end

    # Returns whether the given +namespace+ was defined manually.
    def user_defined(namespace)
      uri = parser.namespaces[namespace]
      !(uri =~ %r{^http://schemas.xmlsoap.org} || uri =~ %r{^http://www.w3.org})
    end

    # Returns the raw WSDL document.
    # Can be used as a hook to extend the library.
    def xml
      @xml ||= Resolver.new(document, request, adapter).resolve
    end

    # Parses the WSDL document and returns the <tt>Wasabi::Parser</tt>.
    def parser
      @parser ||= guard_parse && parse
    end

    private

    # Returns the service ports of the WSDL document.
    def service_ports
      @service_ports ||= ServicePorts.new(parser.document)
    end

    # Raises an error if the WSDL document is missing.
    def guard_parse
      return true if document
      raise ArgumentError, "Wasabi needs a WSDL document"
    end

    # Parses the WSDL document and returns <tt>Wasabi::Parser</tt>.
    def parse
      xml_document = Nokogiri::XML(xml)
      unless xml_document.root&.name == "definitions"
        raise InvalidDocumentError, "Wasabi needs a WSDL document, got: #{xml.to_s[0, 100].inspect}"
      end

      parser = Parser.new xml_document
      parser.parse
      parser
    end

    # Yields the path and definition of each element of a type, then of the
    # elements of each inline complexType below it. Inline complexTypes that
    # extend each other's types share definitions, so the walk stops at the
    # first definition already on its path.
    def each_element(path, info, ancestors = [info], &block)
      info.each do |key, definition|
        next unless key.is_a?(String)

        element_path = path + [key]
        yield element_path, definition
        next if ancestors.any? { |ancestor| ancestor.equal?(definition) }

        each_element(element_path, definition, ancestors + [definition], &block)
      end
    end
  end
end
