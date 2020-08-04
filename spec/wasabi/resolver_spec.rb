# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Resolver do

  describe "#resolve" do
    it "resolves remote documents" do
      expect(HTTPI).to receive(:get) { HTTPI::Response.new(200, {}, "wsdl") }
      xml = Wasabi::Resolver.new("http://example.com?wsdl").resolve
      expect(xml).to eq("wsdl")
    end

    it "resolves remote documents with custom adapter" do
      prev_logging = HTTPI.instance_variable_get(:@log)
      HTTPI.log = false # Don't pollute rspec output by request logging
      xml = Wasabi::Resolver.new("http://example.com?wsdl", nil, :fake_adapter_for_test).resolve
      expect(xml).to eq("wsdl_by_adapter")
      expect(FakeAdapterForTest.class_variable_get(:@@requests).size).to eq(1)
      expect(FakeAdapterForTest.class_variable_get(:@@requests).first.url).to eq(URI.parse("http://example.com?wsdl"))
      expect(FakeAdapterForTest.class_variable_get(:@@methods)).to eq([:get])
      HTTPI.log = prev_logging
    end

    it "resolves local documents" do
      xml = Wasabi::Resolver.new(fixture(:authentication).path).resolve
      expect(xml).to eq(fixture(:authentication).read)
    end

    it "simply returns raw XML" do
      xml = Wasabi::Resolver.new("<xml/>").resolve
      expect(xml).to eq("<xml/>")
    end

    it "raises HTTPError when #load_from_remote gets a response error" do
      code = 404
      headers = {
        "content-type" => "text/html"
      }
      body = "<html><head><title>404 Not Found</title></head><body>Oops!</body></html>"
      failed_response = HTTPI::Response.new(code, headers, body)

      expect(HTTPI).to receive(:get) { failed_response }

      url = "http://example.com?wsdl"

      expect do
        Wasabi::Resolver.new(url).resolve
      end.to raise_error { |ex|
        expect(ex).to be_a(Wasabi::Resolver::HTTPError)
        expect(ex.message).to eq("Error: #{code} for url #{url}")
        expect(ex.response).to eq(failed_response)
      }
    end
  end

end
