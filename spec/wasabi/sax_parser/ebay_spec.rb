require "spec_helper"

describe Wasabi::SAXParser, :fixture => :ebay do
  include SAXParserHelper

  subject(:sax) { Wasabi::SAXParser.new }

  context "with #{metadata[:fixture]}.wsdl" do
    before do
      fixture = self.class.metadata[:fixture]
      report_parse_time(fixture) { parse(fixture) }  # 1.56 sec
    end

    it "knows the target namespace" do
      expect(sax.target_namespace).to eq("urn:ebay:apis:eBLBaseComponents")
    end
  end

end
