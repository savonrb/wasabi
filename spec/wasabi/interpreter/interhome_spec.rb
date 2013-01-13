require "spec_helper"

describe Wasabi::Interpreter do
  context "with: interhome.wsdl" do

    subject(:interpreter) { new_interpreter(:interhome) }

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

    it "maps elements with only an extension" do
      element = interpreter.type_map["NewsletterReturnValue"]
      expect(element).to eq(:extension => "ReturnValue")
    end

    it "maps elements with an extension and a sequence" do
      element = interpreter.type_map["PaymentInformationReturnValue"]

      expect(element[:extension]).to eq("ReturnValue")
      expect(element[:sequence]).to eq([
        { "minOccurs" => "1", "maxOccurs" => "1", "name" => "CreditCardType", "type" => "tns:CCType" },
        { "minOccurs" => "0", "maxOccurs" => "1", "name" => "CreditCardNumber", "type" => "s:string" },
        { "minOccurs" => "0", "maxOccurs" => "1", "name" => "CreditCardExpiry", "type" => "s:string" }
      ])
    end

    it "maps empty elements" do
      element = interpreter.type_map["CheckServerHealth"]
      expect(element[:empty]).to be_true
    end

  end
end
