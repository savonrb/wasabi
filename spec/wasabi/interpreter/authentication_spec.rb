require "spec_helper"

describe Wasabi::Interpreter do

  subject(:interpreter) { new_interpreter(:authentication) }

  it "returns the SOAP endpoint" do
    expected = "http://example.com/validation/1.0/AuthenticationService"
    actual   = interpreter.soap_endpoint

    expect(actual).to eq(expected)
  end

end
