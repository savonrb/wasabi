require "spec_helper"

describe Wasabi::Parser do

  subject(:parser) { new_parser(:economic) }

  context "with economic.wsdl" do
    it "knows the target namespace" do
      expect(parser.target_namespace).to eq("http://e-conomic.com")
    end
  end

end
