require "wasabi/version"
require "wasabi/document"
require "wasabi/resolver"

module Wasabi

  NAMESPACES = {
    "wsdl"  => "http://schemas.xmlsoap.org/wsdl/",
    "http"  => "http://schemas.xmlsoap.org/wsdl/http/",
    "soap"  => "http://schemas.xmlsoap.org/wsdl/soap/",
    "soap2" => "http://schemas.xmlsoap.org/wsdl/soap12/"
  }

  # Expects a WSDL document and returns a <tt>Wasabi::Document</tt>.
  def self.document(document)
    Document.new(document)
  end

end
