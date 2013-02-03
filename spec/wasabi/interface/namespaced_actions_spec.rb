require "spec_helper"

describe Wasabi::Interface do
  context "with: namespaced_actions.wsdl" do

    subject(:interface) { new_interface(:namespaced_actions) }

    it "knows the SOAP endpoint" do
      endpoint = "https://api.example.com/api/api.asmx"
      expect(interface.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "http://api.example.com/api/"
      expect(interface.target_namespace).to eq(namespace)
    end

    it "knows whether elements should be namespaced" do
      pending "elementFormDefault belongs to a schema. needs to be refactored!"
      expect(interface.element_form_default).to eq(:qualified)
    end

    it "knows the available operations" do
      expect(interface).to have(3).operations

      operation = {
        :delete_client => {
          :input       => ["tns", "Client.Delete"],
          :output      => ["tns", "Client.DeleteResponse"],
          :soap_action => "http://api.example.com/api/Client.Delete"
        }
      }

      expect(interface.operations).to include(operation)
    end

  end
end
