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

  def self.sax(source, http_request = nil)
    wsdl   = Resolver.new(source, http_request).xml
    sax    = SAX.new(source, http_request)
    parser = Nokogiri::XML::SAX::Parser.new(sax)

    parser.parse(wsdl)
    sax
  end

  def self.definition(sax)
    Definition.new(sax)
  end

  def self.interface(source, http_request = nil)
    Interface.new(source, http_request)
  end

end
