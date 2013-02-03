require "spec_helper"

describe "Elements" do
  context "with: interhome.wsdl" do

    subject(:interpreter) { new_interface(:interhome) }

    it "maps elements with only an extension" do
      element = interpreter.type_map["NewsletterReturnValue"]
      expect(element).to eq(:extension => "ReturnValue")
    end

    it "maps elements with an extension and a sequence" do
      element = interpreter.type_map["PaymentInformationReturnValue"]

      expect(element[:extension]).to eq("ReturnValue")
      expect(element[:sequence]).to eq([
        { "minOccurs" => "1", "maxOccurs" => "1", "name" => "CreditCardType",   "type" => "tns:CCType" },
        { "minOccurs" => "0", "maxOccurs" => "1", "name" => "CreditCardNumber", "type" => "s:string" },
        { "minOccurs" => "0", "maxOccurs" => "1", "name" => "CreditCardExpiry", "type" => "s:string" }
      ])
    end

    it "maps empty elements" do
      element = interpreter.type_map["CheckServerHealth"]
      expect(element[:empty]).to be_true
    end

    context "map test" do

      let(:operation_name) { "PriceDetail" }

      it "works" do
        element = map ["inputValue"]
        expect(element).to eq(
          "minOccurs" => "0",
          "maxOccurs" => "1",
          "name"      => "inputValue",
          "type"      => "tns:PriceDetailInputValue"
        )

        element = map ["inputValue", "AccommodationCode"]
        expect(element).to eq(
          "minOccurs" => "0",
          "maxOccurs" => "1",
          "name"      => "AccommodationCode",
          "type"      => "s:string"
        )

        element = map ["inputValue", "AdditionalServices"]
        expect(element).to eq(
          "minOccurs" => "0",
          "maxOccurs" => "1",
          "name"      => "AdditionalServices",
          "type"      => "tns:ArrayOfAdditionalServiceInputItem"
        )

        element = map ["inputValue", "AdditionalServices", "AdditionalServiceInputItem"]
        expect(element).to eq(
          "minOccurs" => "0",
          "maxOccurs" => "unbounded",
          "name"      => "AdditionalServiceInputItem",
          "nillable"  => "true",
          "type"      => "tns:AdditionalServiceInputItem"
        )
        element = map ["inputValue", "AdditionalServices", "AdditionalServiceInputItem", "Code"]
        expect(element).to eq(
          "minOccurs" => "0",
          "maxOccurs" => "1",
          "name"      => "Code",
          "type"      => "s:string"
        )
        element = map ["inputValue", "CheckIn"]
        expect(element).to eq(
          "minOccurs" => "0",
          "maxOccurs" => "1",
          "name"      => "CheckIn",
          "type"      => "s:string"
        )
      end

      def map(search_path)
        expected = {}

        operation     = interpreter.operations[operation_name.snakecase.to_sym]
        input_name    = operation[:input].last
        input_element = interpreter.type_map[input_name]

        map!(expected, input_element)

        expected[search_path]
      end

      def map!(memo, element, path = [])
        element[:sequence].each do |child|
          new_path       = path + [child["name"]]
          memo[new_path] = child

          local, nsid = child["type"].split(":").reverse
          namespace   = interpreter.namespaces["xmlns:#{nsid}"]

          # custom namespace, custom element?!
          unless Wasabi::NAMESPACES_BY_URI[namespace] == "xs"
            child_element = interpreter.type_map[local]
            map!(memo, child_element, new_path)
          else
            # do something
          end
        end
      end

    end

  end
end
