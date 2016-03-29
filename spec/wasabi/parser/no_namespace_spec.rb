require "spec_helper"

describe Wasabi::Parser do
  context "with: no_namespace.wsdl" do

    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:no_namespace).read }

    it "lists the types" do
      expect(subject.types['urn:ActionWebService'].keys.sort).to eq(["McContact", "McContactArray", "MpUser", "MpUserArray"])
    end

    it "ignores xsd:all" do
      keys =  subject.types['urn:ActionWebService']["MpUser"].keys
      expect(keys.size).to eq(2)

      expect(keys).to include(:namespace)
      expect(keys).to include(:order!)
    end
  end
end
