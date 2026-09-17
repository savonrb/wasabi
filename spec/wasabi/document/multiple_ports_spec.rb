# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: multiple_ports.wsdl" do
    subject { Wasabi::Document.new fixture(:multiple_ports).read }

    describe "#endpoint" do
      it "keeps the legacy first-port behavior" do
        expect(subject.endpoint.to_s).to eq("http://example.com/system11")
      end
    end

    describe "#endpoint_for_operation" do
      it "resolves the address of the port serving the operation" do
        expect(subject.endpoint_for_operation(:get_system_info).to_s)
          .to eq("http://example.com/system11")
        expect(subject.endpoint_for_operation(:restart_system).to_s)
          .to eq("http://example.com/admin11")
      end

      it "returns nil for unknown operations" do
        expect(subject.endpoint_for_operation(:no_such_operation)).to be_nil
      end
    end
  end
end
