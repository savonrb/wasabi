require "spec_helper"

describe Wasabi::Interface do
  context "with: authentication.wsdl" do

    subject(:interpreter) { new_interface(:authentication) }

    it "knows the SOAP endpoint" do
      endpoint = "http://example.com/validation/1.0/AuthenticationService"
      expect(interpreter.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "http://v1_0.ws.auth.order.example.com/"
      expect(interpreter.target_namespace).to eq(namespace)
    end

    it "knows whether elements should be namespaced" do
      pending "elementFormDefault belongs to a schema. needs to be refactored!"
      expect(interpreter.element_form_default).to eq(:unqualified)
    end

    it "knows the available operations" do
      operations = {
        :authenticate => {
          :input       => ["tns", "authenticate"],
          :output      => ["tns", "authenticateResponse"],
          :soap_action => ""
        }
      }

      expect(interpreter.operations).to eq(operations)
    end

  end
end
