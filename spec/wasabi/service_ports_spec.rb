# frozen_string_literal: true

require "spec_helper"

describe Wasabi::ServicePorts do
  context "with: multiple_ports.wsdl" do
    subject { Wasabi::ServicePorts.new(document.parser.document) }

    let(:document) { Wasabi::Document.new fixture(:multiple_ports).read }

    it "parses every service port in document order" do
      expect(subject.ports.map { |port| port[:name] })
        .to eq(["SystemService11", "SystemService12", "AdminService11"])
    end

    it "records each port's binding and SOAP version" do
      ports = subject.ports

      expect(ports[0]).to include(binding: "SystemServiceSoap11", soap_version: 1)
      expect(ports[1]).to include(binding: "SystemServiceSoap12", soap_version: 2)
      expect(ports[2]).to include(binding: "AdminServiceSoap11", soap_version: 1)
    end

    describe "#endpoint_for_operation" do
      it "resolves the address of the port serving the operation" do
        expect(subject.endpoint_for_operation(:get_system_info).to_s)
          .to eq("http://example.com/system11")
        expect(subject.endpoint_for_operation(:restart_system).to_s)
          .to eq("http://example.com/admin11")
      end

      it "accepts operation names as strings" do
        expect(subject.endpoint_for_operation("get_system_info").to_s)
          .to eq("http://example.com/system11")
      end

      it "prefers the requested soap_version, falling back to the operation's first SOAP port" do
        expect(subject.endpoint_for_operation(:get_system_info, soap_version: 2).to_s)
          .to eq("http://example.com/system12")
        expect(subject.endpoint_for_operation(:get_system_info, soap_version: 1).to_s)
          .to eq("http://example.com/system11")
        expect(subject.endpoint_for_operation(:restart_system, soap_version: 2).to_s)
          .to eq("http://example.com/admin11")
      end

      it "returns nil for unknown operations" do
        expect(subject.endpoint_for_operation(:no_such_operation)).to be_nil
      end
    end
  end

  context "with: two_bindings.wsdl" do
    subject { Wasabi::ServicePorts.new(document.parser.document) }

    let(:document) { Wasabi::Document.new fixture(:two_bindings).read }

    describe "#endpoint_for_operation" do
      it "returns nil when the WSDL has no service ports" do
        expect(subject.endpoint_for_operation(:post)).to be_nil
      end
    end
  end

  context "with: soap12_only.wsdl" do
    subject { Wasabi::ServicePorts.new(document.parser.document) }

    let(:document) { Wasabi::Document.new fixture(:soap12_only).read }

    it "records non-SOAP ports with a nil soap_version" do
      http_port = subject.ports.find { |port| port[:name] == "SystemServiceHttp" }

      expect(http_port[:soap_version]).to be_nil
    end

    describe "#endpoint_for_operation" do
      it "returns the operation's SOAP 1.2 port when SOAP 1.1 is requested" do
        expect(subject.endpoint_for_operation(:get_system_info, soap_version: 1).to_s)
          .to eq("http://example.com/system12")
      end

      it "never returns a non-SOAP port" do
        expect(subject.endpoint_for_operation(:get_system_info).to_s)
          .to eq("http://example.com/system12")
      end

      it "returns nil when the operation has no SOAP ports" do
        expect(subject.endpoint_for_operation(:http_ping)).to be_nil
      end
    end
  end
end
