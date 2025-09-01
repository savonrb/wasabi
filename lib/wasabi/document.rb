# frozen_string_literal: true

require "nokogiri"
require "wasabi/resolver"
require "wasabi/parser"

module Wasabi

  # = Wasabi::Document
  #
  # Represents a WSDL document.
  class Document

    ELEMENT_FORM_DEFAULTS = [:unqualified, :qualified]

    # Validates if a given +value+ is a valid elementFormDefault value.
    # Raises an +ArgumentError+ if the value is not valid.
    def self.validate_element_form_default!(value)
      return if ELEMENT_FORM_DEFAULTS.include?(value)

      raise ArgumentError, "Invalid value for elementFormDefault: #{value}\n" +
                           "Must be one of: #{ELEMENT_FORM_DEFAULTS.inspect}"
    end

    # Accepts a WSDL +document+ to parse.
    def initialize(document = nil, adapter = nil)
      self.document = document
      self.adapter  = adapter
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
      params.keys if params
    end

    # Returns a list of input parameters for a given +key+.
    def operation_input_parameters(key)
      parser.operations[key][:parameters] if operations[key]
    end

    # Returns type information for a given type name.
    def type_definition(type_name)
      return nil unless type_name

      @type_definitions ||= {}
      return @type_definitions[type_name] if @type_definitions[type_name]

      type_info = find_type_info(type_name)
      return nil unless type_info

      definition = {
        name: type_name,
        namespace: type_info[:namespace],
        fields: {},
        order: type_info[:order!] || []
      }

      type_info.each do |field_name, field_info|
        next if [:namespace, :order!, :base_type].include?(field_name)
        next if field_info.nil? || !field_info.is_a?(Hash)

        definition[:fields][field_name] = {
          type: field_info[:type],
          required: field_info[:minOccurs] != "0",
          array: field_info[:maxOccurs] == "unbounded" || (field_info[:maxOccurs].to_i > 1),
          min_occurs: field_info[:minOccurs],
          max_occurs: field_info[:maxOccurs],
          nillable: field_info[:nillable] == "true"
        }
      end

      @type_definitions[type_name] = definition
      definition
    end

    # Input type for an operation
    def operation_input_type(operation_name)
      operation_key = operation_name.to_sym
      operation = parser.operations[operation_key]
      return nil unless operation

      input_type = operation[:input]
      type_definition(input_type) || type_definition("#{input_type}Type")
    end

    # Output type for an operation
    def operation_output_type(operation_name)
      operation_key = operation_name.to_sym
      operation = parser.operations[operation_key]
      return nil unless operation

      output_type = operation[:output]
      type_definition(output_type) || type_definition("#{output_type}Type")
    end

    def type_namespaces
      @type_namespaces ||= begin
        namespaces = []

        parser.types.each do |ns, types|
          types.each do |type, info|
            namespaces << [[type], info[:namespace]]

            element_keys(info).each do |field|
              namespaces << [[type, field], info[:namespace]]
            end
          end
        end if document

        namespaces
      end
    end

    def type_definitions
      @type_definitions ||= begin
        result = []

        parser.types.each do |ns, types|
          types.each do |type, info|
            element_keys(info).each do |field|
              field_type = info[field][:type]
              tag, namespace = field_type.split(":").reverse

              result << [[type, field], tag] if user_defined(namespace)
            end
          end
        end if document

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

    # Raises an error if the WSDL document is missing.
    def guard_parse
      return true if document
      raise ArgumentError, "Wasabi needs a WSDL document"
    end

    # Parses the WSDL document and returns <tt>Wasabi::Parser</tt>.
    def parse
      base_path = determine_base_path
      parser = Parser.new Nokogiri::XML(xml), base_path
      parser.parse
      parser
    end

    # Base path for resolving relative schema locations
    def determine_base_path
      return nil unless document

      if document.is_a?(String)
        if document =~ /^http[s]?:/
          document
        elsif document =~ /^</
          nil
        else
          File.expand_path(document)
        end
      else
        nil
      end
    end

    def element_keys(info)
      info.keys - [:namespace, :order!, :base_type]
    end

        # Find type info with XSD resolution rules
    def find_type_info(type_name, context_namespace = nil)
      return nil unless type_name

      @type_resolution_cache ||= {}
      cache_key = "#{type_name}:#{context_namespace}"
      return @type_resolution_cache[cache_key] if @type_resolution_cache.key?(cache_key)

      result = resolve_type_systematically(type_name, context_namespace)
      @type_resolution_cache[cache_key] = result
      result
    end

    private

    def resolve_type_systematically(type_name, context_namespace)
      # Handle qualified names (prefix:localname)
      if type_name.include?(':')
        prefix, local_name = type_name.split(':', 2)
        namespace_uri = parser.namespaces[prefix]
        if namespace_uri && parser.types[namespace_uri]
          return parser.types[namespace_uri][local_name]
        end
      end

      # Build type index
      @type_index ||= build_type_index

      # Search with XSD precedence
      candidates = []

      # Exact match in context namespace
      if context_namespace && @type_index[context_namespace]&.key?(type_name)
        candidates << { type_info: @type_index[context_namespace][type_name], priority: 1 }
      end

      # Exact match in any namespace
      @type_index.each do |namespace, types|
        next if namespace == context_namespace
        if types.key?(type_name)
          candidates << { type_info: types[type_name], priority: 2 }
        end
      end

      # Try with "Type" suffix
      type_name_with_suffix = "#{type_name}Type"
      @type_index.each do |namespace, types|
        if types.key?(type_name_with_suffix)
          candidates << { type_info: types[type_name_with_suffix], priority: 3 }
        end
      end

      candidates.min_by { |c| c[:priority] }&.dig(:type_info)
    end

    def build_type_index
      # Build lookup index
      index = {}
      parser.types.each do |namespace, types|
        index[namespace] = types.dup
      end
      index
    end
  end
end
