require "spec_helper"

describe Wasabi::Interface do
  context "with: inherited.xml" do

    subject(:interface) { new_interface(:inherited) }

    it "knows the type definitions" do
      definitions = interface.type_definitions

      expect(definitions).to include([["Account", "Id"], "ID"])
      expect(definitions).to include([["Account", "ProcessId"], "ID"])
      expect(definitions).to include([["Account", "CreatedDate"], "dateTime"])
      expect(definitions).to include([["Account", "Description"], "string"])
      expect(definitions).to include([["Account", "fieldsToNull"], "string"])
    end

  end
end

