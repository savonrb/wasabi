require "spec_helper"

describe Wasabi::Interpreter do
  context "with: namespaced_actions.wsdl" do

    subject(:interpreter) { new_interpreter(:namespaced_actions) }

    it "knows the SOAP endpoint" do
      endpoint = "https://api.example.com/api/api.asmx"
      expect(interpreter.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "http://api.example.com/api/"
      expect(interpreter.target_namespace).to eq(namespace)
    end

    it "knows whether elements should be namespaced" do
      pending "elementFormDefault belongs to a schema. needs to be refactored!"
      expect(interpreter.element_form_default).to eq(:qualified)
    end

    it "knows the available operations" do
      expect(interpreter).to have(3).operations

      operation = {
        :delete_client => {
          :input       => ["tns", "Client.Delete"],
          :output      => ["tns", "Client.DeleteResponse"],
          :soap_action => "http://api.example.com/api/Client.Delete"
        }
      }

      expect(interpreter.operations).to include(operation)
    end

  end
end
