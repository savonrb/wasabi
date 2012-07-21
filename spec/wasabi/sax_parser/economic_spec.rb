require "spec_helper"

describe Wasabi::SAXParser do

  subject(:sax) { Wasabi::SAXParser.new }

  context "with economic.wsdl" do
    before do
      # 1.45 sec
      st = Time.now
      parse(:economic)
      et = Time.now
      puts "time: #{et - st}"
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
