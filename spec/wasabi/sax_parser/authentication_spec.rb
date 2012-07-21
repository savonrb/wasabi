require "spec_helper"

describe Wasabi::SAXParser, :fixture => :authentication do
  include SAXParserHelper

  subject(:sax) { Wasabi::SAXParser.new }

  context "with #{metadata[:fixture]}.wsdl" do
    before :all do
      fixture = self.class.metadata[:fixture]
      report_parse_time(fixture) { parse(fixture) }  # 0.0016 sec
    end

    it "knows the target namespace" do
      expect(sax.target_namespace).to eq("http://v1_0.ws.auth.order.example.com/")
    end

    it "knows the elementFormDefault value" do
      expect(sax.element_form_default).to eq("unqualified")
    end

    it "knows the attributeFormDefault value" do
      expect(sax.attribute_form_default).to eq("unqualified")
    end
  end

end
