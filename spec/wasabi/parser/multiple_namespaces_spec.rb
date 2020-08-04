# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Parser do
  context "with: multiple_namespaces.wsdl" do

    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:multiple_namespaces).read }

    it "lists the types" do
      expect(subject.types.keys.sort).to eq(["Article", "Save"])
    end

    it "records the namespace for each type" do
      expect(subject.types["Save"][:namespace]).to eq("http://example.com/actions")
    end

    it "records the fields under a type" do
      expect(subject.types["Save"].keys).to match_array(["article", :namespace, :order!])
    end

    it "records multiple fields when there are more than one" do
      expect(subject.types["Article"].keys).to match_array(["Title", "Author", :namespace, :order!])
    end

    it "records the type of a field" do
      expect(subject.types["Save"]["article"][:type]).to eq("article:Article")
      expect(subject.namespaces["article"]).to eq("http://example.com/article")
    end

    it "lists the order of the type elements" do
      expect(subject.types["Article"][:order!]).to eq(["Author", "Title"])
    end

  end
end
