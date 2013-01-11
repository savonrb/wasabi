require "wasabi/version"
require "wasabi/resolver"
require "wasabi/document"
require "wasabi/interpreter"

module Wasabi

  NAMESPACES = {
    "wsdl"  => "http://schemas.xmlsoap.org/wsdl/",
    "http"  => "http://schemas.xmlsoap.org/wsdl/http/",
    "soap"  => "http://schemas.xmlsoap.org/wsdl/soap/",
    "soap2" => "http://schemas.xmlsoap.org/wsdl/soap12/",
    "xs"    => "http://www.w3.org/2001/XMLSchema"
  }

  NAMESPACES_BY_URI = NAMESPACES.invert

  def self.sax(wsdl)
    sax    = SAX.new
    parser = Nokogiri::XML::SAX::Parser.new(sax)

    parser.parse(wsdl)
    sax
  end

  def self.interpreter(wsdl, http_request = nil)
    Interpreter.new(wsdl, http_request)
  end

end
