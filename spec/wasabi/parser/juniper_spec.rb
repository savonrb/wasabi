# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Parser do
  context "with: juniper.wsdl" do
    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:juniper).read }

    it "does not blow up when an extension base element is defined in an import" do
      request = subject.operations[:get_system_info_request]

      expect(request[:input]).to eq("GetSystemInfoRequest")
      expect(request[:action]).to eq("urn:#GetSystemInfoRequest")
      expect(request[:namespace_identifier]).to eq("impl")
    end

    it "keeps the historical output fallback for a one-way operation" do
      # LogoutRequest declares an input but no output in its portType. wasabi has
      # always reported the operation name as the output here, so we preserve it
      # rather than changing it to nil in a fault-parsing change.
      logout = subject.operations[:logout_request]

      expect(logout[:output]).to eq("LogoutRequest")
    end
  end
end
