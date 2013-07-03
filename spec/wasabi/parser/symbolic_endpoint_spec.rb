require "spec_helper"

describe Wasabi::Parser do
  context "with: symbolic_endpoint.wsdl" do

    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:symbolic_endpoint).read }

    it "allows symbolic endpoints" do
      subject.endpoint.should be_nil
    end

    it "should position base class attributes before subclass attributes in :order! array" do
      type = subject.types["ROPtsLiesListe"]
      type[:order!].should == ["messages", "returncode", "listenteil"]
    end

  end
end
