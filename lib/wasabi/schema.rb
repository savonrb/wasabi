module Wasabi

  # = Wasabi::Schema
  #
  # Purpose:
  #   Represents an XS schema.
  class Schema

    def initialize(schema)
      @namespace              = schema["targetNamespace"]
      @element_form_default   = schema["elementFormDefault"]   || "unqualified"
      @attribute_form_default = schema["attributeFormDefault"] || "unqualified"

      @elements      ||= {}
      @complex_types ||= {}
    end

    attr_reader :namespace, :element_form_default, :attribute_form_default,
                :elements, :complex_types

  end
end