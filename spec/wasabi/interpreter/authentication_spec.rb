require "spec_helper"

describe Wasabi::Interpreter do
  include SAXParserHelper

  subject(:sax)         { Wasabi::SAXParser.new }
  subject(:interpreter) { Wasabi::Interpreter.new(sax) }

  before :all do
    fixture = :authentication
    report_parse_time(fixture) { parse(fixture) }
  end

  it "returns the SOAP endpoint" do
    expected = "http://example.com/validation/1.0/AuthenticationService"
    actual   = interpreter.soap_endpoint

    expect(actual).to eq(expected)
  end

end
