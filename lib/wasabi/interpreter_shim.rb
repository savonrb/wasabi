module Wasabi

  # = Wasabi::InterpreterShim
  #
  # Purpose:
  #   Acts as an Interpreter with a WSDL.
  class InterpreterShim

    def initialize
      @type_definitions     = []
      @type_namespaces      = []
      @element_form_default = :unqualified
    end

    attr_accessor :soap_endpoint, :target_namespace, :element_form_default
    attr_reader :type_definitions, :type_namespaces

    def shim?
      true
    end

  end
end
