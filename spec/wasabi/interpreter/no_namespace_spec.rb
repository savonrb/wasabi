require "spec_helper"

describe Wasabi::Interpreter do
  context "with: no_namespace.wsdl" do

    subject(:interpreter) { new_interpreter(:no_namespace) }

    it "knows the SOAP endpoint" do
      endpoint = "http://example.com/api/api"
      expect(interpreter.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "urn:ActionWebService"
      expect(interpreter.target_namespace).to eq(namespace)
    end

    it "knows whether elements should be namespaced" do
      expect(interpreter.element_form_default).to eq(:unqualified)
    end

    it "knows the available operations" do
      expect(interpreter).to have(3).operations

      operation = {
        :get_user_login_by_id => {
          :input       => ["typens", "GetUserLoginById"],
          :output      => ["typens", "GetUserLoginByIdResponse"],
          :soap_action => "/api/api/GetUserLoginById"
        }
      }

      expect(interpreter.operations).to include(operation)
    end

  end
end
