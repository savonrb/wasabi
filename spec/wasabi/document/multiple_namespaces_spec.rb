require 'spec_helper'

describe Wasabi::Document do
  context 'with: multiple_namespaces.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:multiple_namespaces).read }

    describe '#namespace' do
      subject(:namespace) { document.namespace }

      it { is_expected.to eq('http://example.com/actions') }
    end

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { is_expected.to eq(URI('http://example.com:1234/soap')) }
    end

    describe '#element_form_default' do
      subject(:element_form_default) { document.element_form_default }

      it { is_expected.to eq(:qualified) }
    end

    describe '#operations' do
      subject(:operations) { document.operations }

      it 'has 1 operation' do
        expect(operations.size).to eq(1)
      end

      it 'has the  operation data' do
        expect(operations).to match(
          a_hash_including(
            :save => {
              :input => 'Save',
              :output=>'SaveResponse',
              :action => 'http://example.com/actions.Save',
              :namespace_identifier => 'actions',
              :parameters => {
                :article => {
                  :name => 'article',
                  :type => 'Article'
                }
              }
            }
          )
        )
      end
    end

    describe '#type_namespaces' do
      subject(:type_namespaces) { document.type_namespaces }

      it 'has the type namespaces'do
        expect(type_namespaces).to match(
          [
            [['Save'], 'http://example.com/actions'],
            [['Save', 'article'], 'http://example.com/actions'],
            [['Article'], 'http://example.com/article'],
            [['Article', 'Author'], 'http://example.com/article'],
            [['Article', 'Title'], 'http://example.com/article']
          ]
        )
      end
    end

    describe '#type_definitions' do
      subject(:type_definitions) { document.type_definitions }

      it 'has the type definitions' do
        expect(type_definitions).to match([ [['Save', 'article'], 'Article'] ])
      end
    end
  end
end
