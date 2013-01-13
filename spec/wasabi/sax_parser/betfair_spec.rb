require "spec_helper"

describe Wasabi::SAX do

  subject(:sax) { new_sax(:betfair).hash }

  def count_elements(element_type)
    sax[:schemas].inject(0) { |count, schema|
      count + schema[element_type].count
    }
  end

  def find_element(element_type, element_name)
    all_elements(element_type)[element_name]
  end

  def all_elements(element_type)
    sax[:schemas].inject({}) { |memo, schema|
      memo.merge schema[element_type]
    }
  end

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
