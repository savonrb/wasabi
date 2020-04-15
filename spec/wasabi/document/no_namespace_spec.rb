require 'spec_helper'

describe Wasabi::Document do
  context 'with: no_namespace.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:no_namespace).read }

    describe '#namespace' do
      subject(:namespace) { document.namespace }

      it { is_expected.to eq('urn:ActionWebService') }
    end

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { is_expected.to eq(URI('http://example.com/api/api')) }
    end

    describe '#element_form_default' do
      subject(:element_form_default) { document.element_form_default }

      it { is_expected.to eq(:unqualified) }
    end

    describe '#operations' do
      subject(:operations) { document.operations }

    it 'has 3 operations' do
      expect(operations.size).to eq(3)
    end

      it 'has the operations instruction' do
        expect(operations).to match(
          a_hash_including(
            :get_user_login_by_id => {
              :input => { 'GetUserLoginById' => { 'api_key' => ['xsd', 'string'], 'id' => ['xsd', 'int'] }},
              :output=>{'GetUserLoginById'=>{'return'=>['xsd', 'string']}},
              :action => '/api/api/GetUserLoginById',
              :namespace_identifier => 'typens'
            }
          )
        )

        expect(operations).to match(
          a_hash_including(
            :get_all_contacts => {
              :input => {'GetAllContacts' => { 'api_key' => ['xsd', 'string'], 'login'=>['xsd', 'string'] }},
              :output=>{'GetAllContacts'=>{'return'=>['typens', 'McContactArray']}},
              :action => '/api/api/GetAllContacts',
              :namespace_identifier => 'typens'
            }
          )
        )

        expect(operations).to match(
          a_hash_including(
            :search_user => {
              :input => {
                'SearchUser' => {
                  'api_key' => ['xsd', 'string'],
                  'phrase'=>['xsd', 'string'],
                  'page'=>['xsd', 'string'],
                  'per_page'=>['xsd', 'string']
                }
              },
              :output=>{'SearchUser'=>{'return'=>['typens', 'MpUserArray']}},
              :action => '/api/api/SearchUser',
              :namespace_identifier => nil
            }
          )
        )
      end
    end
  end
end
