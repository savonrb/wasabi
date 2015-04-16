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
      expect(subject.endpoint).to be_nil
    end

    it "should position base class attributes before subclass attributes in :order! array" do
      type = subject.types["http://model.webservices.partner.example.de"]["ROPtsLiesListe"]
      expect(type[:order!]).to eq(["messages", "returncode", "listenteil"])
    end

  end
end
