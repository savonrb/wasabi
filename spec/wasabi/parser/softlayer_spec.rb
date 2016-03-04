require 'spec_helper'

describe Wasabi::Parser do
  context 'with: brand.wsdl' do
    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:brand).read }

    it 'parses the operations' do
      expect(subject.operations[:create_object][:input]).to eq('createObject' => { 'templateObject' => ['tns', 'SoftLayer_Brand'] })
      expect(subject.operations[:create_customer_account][:input]).to eq('createCustomerAccount' => {'account' => ['tns', 'SoftLayer_Account'], 'bypassDuplicateAccountCheck' => ['xsd', 'boolean']})
    end
  end
end
