require "spec_helper"

describe "Elements" do
  context "with: betfair.wsdl" do

    subject(:interpreter) { new_interpreter(:betfair) }

    it "maps array elements" do
      element = interpreter.type_map["ArrayOfUpdateBets"]
      expect(element).to eq(:sequence => [
        { "form"      => "qualified",
          "maxOccurs" => "unbounded",
          "minOccurs" => "0",
          "name"      => "UpdateBets",
          "nillable"  => "true",
          "type"      => "types:UpdateBets"
        }
      ])
    end

    it "maps simple types" do
      element = interpreter.type_map["PlaceBetsErrorEnum"]

      expect(element[:restriction][:base]).to eq("xsd:string")
      expect(element[:restriction][:enumeration]).to include("OK", "API_ERROR")
    end

  end
end
