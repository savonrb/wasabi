require 'spec_helper'

describe Wasabi::Document do
  context 'with: geotrust.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:geotrust).read }

    describe '#namespace' do
      subject(:namespace) { document.namespace }

      it { is_expected.to eq('http://api.geotrust.com/webtrust/query') }
    end

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { is_expected.to eq(URI('https://test-api.geotrust.com/webtrust/query.jws')) }
    end

    describe '#element_form_default' do
      subject(:element_form_default) { document.element_form_default }

      it { is_expected.to eq(:qualified) }
    end

    describe '#operations' do
      subject(:operations) { document.operations }

      it 'has 2 operations' do
        expect(operations.size).to eq(2)
      end

      it 'has both operations parameters description' do
        expect(operations).to match(
          a_hash_including(
            :get_quick_approver_list => {
              :input => 'GetQuickApproverList',
              :action => 'GetQuickApproverList',
              :parameters => {
                :Request => {
                  :name => 'Request',
                  :type => 'GetQuickApproverListInput'
                }
              }
            }
          )
        )

        expect(operations).to match(
          a_hash_including(
            :hello => {
              :input => 'hello',
              :action => 'hello',
              :parameters => {
                :Input => {
                  :name => 'Input',
                  :type => 'string'
                }
              }
            }
          )
        )
      end
    end
  end
end
