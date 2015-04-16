# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Parser do
  context "with: symbolic_endpoint.wsdl" do
    subject(:parser) { described_class.new Nokogiri::XML(xml) }

    let(:xml) { fixture(:symbolic_endpoint).read }

    before { parser.parse }

    it "allows symbolic endpoints" do
      expect(parser.endpoint).to be_nil
    end

    it "should position base class attributes before subclass attributes in :order! array" do
      type = subject.types["http://model.webservices.partner.example.de"]["ROPtsLiesListe"]
      expect(type[:order!]).to eq(["messages", "returncode", "listenteil"])
    end

  end
end
