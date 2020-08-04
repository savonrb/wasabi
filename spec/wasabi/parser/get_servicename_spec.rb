# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Parser do
  context "with: geotrust.wsdl" do

    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:geotrust).read }

    it "returns the #service_name attribute" do
      expect(subject.service_name).to eq("queryDefinitions")
    end

  end
end
