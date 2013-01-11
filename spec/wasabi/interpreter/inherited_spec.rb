require "spec_helper"

describe Wasabi::Interpreter do
  context "with: inherited.xml" do

    subject(:interpreter) { new_interpreter(:inherited) }

    it "knows the type definitions" do
      definitions = interpreter.type_definitions

      expect(definitions).to include([["Account", "Id"], "ID"])
      expect(definitions).to include([["Account", "ProcessId"], "ID"])
      expect(definitions).to include([["Account", "CreatedDate"], "dateTime"])
      expect(definitions).to include([["Account", "Description"], "string"])
      expect(definitions).to include([["Account", "fieldsToNull"], "string"])
    end

  end
end

