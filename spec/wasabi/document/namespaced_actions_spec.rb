require 'spec_helper'

describe Wasabi::Document do
  context 'with: namespaced_actions.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:namespaced_actions).read }

    describe '#namespace' do
      subject(:namespace) { document.namespace }

      it { is_expected.to eq('http://api.example.com/api/') }
    end

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { is_expected.to eq(URI('https%3A%2F%2Fapi.example.com%2Fapi%2Fapi.asmx')) }
    end

    describe '#element_form_default' do
      subject(:element_form_default) { document.element_form_default }
      it { is_expected.to eq(:qualified) }
    end

    describe '#operations' do
      subject(:operations) { document.operations }

      it 'has 3 operations' do
        expect(operations.size).to eq(3)
      end

      it 'has the operations instruction' do
        expect(operations).to match(
          a_hash_including(
            :delete_client => {
              :input => 'Client.Delete',
              :output => 'Client.DeleteResponse',
              :action => 'http://api.example.com/api/Client.Delete',
              :namespace_identifier => 'tns'
            }
          )
        )

        expect(operations).to match(
          a_hash_including(
            :get_clients   => {
              :input => 'User.GetClients',
              :output => 'User.GetClientsResponse',
              :action => 'http://api.example.com/api/User.GetClients',
              :namespace_identifier => 'tns'
            }
          )
        )

        expect(operations).to match(
          a_hash_including(
            :get_api_key   => {
              :input => 'User.GetApiKey',
              :output => 'User.GetApiKeyResponse',
              :action => 'http://api.example.com/api/User.GetApiKey',
              :namespace_identifier => 'tns'
            }
          )
        )
      end
    end
  end
end
