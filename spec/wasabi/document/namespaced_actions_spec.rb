# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: namespaced_actions.wsdl" do

    subject { Wasabi::Document.new fixture(:namespaced_actions).read }

    describe '#namespace' do
      subject { super().namespace }
      it { should == "http://api.example.com/api/" }
    end

    describe '#endpoint' do
      subject { super().endpoint }
      it { should == URI("https://api.example.com/api/api.asmx") }
    end

    describe '#element_form_default' do
      subject { super().element_form_default }
      it { should == :qualified }
    end

    it 'has 3 operations' do
      expect(subject.operations.size).to eq(3)
    end

    describe '#operations' do
      subject { super().operations }
      it do
        should include(
          {
            delete_client: {
              name: "DeleteClient",
              input: "Client.Delete",
              output: "Client.DeleteResponse",
              action: "http://api.example.com/api/Client.Delete",
              namespace_identifier: "tns"
            }
          },
          {
            get_clients: {
              name: "GetClients",
              input: "User.GetClients",
              output: "User.GetClientsResponse",
              action: "http://api.example.com/api/User.GetClients",
              namespace_identifier: "tns"
            }
          },
          {
            get_api_key: {
              name: "GetApiKey",
              input: "User.GetApiKey",
              output: "User.GetApiKeyResponse",
              action: "http://api.example.com/api/User.GetApiKey",
              namespace_identifier: "tns"
            }
          }
        )
      end
    end

  end
end
