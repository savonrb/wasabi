# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: nested_anonymous_types.wsdl" do
    subject { Wasabi::Document.new fixture(:nested_anonymous_types).read }

    it "points an element with an inline complexType at a type named after its path" do
      expect(subject.type_definitions).to include(
        [["CreateOrder", "customer"], "CreateOrder/customer"],
        [["CreateOrder/customer", "address"], "CreateOrder/customer/address"]
      )
    end

    it "does the same inside an extension, and the derived type inherits the base's" do
      expect(subject.type_definitions).to include(
        [["Derived", "note"], "Derived/note"],
        [["Derived", "reference"], "Base/reference"]
      )
      expect(subject.parser.types["http://example.com/orders"]["Derived"][:order!]).to eq(["reference", "note"])
    end

    it "records the schema namespace of the nested elements" do
      expect(subject.type_namespaces).to include(
        [["CreateOrder/customer", "lastName"], "http://example.com/orders"],
        [["CreateOrder/customer/address", "city"], "http://example.com/orders"]
      )
    end

    it "keeps the sequence order of the nested types" do
      types = subject.parser.types["http://example.com/orders"]
      expect(types["CreateOrder"][:order!]).to eq(["customer", "total"])
      expect(types["CreateOrder/customer"][:order!]).to eq(["lastName", "firstName", "address"])
      expect(types["CreateOrder/customer/address"][:order!]).to eq(["street", "city"])
    end
  end
end
