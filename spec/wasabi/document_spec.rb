# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  subject { Wasabi::Document.new fixture(:authentication).read }

  it "accepts a URL" do
    path = "http://example.com?wsdl"
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get(path) do
      [200, {"Content-Type": "application/xml"}, "wsdl"]
    end

    document = Wasabi::Document.new(path, [:test, stubs])
    expect(document.xml).to eq("wsdl")
  end

  it "accepts a path" do
    document = Wasabi::Document.new fixture(:authentication).path
    expect(document.xml).to eq(fixture(:authentication).read)
  end

  it "accepts raw XML" do
    document = Wasabi::Document.new fixture(:authentication).read
    expect(document.xml).to eq(fixture(:authentication).read)
  end

  [
    "<!DOCTYPE html><html><body>Example Domain</body></html>",
    "<!doctype html><html><body>Example Domain</body></html>",
    ""
  ].each do |body|
    it "raises a readable error when a URL returns #{body.inspect} instead of a WSDL" do
      path = "http://example.com?wsdl"
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(path) do
        [200, {"Content-Type": "text/html"}, body]
      end

      document = Wasabi::Document.new(path, [:test, stubs])
      expect { document.soap_actions }
        .to raise_error(ArgumentError, "Wasabi needs a WSDL document, got: #{body[0, 100].inspect}")
    end
  end

  describe ".validate_element_form_default!" do
    [:unqualified, :qualified].each do |value|
      it "does not raise for :#{value}" do
        expect { Wasabi::Document.validate_element_form_default!(value) }.to_not raise_error
      end
    end

    it "raises if given an invalid value" do
      error_msg = "Invalid value for elementFormDefault: invalid\n" \
        "Must be one of: [:unqualified, :qualified]"

      expect { Wasabi::Document.validate_element_form_default!(:invalid) }
        .to raise_error(ArgumentError, error_msg)
    end
  end

  describe "#element_form_default" do
    it "defaults to :unqualified" do
      expect(subject.element_form_default).to eq(:unqualified)
    end

    [:unqualified, :qualified].each do |value|
      it "accepts :#{value}" do
        subject.element_form_default = value
        expect(subject.element_form_default).to eq(value)
      end
    end

    it "raises if set to an invalid value" do
      expect { subject.element_form_default = :invalid }
        .to raise_error(ArgumentError, /Invalid value for elementFormDefault/)
    end
  end
end
