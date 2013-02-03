require "wasabi/version"
require "wasabi/resolver"
require "wasabi/interface"
require "wasabi/definition"

module Wasabi

  NAMESPACES = {
    "wsdl"  => "http://schemas.xmlsoap.org/wsdl/",
    "http"  => "http://schemas.xmlsoap.org/wsdl/http/",
    "soap"  => "http://schemas.xmlsoap.org/wsdl/soap/",
    "soap2" => "http://schemas.xmlsoap.org/wsdl/soap12/",
    "xs"    => "http://www.w3.org/2001/XMLSchema"
  }

  NAMESPACES_BY_URI = NAMESPACES.invert

  DefinitionError = Class.new(StandardError)

  def self.parser(source, http_request = nil)
    wsdl   = Resolver.new(source, http_request).xml
    parser = Parser.new(source, http_request)

    nokogiri = Nokogiri::XML::SAX::Parser.new(parser)
    nokogiri.parse(wsdl)

    parser
  end

  def self.interface(source, http_request = nil)
    Interface.new(source, http_request)
  end

  def self.definition(definition)
    Definition.new(definition)
  end

end
