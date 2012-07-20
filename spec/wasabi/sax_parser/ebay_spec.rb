require "spec_helper"

describe Wasabi::SAXParser do

  subject(:sax) { Wasabi::SAXParser.new }

  context "with ebay.wsdl" do
    before do
      st = Time.now
      parse(:ebay)
      et = Time.now
      puts "time: #{et - st}"
    end

    it "knows the target namespace" do
      expect(sax.target_namespace).to eq("urn:ebay:apis:eBLBaseComponents")
    end
  end

  def parse(fixture_name)
    parser = Nokogiri::XML::SAX::Parser.new(sax)
    parser.parse fixture(fixture_name).read
  end

end
