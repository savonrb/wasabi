require "spec_helper"

describe Wasabi::Interface do
  context "with: multiple_namespaces.wsdl" do

    subject(:interface) { new_interface(:multiple_namespaces) }

    it "knows the available types" do
      expect(interface).to have(2).types
      expect(interface.types).to include("Article", "Save")
    end

    it "knows the type namespaces from multiple schemas" do
      expect(interface.types["Article"]).to include(:namespace => "http://example.com/article")
      expect(interface.types["Save"]).to include(:namespace => "http://example.com/actions")
    end

    it "knows the types children" do
      expect(interface.types["Save"]).to include("article")
    end

    it "knows about multiple children" do
      expect(interface.types["Article"]).to include("Title", "Author")
    end

    it "knows the children's types" do
      expect(interface.types["Save"]["article"][:type]).to eq("article:Article")
      expect(interface.namespaces["xmlns:article"]).to eq("http://example.com/article")
    end

    it "knows the type namespaces" do
      expect(interface.type_namespaces).to include(
        [["Save"], "http://example.com/actions"],
        [["Save", "article"], "http://example.com/actions"],
        [["Article"], "http://example.com/article"],
        [["Article", "Author"], "http://example.com/article"],
        [["Article", "Title"], "http://example.com/article"]
      )
    end

    it "knows the type definitions" do
      expect(interface.type_definitions).to eq([
        [["Save", "article"], "Article"]
      ])
    end

  end
end
