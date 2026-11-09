# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: nested_anonymous_types.wsdl" do
    subject { Wasabi::Document.new fixture(:nested_anonymous_types).read }

    let(:types) { subject.parser.types["http://example.com/orders"] }

    it "describes the elements of an inline complexType inside the element's definition, in sequence order" do
      customer = types["CreateOrder"]["customer"]
      expect(types["CreateOrder"][:order!]).to eq(["customer", "total", "gift"])
      expect(customer[:order!]).to eq(["lastName", "firstName", "address"])
      expect(customer["lastName"]).to eq(type: "xsd:string")
      expect(customer["address"][:order!]).to eq(["street", "city"])
    end

    it "does the same inside an extension, and the derived type inherits the base's" do
      expect(types["Derived"][:order!]).to eq(["reference", "note"])
      expect(types["Derived"]["note"][:order!]).to eq(["text"])
      expect(types["Derived"]["reference"][:order!]).to eq(["code"])
    end

    it "inherits the base's elements in an inline complexType that extends a named type" do
      expect(types["CreateOrder"]["gift"][:order!]).to eq(["reference", "message"])
      expect(subject.type_namespaces).to include(
        [["CreateOrder", "gift", "reference", "code"], "http://example.com/orders"],
        [["CreateOrder", "gift", "message"], "http://example.com/orders"]
      )
    end

    it "stops at the first repetition of inline complexTypes that extend each other's types" do
      expect(subject.type_namespaces).to include(
        [["Author", "book", "title"], "http://example.com/orders"],
        [["Author", "book", "author", "since"], "http://example.com/orders"]
      )
      expect(subject.type_namespaces.map(&:first)).not_to include(["Author", "book", "author", "book", "title"])
    end

    it "records the schema namespace of the nested elements under their full path" do
      expect(subject.type_namespaces).to include(
        [["CreateOrder", "customer", "lastName"], "http://example.com/orders"],
        [["CreateOrder", "customer", "address", "city"], "http://example.com/orders"],
        [["Derived", "note", "text"], "http://example.com/orders"],
        [["Derived", "reference", "code"], "http://example.com/orders"]
      )
    end

    it "gives no type name to an element with an inline complexType" do
      expect(subject.type_definitions).to include([["CreateOrder", "customer"], nil])
      expect(subject.type_definitions.map(&:last)).to all(be_nil)
    end
  end
end
