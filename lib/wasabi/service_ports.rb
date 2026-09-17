# frozen_string_literal: true

require "uri"
require "addressable/uri"
require "wasabi/core_ext/string"

module Wasabi
  # = Wasabi::ServicePorts
  #
  # Parses the +wsdl:service+ ports and +wsdl:binding+ elements of a WSDL
  # document, so callers can resolve the SOAP endpoint of the port that
  # serves a given operation instead of always using the first port's
  # address.
  class ServicePorts
    SOAP_1_1 = "http://schemas.xmlsoap.org/wsdl/soap/"
    SOAP_1_2 = "http://schemas.xmlsoap.org/wsdl/soap12/"

    def initialize(document)
      @document = document
    end

    # Returns the parsed service ports as an Array of Hashes with +:name+,
    # +:binding+ (local binding name), +:address+ (URI) and +:soap_version+
    # (1, 2 or nil when the address is not a SOAP address) keys, in
    # document order.
    def ports
      @ports ||= parse_ports
    end

    # Returns the SOAP endpoint (address) of the port serving the given
    # SOAP operation.
    #
    # Walks operation -> portType -> binding -> port, so WSDLs exposing
    # several ports resolve to the address of the port that actually serves
    # the operation instead of the first port's address. When +soap_version+
    # is given, a port for that SOAP version is preferred, but the first
    # SOAP port for the operation is returned when no port matches the
    # requested version — routing degrades to the operation's best
    # available SOAP port instead of silently falling back to the WSDL's
    # first port. Non-SOAP ports (e.g. +http:address+) are never returned.
    # Returns +nil+ when the operation has no SOAP ports at all, so
    # callers can fall back to the default endpoint.
    def endpoint_for_operation(operation_name, soap_version: nil)
      port = preferred_port(operation_name, soap_version)
      port && port[:address]
    end

    private

    # Returns the preferred SOAP port serving the given SOAP operation.
    # Ports for the requested SOAP version win; otherwise the first SOAP
    # port in document order. Returns nil when the operation has no SOAP
    # ports at all.
    def preferred_port(operation_name, soap_version)
      candidates = soap_ports_for_operation(operation_name)

      candidates.find { |port| port[:soap_version] == soap_version } || candidates.first
    end

    # Returns the SOAP ports serving the given SOAP operation, in document
    # order. Non-SOAP ports (e.g. +http:address+) and ports with
    # unparsable addresses never qualify as routing candidates.
    def soap_ports_for_operation(operation_name)
      port_type = port_type_for_operation(operation_name)
      return [] unless port_type

      bindings = parse_bindings

      ports.select { |port|
        !port[:soap_version].nil? && !port[:address].nil? &&
          bindings[port[:binding]] == port_type
      }
    end

    # Returns the name of the portType defining the given operation.
    # Operation names are compared snake-cased, like the keys of
    # Wasabi::Parser#operations.
    def port_type_for_operation(operation_name)
      target = operation_name.to_sym

      port_type_operations.each do |port_type_name, operations|
        match = operations.any? { |name| Wasabi::CoreExt::String.snakecase(name.to_s).to_sym == target }
        return port_type_name if match
      end

      nil
    end

    # Returns a map from portType name to its operation names.
    def port_type_operations
      @port_type_operations ||= @document.root.element_children.each_with_object({}) do |node, memo|
        next unless node.name == "portType"

        operations = node.element_children.select { |child| child.name == "operation" }
        memo[node["name"]] = operations.map { |operation| operation["name"] }
      end
    end

    # Parses every +wsdl:port+ of the service in document order. Address
    # elements are matched by local name so any namespace prefix works, and
    # the SOAP version is derived from the address element's namespace.
    def parse_ports
      service_node = @document.root.element_children.find { |node| node.name == "service" }
      return [] unless service_node

      service_node.element_children.each_with_object([]) do |port, memo|
        next unless port.name == "port"

        address = port.element_children.find { |node| node.name == "address" }
        next unless address && address["location"]

        memo << {
          name: port["name"].to_s,
          binding: local_name(port["binding"]),
          address: parse_url(address["location"]),
          soap_version: soap_version_of(address)
        }
      end
    end

    # Parses every +wsdl:binding+ into a map from the local binding name
    # to the local portType name.
    def parse_bindings
      @document.root.element_children.each_with_object({}) do |node, memo|
        next unless node.name == "binding"

        memo[node["name"].to_s] = local_name(node["type"])
      end
    end

    # Returns the local part of a QName ("tns:Foo" -> "Foo").
    def local_name(qname)
      qname.to_s.split(":").last.to_s
    end

    # Returns 1 for SOAP 1.1 addresses, 2 for SOAP 1.2 addresses and nil
    # for anything else (e.g. http:address ports).
    def soap_version_of(address)
      href = address.namespace&.href

      if href == SOAP_1_2
        2
      elsif href == SOAP_1_1
        1
      end
    end

    def parse_url(url)
      unescaped_url = Addressable::URI.unescape(url.to_s)
      escaped_url = Addressable::URI.escape(unescaped_url)
      URI(escaped_url)
    rescue URI::InvalidURIError, Addressable::URI::InvalidURIError
      nil
    end
  end
end
