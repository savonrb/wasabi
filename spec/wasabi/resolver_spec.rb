require "spec_helper"

describe Wasabi::Resolver do

  describe "#resolve" do
    it "resolves remote documents" do
      HTTPI.should_receive(:get) { HTTPI::Response.new(200, {}, "wsdl") }
      xml = Wasabi::Resolver.new("http://example.com?wsdl").resolve
      xml.should == "wsdl"
    end

    it "resolves remote documents with custom adapter" do
      prev_logging = HTTPI.instance_variable_get(:@log)
      HTTPI.log = false # Don't pollute rspec output by request logging
      xml = Wasabi::Resolver.new("http://example.com?wsdl", nil, :fake_adapter_for_test).resolve
      xml.should == "wsdl_by_adapter"
      expect(FakeAdapterForTest.class_variable_get(:@@requests).size).to eq(1)
      expect(FakeAdapterForTest.class_variable_get(:@@requests).first.url).to eq(URI.parse("http://example.com?wsdl"))
      expect(FakeAdapterForTest.class_variable_get(:@@methods)).to eq([:get])
      HTTPI.log = prev_logging
    end

    it "resolves local documents" do
      xml = Wasabi::Resolver.new(fixture(:authentication).path).resolve
      xml.should == fixture(:authentication).read
    end

    it "simply returns raw XML" do
      xml = Wasabi::Resolver.new("<xml/>").resolve
      xml.should == "<xml/>"
    end

    it "raises HTTPError when #load_from_remote gets a response error" do
      code = 404
      headers = {
        "content-type" => "text/html"
      }
      body = "<html><head><title>404 Not Found</title></head><body>Oops!</body></html>"
      failed_response = HTTPI::Response.new(code, headers, body)
      HTTPI.stub(:get => failed_response)
      lambda do
        Wasabi::Resolver.new("http://example.com?wsdl").resolve
      end.should raise_error { |ex|
        ex.should be_a(Wasabi::Resolver::HTTPError)
        ex.message.should == "Error: #{code}"
        ex.response.should == failed_response
      }
    end
  end

end
