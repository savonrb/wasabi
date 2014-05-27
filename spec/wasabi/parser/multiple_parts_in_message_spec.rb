require "spec_helper"

describe Wasabi::Parser do
  context 'with: multiple_parts_in_message.wsdl' do

    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:multiple_parts_in_message).read }

    context "with a parts attribute in soap:body element" do
      it 'uses the part specified in parts attribute' do
        pending("need to determine if these tests are actually valid. QName resolution of operations is complex")

        request = subject.operations[:some_operation][:input]

        expect(request).to eq("SomeRequestBody")
      end
    end

    context "with no parts attribute in soap:body element" do
      it 'uses the first part element in message' do
        pending("need to determine if these tests are actually valid. QName resolution of operations is complex")

        request = subject.operations[:other_operation][:input]

        expect(request).to eq("SomeRequest")
      end
    end

  end
end
