require "spec_helper"

describe Wasabi::SAX do

  subject(:sax) { new_sax(:ebay) }

  context "with ebay.wsdl" do
    it "knows the target namespace" do
      expect(sax.target_namespace).to eq("urn:ebay:apis:eBLBaseComponents")
    end
  end

end
