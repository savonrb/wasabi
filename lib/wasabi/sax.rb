require "nokogiri"
require "wasabi/node"
require "wasabi/matcher"
require "wasabi/schema"
require "wasabi/core_ext/hash"

module Wasabi

  # = Wasabi::SAX
  #
  # Purpose:
  #   Parses WSDL documents.
  class SAX < Nokogiri::XML::SAX::Document

    def initialize(source, http_request = nil)
      @source       = source
      @http_request = http_request

      @stack        = []
      @matchers     = {}
      @namespaces   = nil
      @schemas      = []
      @xs_imports   = {}
      @wsdl_imports = {}
      @messages     = {}
      @bindings     = {}
      @port_types   = {}
      @services     = {}
    end

    attr_reader :namespaces, :target_namespace, :schemas, :messages,
                :bindings, :port_types, :services

    def start_element(tag, attrs = [])
      local, nsid = tag.split(":").reverse
      attrs = Hash[attrs]

      # grabs namespaces from the root node
      @namespaces = collect_namespaces(attrs) unless @namespaces

      # grabs additional namespaces from the schema node
      @namespaces.merge! collect_namespaces(attrs) if local == "schema"

      node = create_node(nsid, local, attrs)
      @stack.push(node.to_s)

      case @stack
      # xs elements
      when matches("wsdl:definitions > wsdl:types > xs:schema > xs:element",
                   "xs:schema > xs:element")
        @last_element = @last_schema.elements[node["name"]] ||= node.attrs.reject { |k, _| k == "name" }
      when matches("wsdl:definitions > wsdl:types > xs:schema > xs:element > *",
                   "xs:schema > xs:element > *")
        if node.local == "element"
          element = @last_element["element"] ||= []
          element << node.attrs
        else
          @last_element = @last_element[node.local] = {}
        end

      # xs complex types
      when matches("wsdl:definitions > wsdl:types > xs:schema > xs:complexType",
                   "xs:schema > xs:complexType")
        @last_complex_type = @last_schema.complex_types[node["name"]] ||= {}
      when matches("wsdl:definitions > wsdl:types > xs:schema > xs:complexType > *",
                   "xs:schema > xs:complexType > *")
        if node.local == "element"
          element = @last_complex_type["element"] ||= []
          element << node.attrs
        elsif node.local == "extension"
          @last_complex_type = @last_complex_type[node.local] = {}
          @last_complex_type["base"] = node.attrs["base"] if node.attrs["base"]
        else
          @last_complex_type = @last_complex_type[node.local] = {}
        end

      # messages
      when matches("wsdl:definitions > wsdl:message")
        @last_message = @messages[node["name"]] = []
      when matches("wsdl:definitions > wsdl:message > wsdl:part")
        @last_message << node.attrs

      # port types
      when matches("wsdl:definitions > wsdl:portType")
        @last_port_type = @port_types[node["name"]] = { "operations" => {} }
      when matches("wsdl:definitions > wsdl:portType > wsdl:operation")
        @last_port_type_operation = @last_port_type["operations"][node["name"]] = {}
      when matches("wsdl:definitions > wsdl:portType > wsdl:operation > wsdl:input")
        @last_port_type_operation["input"] = {
          node["name"] => { "message" => node["message"] }
        }
      when matches("wsdl:definitions > wsdl:portType > wsdl:operation > wsdl:output")
        @last_port_type_operation["output"] = {
          node["name"] => { "message" => node["message"] }
        }

      # bindings
      when matches("wsdl:definitions > wsdl:binding")
        @last_binding = @bindings[node["name"]] = { "type" => node["type"], "operations" => {} }
      when matches("wsdl:definitions > wsdl:binding > soap|soap2:binding")
        @last_binding["namespace"] = node.namespace
        @last_binding["transport"] = node["transport"]
      when matches("wsdl:definitions > wsdl:binding > http:binding")
        @last_binding["namespace"] = node.namespace
        @last_binding["verb"]      = node["verb"]

      # binding operations
      when matches("wsdl:definitions > wsdl:binding > wsdl:operation")
        @last_binding_operation = @last_binding["operations"][node["name"]] = {}
      when matches("wsdl:definitions > wsdl:binding > wsdl:operation > soap|soap2:operation")
        @last_binding_operation["namespace"]   = node.namespace
        @last_binding_operation["soap_action"] = node["soapAction"]
        @last_binding_operation["style"]       = node["style"]
      when matches("wsdl:definitions > wsdl:binding > wsdl:operation > http:operation")
        @last_binding_operation["namespace"]   = node.namespace
        @last_binding_operation["location"]    = node["location"]
      when matches("wsdl:definitions > wsdl:binding > wsdl:operation > wsdl:input")
        input = @last_binding_operation["input"]  ||= {}
        @last_operation_input = input[node["name"]] = {}
      when matches("wsdl:definitions > wsdl:binding > wsdl:operation > wsdl:input > soap|soap2:body")
        @last_operation_input["body"] = { "use" => node["use"] }
      when matches("wsdl:definitions > wsdl:binding > wsdl:operation > wsdl:output")
        output = @last_binding_operation["output"]  ||= {}
        @last_operation_output = output[node["name"]] = {}
      when matches("wsdl:definitions > wsdl:binding > wsdl:operation > wsdl:output > soap|soap2:body")
        @last_operation_output["body"] = { "use" => node["use"] }

      # services
      when matches("wsdl:definitions > wsdl:service")
        @last_service = @services[node["name"]] = {}
      when matches("wsdl:definitions > wsdl:service > wsdl:port")
        @last_port = @last_service[node["name"]] = { "binding" => node["binding"] }
      when matches("wsdl:definitions > wsdl:service > wsdl:port > soap|soap2|http:address")
        @last_port["namespace"] = node.namespace
        @last_port["location"]  = node["location"]

      # wsdl imports
      when matches("wsdl:definitions > wsdl:import")
        @wsdl_imports[node["namespace"]] = node.attrs

      # xs imports
      when matches("wsdl:definitions > wsdl:types > xs:schema > xs:import")
                   # TODO: why is this commented out? [dh, 2012-01-12]
                   #"xs:schema > xs:import")
        @xs_imports[node["namespace"]] = node.attrs

      # schema and element/attribute form default values
      when matches("wsdl:definitions > wsdl:types > xs:schema",
                   "xs:schema")
        @last_schema = Schema.new(node)
        @schemas << @last_schema

      # target namespace
      when matches("wsdl:definitions")
        @target_namespace = node["targetNamespace"]
      end
    end

    def end_element(name)
      @stack.pop
    end

    def end_document
      resolve_wsdl_imports
      resolve_xs_imports
    end

    def hash
      @hash ||= begin
        {
          :namespaces       => @namespaces,
          :target_namespace => @target_namespace,
          :schemas          => @schemas.map(&:hash),
          :messages         => @messages,
          :bindings         => @bindings,
          :port_types       => @port_types,
          :services         => @services
        }
      end
    end

    private

    def resolve_xs_imports
      @xs_imports.each do |namespace, import|
        resolve_import! import["schemaLocation"] do |sax|
          schemas = sax.hash[:schemas]
          hash[:schemas] += schemas
        end
      end
    end

    def resolve_wsdl_imports
      @wsdl_imports.each do |namespace, import|
        resolve_import! import["location"] do |sax|
          @hash = hash.deep_merge(sax.hash)
        end
      end
    end

    def resolve_import!(location)
      source = URI.join(@source, location)

      if location && source
        yield Wasabi.sax(source, @http_request)
      end
    end

    def create_node(nsid, local, attrs)
      namespace = case
        when nsid           then @namespaces["xmlns:#{nsid}"]
        when attrs["xmlns"] then attrs["xmlns"]
        else                     parent_node_namespace
      end

      Node.new(namespace, local, attrs)
    end

    def parent_node_namespace
      return if @stack.empty?

      parent_nsid = @stack.last.split(":").first
      Wasabi::NAMESPACES[parent_nsid]
    end

    def matches(*matcher)
      @matchers[matcher] ||= Matcher.create(*matcher)
    end

    def collect_namespaces(attrs)
      attrs.inject({}) { |memo, (key, value)|
        memo[key] = value if key =~ /^xmlns/
        memo
      }
    end

  end
end
