require 'spec_helper'

describe Wasabi::Document do
  context 'with: authentication.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:authentication).read }

    describe '#namespace' do
      subject(:namespace) { document.namespace }

      it { is_expected.to eq('http://v1_0.ws.auth.order.example.com/') }
    end

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { is_expected.to eq URI('http://example.com/validation/1.0/AuthenticationService') }
    end

    describe '#element_form_default' do
      subject(:element_form_default) { document.element_form_default }

      it { is_expected.to eq(:unqualified) }
    end

    describe '#operations' do
      subject(:operations) { document.operations }

      it 'has 1 operation' do
        expect(operations.size).to eq(1)
      end

      it 'has authenticate data'do
        expect(operations).to match(
          a_hash_including(
            :authenticate => {
              :input => 'authenticate',
              :output => 'authenticateResponse',
              :action => 'authenticate',
              :namespace_identifier => 'tns'
            }
          )
        )
      end
    end
  end
end
