require "spec_helper"

describe Wasabi::Interface do
  context "with: interhome.wsdl" do

    subject(:interpreter) { new_interface(:interhome) }

    it "knows the available operations" do
      operations = {
        :price_detail => {
        :input       => ["tns", "PriceDetail"],
        :output      => ["tns", "PriceDetailResponse"],
        :soap_action => "http://www.interhome.com/webservice/PriceDetail"
        }
      }

      expect(interpreter.operations).to include(operations)
    end

  end
end
