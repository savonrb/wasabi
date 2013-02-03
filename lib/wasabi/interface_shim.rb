module Wasabi

  # = Wasabi::InterfaceShim
  #
  # Purpose:
  #   Acts like an Interface with a WSDL.
  class InterfaceShim

    def initialize
      @type_definitions = []
      @type_namespaces  = []
    end

    attr_accessor :soap_endpoint, :target_namespace
    attr_reader :type_definitions, :type_namespaces

    def shim?
      true
    end

  end
end
