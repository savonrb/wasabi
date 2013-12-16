require 'spec_helper'

describe Wasabi::Parser do
  context 'with: marketo.wsdl' do
    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:marketo).read }

    it 'parses the operations' do
      subject.operations[:get_lead][:input].should == 'paramsGetLead'
    end
  end
end
