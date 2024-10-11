# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Resolver do

  describe "#resolve" do
    # TODO: remove_after_httpi
    context "HTTPI" do
      it "resolves remote documents" do
        expect(HTTPI).to receive(:get) { HTTPI::Response.new(200, {}, "wsdl") }
        xml = Wasabi::Resolver.new("http://example.com?wsdl", HTTPI::Request.new).resolve
        expect(xml).to eq("wsdl")
      end
    end

    it "resolves remote documents" do
      expect(Faraday::Connection).to receive(:new).and_return(
        connection = instance_double(Faraday::Connection, get: Responses.mock_faraday(200, {}, "wsdl"))
      )
      xml = Wasabi::Resolver.new("http://example.com?wsdl").resolve
      expect(xml).to eq("wsdl")
    end

    it "resolves remote documents with custom adapter" do
      path = 'http://example.com?wsdl'
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(path) do
        [200, {'Content-Type': 'application/xml'}, 'wsdl']
      end
      xml = Wasabi::Resolver.new("http://example.com?wsdl", nil, [:test, stubs]).resolve
      expect(xml).to eq("wsdl")
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
      failed_response = Responses.mock_faraday(code, headers, body)
      expect(Faraday::Connection).to receive(:new).and_return(
        connection = instance_double(Faraday::Connection, get: failed_response)
      )
      url = "http://example.com?wsdl"

      expect do
        Wasabi::Resolver.new(url).resolve
      end.to(raise_error{ |ex|
        expect(ex).to be_a(Wasabi::Resolver::HTTPError)
        expect(ex.message).to eq("Error: #{code} for url #{url}")
        expect(ex.response).to eq(failed_response)
      })
    end
  end

end
