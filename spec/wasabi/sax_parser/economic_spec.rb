require "spec_helper"

describe Wasabi::SAXParser, :fixture => :economic do
  include SAXParserHelper

  subject(:sax) { Wasabi::SAXParser.new }

  context "with #{metadata[:fixture]}.wsdl" do
    before do
      fixture = self.class.metadata[:fixture]
      report_parse_time(fixture) { parse(fixture) }  # 1.45 sec
    end

    it "knows the target namespace" do
      expect(sax.target_namespace).to eq("http://e-conomic.com")
    end
  end

  def parse(fixture_name)
    parser = Nokogiri::XML::SAX::Parser.new(sax)
    parser.parse fixture(fixture_name).read
  end

end
