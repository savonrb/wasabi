# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: rpc_operation.wsdl" do
    subject { Wasabi::Document.new(fixture(:rpc_operation).read) }

    describe "#operations" do
      subject { super().operations }

      it do
        should include(
          {
            example_operation: {
              action: "urn:ExampleInterface-ExamplePortType#ExampleOperation",
              input: "ExampleOperation",
              output: "ExampleOperation",
              namespace_identifier: "tns"
            }
          }
        )
      end
    end
  end
end
