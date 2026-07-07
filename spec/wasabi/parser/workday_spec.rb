# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Parser do
  context "with: workday.wsdl" do
    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:workday).read }

    it "parses the operations" do
      expect(subject.operations[:get_customer_invoices][:input]).to eq("Get_Customer_Invoices_Request")
    end

    it "returns faults" do
      expect(subject.operations[:get_customer_invoices][:fault]).to eq(["Validation_Fault", "Processing_Fault"])
    end
  end
end
