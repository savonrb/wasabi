require "spec_helper"

describe Wasabi::Interpreter do
  context "with: soap12.wsdl" do

    subject(:interpreter) { new_interpreter(:soap12) }

    it "knows the SOAP endpoint" do
      endpoint = "http://blogsite.example.com/endpoint12"
      expect(interpreter.soap_endpoint).to eq(endpoint)
    end

  end
end
