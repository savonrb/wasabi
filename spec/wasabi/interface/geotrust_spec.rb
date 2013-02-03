require "spec_helper"

describe Wasabi::Interface do
  context "with: geotrust.wsdl" do

    subject(:interface) { new_interface(:geotrust) }

    it "knows the SOAP endpoint" do
      endpoint = "https://test-api.geotrust.com:443/webtrust/query.jws"
      expect(interface.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "http://api.geotrust.com/webtrust/query"
      expect(interface.target_namespace).to eq(namespace)
    end

    it "knows the available operations" do
      operation = {
        :get_quick_approver_list => {
          :input       => ["s1", "GetQuickApproverList"],
          :output      => ["s1", "GetQuickApproverListResponse"],
          :soap_action => ""
        }
      }

      expect(interface).to have(2).operations
      expect(interface.operations).to include(operation)
    end

  end
end
