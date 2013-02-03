require "spec_helper"

describe Wasabi::Interface do
  context "with: no_namespace.wsdl" do

    subject(:interpreter) { new_interface(:no_namespace) }

    it "knows the SOAP endpoint" do
      endpoint = "http://example.com/api/api"
      expect(interpreter.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "urn:ActionWebService"
      expect(interpreter.target_namespace).to eq(namespace)
    end

    it "knows whether elements should be namespaced" do
      pending "elementFormDefault belongs to a schema. needs to be refactored!"
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

    it "knows the types" do
      types = ["McContact", "McContactArray", "MpUser", "MpUserArray"]
      expect(interpreter.types.keys.sort).to eq(types)
    end

    it "ignores xsd:all" do
      expect(interpreter.types["MpUser"].keys).to eq([:namespace])
    end

  end
end
