require "wasabi/node"
require "wasabi/matcher"

module Wasabi
  class SAXParser < Nokogiri::XML::SAX::Document

    def initialize
      @stack            = []
      @matchers         = {}
      @namespaces       = nil
      @target_namespace = nil
      @bindings         = {}
      @port_types       = {}
      @services         = {}
    end

    attr_reader :target_namespace, :bindings, :port_types, :services

    def export
      {
        "target_namespace" => @target_namespace,
        "bindings"         => @bindings,
        "port_types"       => @port_types,
        "services"         => @services
      }
    end

    def start_element(tag, attrs = [])
      # grabs the namespaces from the root node once
      @namespaces = collect_namespaces(attrs) unless @namespaces

      node = create_node(tag, Hash[attrs])
      @stack.push(node.to_s)

      case @stack
      # target namespace
      when matches("wsdl:definitions")
        @target_namespace = node["targetNamespace"]

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
      end
    end

    def end_element(name)
      @stack.pop
    end

    private

    def create_node(tag, attrs)
      local, nsid = tag.split(":").reverse

      @last_namespace = attrs["xmlns"] if attrs["xmlns"]
      namespace = nsid ? @namespaces["xmlns:#{nsid}"] : @last_namespace

      Node.new(namespace, local, attrs)
    end

    def matches(matcher)
      @matchers[matcher] ||= Matcher.new(matcher)
    end

    def collect_namespaces(attrs)
      attrs.each_with_object({}) { |(key, value), memo|
        memo[key] = value if key =~ /^xmlns/
      }
    end

  end
end
