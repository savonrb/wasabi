require "spec_helper"

describe Wasabi::Parser do

  subject(:parser) { new_parser(:ebay) }

  context "with ebay.wsdl" do
    it "knows the target namespace" do
      expect(parser.target_namespace).to eq("urn:ebay:apis:eBLBaseComponents")
    end
  end

end
