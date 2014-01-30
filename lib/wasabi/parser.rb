require 'uri'
require 'wasabi/core_ext/string'

module Wasabi

  # = Wasabi::Parser
  #
  # Parses WSDL documents and remembers their important parts.
  class Parser

    XSD      = 'http://www.w3.org/2001/XMLSchema'
    WSDL     = 'http://schemas.xmlsoap.org/wsdl/'
    SOAP_1_1 = 'http://schemas.xmlsoap.org/wsdl/soap/'
    SOAP_1_2 = 'http://schemas.xmlsoap.org/wsdl/soap12/'

    def initialize(document)
      self.document = document
      self.operations = {}
      self.namespaces = {}
      self.service_name = ''
      self.types = {}
      self.deferred_types = []
      self.element_form_default = :unqualified
    end

    # Returns the Nokogiri document.
    attr_accessor :document

    # Returns the target namespace.
    attr_accessor :namespace

    # Returns a map from namespace identifier to namespace URI.
    attr_accessor :namespaces

    # Returns the SOAP operations.
    attr_accessor :operations

    # Returns a map from a type name to a Hash with type information.
    attr_accessor :types

    # Returns a map of deferred type Proc objects.
    attr_accessor :deferred_types

    # Returns the SOAP endpoint.
    attr_accessor :endpoint

    # Returns the SOAP Service Name
    attr_accessor :service_name

    # Returns the elementFormDefault value.
    attr_accessor :element_form_default

    def parse
      parse_namespaces
      parse_endpoint
      parse_service_name
      parse_messages
      parse_port_types
      parse_port_type_operations
      parse_operations
      parse_operations_parameters
      parse_types
      parse_deferred_types
    end

    def parse_namespaces
      element_form_default = schemas.first && schemas.first['elementFormDefault']
      @element_form_default = element_form_default.to_s.to_sym if element_form_default

      namespace = document.root['targetNamespace']
      @namespace = namespace.to_s if namespace

      @namespaces = @document.namespaces.inject({}) do |memo, (key, value)|
        memo[key.sub('xmlns:', '')] = value
        memo
      end
    end

    def parse_endpoint
      if service_node = service
        endpoint = service_node.at_xpath('.//soap11:address/@location', 'soap11' => SOAP_1_1)
        endpoint ||= service_node.at_xpath(service_node, './/soap12:address/@location', 'soap12' => SOAP_1_2)
      end

      @endpoint = parse_url(endpoint) if endpoint
    end

    def parse_url(url)
      unescaped_url = URI.unescape(url.to_s)
      escaped_url   = URI.escape(unescaped_url)
      URI.parse(escaped_url)
    rescue URI::InvalidURIError
    end

    def parse_service_name
      service_name = document.root['name']
      @service_name = service_name.to_s if service_name
    end

    def parse_messages
      messages = document.root.element_children.select { |node| node.name == 'message' }
      @messages = Hash[messages.map { |node| [node['name'], node] }]
    end

    def parse_port_types
      port_types = document.root.element_children.select { |node| node.name == 'portType' }
      @port_types = Hash[port_types.map { |node| [node['name'], node] }]
    end

    def parse_port_type_operations
      @port_type_operations = {}

      @port_types.each do |port_type_name, port_type|
        operations = port_type.element_children.select { |node| node.name == 'operation' }
        @port_type_operations[port_type_name] = Hash[operations.map { |node| [node['name'], node] }]
      end
    end

    def parse_operations_parameters
      root_elements = document.xpath("wsdl:definitions/wsdl:types/*[local-name()='schema']/*[local-name()='element']", 'wsdl' => WSDL).each do |element|
        name = element.attribute('name').to_s.snakecase.to_sym

        if operation = @operations[name]
          element.xpath("*[local-name() ='complexType']/*[local-name() ='sequence']/*[local-name() ='element']").each do |child_element|
            attr_name = child_element.attribute('name').to_s
            attr_type = (attr_type = child_element.attribute('type').to_s.split(':')).size > 1 ? attr_type[1] : attr_type[0]

            operation[:parameters] ||= {}
            operation[:parameters][attr_name.to_sym] = { :name => attr_name, :type => attr_type }
          end
        end
      end
    end

    def parse_operations
      operations = document.xpath('wsdl:definitions/wsdl:binding/wsdl:operation', 'wsdl' => WSDL)
      operations.each do |operation|
        name = operation.attribute('name').to_s

        # TODO: check for soap namespace?
        soap_operation = operation.element_children.find { |node| node.name == 'operation' }
        soap_action = soap_operation['soapAction'] if soap_operation

        if soap_action
          soap_action = soap_action.to_s
          action = soap_action && !soap_action.empty? ? soap_action : name

          # There should be a matching portType for each binding, so we will lookup the input from there.
          namespace_id, output = output_for(operation)
          namespace_id, input = input_for(operation)

          # Store namespace identifier so this operation can be mapped to the proper namespace.
          @operations[name.snakecase.to_sym] = { :action => action, :input => input, :output => output, :namespace_identifier => namespace_id}
        elsif !@operations[name.snakecase.to_sym]
          @operations[name.snakecase.to_sym] = { :action => name, :input => name }
        end
      end
    end

    def parse_types
      schemas.each do |schema|
        schema_namespace = schema['targetNamespace']

        schema.element_children.each do |node|
          namespace = schema_namespace || @namespace

          case node.name
          when 'element'
            complex_type = node.at_xpath('./xs:complexType', 'xs' => XSD)
            process_type namespace, complex_type, node['name'].to_s if complex_type
          when 'complexType'
            process_type namespace, node, node['name'].to_s
          end
        end
      end
    end

    def process_type(namespace, type, name)
      @types[name] ||= { :namespace => namespace }
      @types[name][:order!] = []

      type.xpath('./xs:sequence/xs:element', 'xs' => XSD).each do |inner|
        element_name = inner.attribute('name').to_s
        @types[name][element_name] = { :type => inner.attribute('type').to_s }

        [ :nillable, :minOccurs, :maxOccurs ].each do |attr|
          if v = inner.attribute(attr.to_s)
            @types[name][element_name][attr] = v.to_s
          end
        end

        @types[name][:order!] << element_name
      end

      type.xpath('./xs:complexContent/xs:extension/xs:sequence/xs:element', 'xs' => XSD).each do |inner_element|
        element_name = inner_element.attribute('name').to_s
        @types[name][element_name] = { :type => inner_element.attribute('type').to_s }

        @types[name][:order!] << element_name
      end

      type.xpath('./xs:complexContent/xs:extension[@base]', 'xs' => XSD).each do |inherits|
        base = inherits.attribute('base').value.match(/\w+$/).to_s

        if @types[base]
          # Reverse merge because we don't want subclass attributes to be overriden by base class
          @types[name] = types[base].merge(types[name])
          @types[name][:order!] = @types[base][:order!] | @types[name][:order!]
          @types[name][:base_type] = base
        else
          p = Proc.new do
            if @types[base]
              # Reverse merge because we don't want subclass attributes to be overriden by base class
              @types[name] = @types[base].merge(@types[name])
              @types[name][:order!] = @types[base][:order!] | @types[name][:order!]
              @types[name][:base_type] = base
            end
          end
          deferred_types << p
        end
      end
    end

    def parse_deferred_types
      deferred_types.each(&:call)
    end

    def input_for(operation)
      input_output_for(operation, 'input')
    end

    def output_for(operation)
      input_output_for(operation, 'output')
    end

    def input_output_for(operation, input_output)
      operation_name = operation['name']

      # Look up the input by walking up to portType, then up to the message.

      binding_type = operation.parent['type'].to_s.split(':').last
      if @port_type_operations[binding_type]
        port_type_operation = @port_type_operations[binding_type][operation_name]
      end

      port_type_input_output = port_type_operation &&
        port_type_operation.element_children.find { |node| node.name == input_output }

      # TODO: Stupid fix for missing support for imports.
      # Sometimes portTypes are actually included in a separate WSDL.
      if port_type_input_output
        if port_type_input_output.attribute('message').to_s.include? ':'
          port_message_ns_id, port_message_type = port_type_input_output.attribute('message').to_s.split(':')
        else
          port_message_type = port_type_input_output.attribute('message').to_s
        end

        message_ns_id, message_type = nil

        # When there is a parts attribute in soap:body element, we should use that value
        # to look up the message part from messages array.
        input_output_element = operation.element_children.find { |node| node.name == input_output }
        if input_output_element
          soap_body_element = input_output_element.element_children.find { |node| node.name == 'body' }
          soap_body_parts = soap_body_element['parts'] if soap_body_element
        end

        message = @messages[port_message_type]
        port_message_part = message.element_children.find do |node| 
          soap_body_parts.nil? ? (node.name == 'part') : ( node.name == 'part' && node['name'] == soap_body_parts)
        end
        
        if port_message_part && port_element = port_message_part.attribute('element')
          port_message_part = port_element.to_s
          if port_message_part.include?(':')
            message_ns_id, message_type = port_message_part.split(':')
          else
            message_type = port_message_part
          end
        end

        # Fall back to the name of the binding operation
        if message_type
          [message_ns_id, message_type]
        else
          [port_message_ns_id, operation_name]
        end
      else
        [nil, operation_name]
      end
    end

    def schemas
      types = section('types').first
      types ? types.element_children : []
    end

    def service
      services = section('service')
      services.first if services  # service nodes could be imported?
    end

    def section(section_name)
      sections[section_name] || []
    end

    def sections
      return @sections if @sections

      sections = {}
      document.root.element_children.each do |node|
        (sections[node.name] ||= []) << node
      end

      @sections = sections
    end
  end
end
