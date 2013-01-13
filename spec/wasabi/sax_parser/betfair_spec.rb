require "spec_helper"

describe Wasabi::SAX do
  include SpecSupport::SAX

  subject(:sax) { new_sax(:betfair).hash }

  context "with betfair.wsdl" do
    it "knows the simple types" do
      count = count_elements(:simple_types)
      expect(count).to eq(40)

      element = find_element(:simple_types, "PlaceBetsErrorEnum")
      expect(element[:restriction][:base]).to eq("xsd:string")
      expect(element[:restriction][:enumeration]).to include("OK", "API_ERROR")
    end

  end
end
