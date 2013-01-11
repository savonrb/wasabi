require "spec_helper"

describe Wasabi::Interpreter do
  context "with: no_message_parts.wsdl" do

    subject(:interpreter) { new_interpreter(:no_message_parts) }

    it "falls back to using the information from the port element" do
      expect(interpreter.operations[:save]).to eq(
        :input       => ["actions", "Save"],
        :output      => ["actions", "SaveResponse"],
        :soap_action => "http://example.com/actions.Save"
      )
    end

  end
end
