# frozen_string_literal: true

require "wasabi/version"
require "wasabi/document"
require "wasabi/resolver"
require "wasabi/service_ports"

module Wasabi
  # Expects a WSDL document and returns a <tt>Wasabi::Document</tt>.
  def self.document(document)
    Document.new(document)
  end
end
