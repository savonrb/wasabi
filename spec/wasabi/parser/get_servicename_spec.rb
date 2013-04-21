require "spec_helper"

describe Wasabi::Parser do
  context "with: geotrust.wsdl" do

    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:geotrust).read }

    it "does return the servicename attribute" do
      name = subject.servicename

      name.should == "queryDefinitions"
    end

  end
end
