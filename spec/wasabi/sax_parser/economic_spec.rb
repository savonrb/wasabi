require "spec_helper"

describe Wasabi::SAX do

  subject(:sax) { new_sax(:economic) }

  context "with economic.wsdl" do
    it "knows the target namespace" do
      expect(sax.target_namespace).to eq("http://e-conomic.com")
    end
  end

end
