require 'spec_helper'

describe Wasabi::Parser do
  context 'with: no_message_parts.wsdl' do

    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:no_message_parts).read }

    it 'falls back to using the message type in the port element' do
      # Operation's input has no part element in the message, so using the message type.
      subject.operations[:save][:input].should == 'Save'

      # Operation's output has part element in the message, so using part element's type.
      subject.operations[:save][:output].should == 'SaveResponse'
    end

    it 'falls back to using the namespace ID in the port element' do
      subject.operations[:save][:namespace_identifier].should == 'actions'
    end

    it 'gracefully handles port messages without a colon' do
      subject.operations[:delete][:input].should == 'Delete'
      subject.operations[:delete][:output].should == 'DeleteResponse'
      subject.operations[:delete][:namespace_identifier].should be_nil
    end
  end
end
