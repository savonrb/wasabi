require "spec_helper"

describe Wasabi::Interface do
  context "with: responsys.wsdl" do

    subject(:interface) { Wasabi.interface(wsdl) }

    let(:wsdl)   { "https://ws5.responsys.net/webservices/wsdl/ResponsysWS_Level1.wsdl" }
    let(:types)  { "https://ws5.responsys.net/webservices/services/ResponsysWSService/_resources_/xsd/ResponsysWSTypes_Schema.xsd" }
    let(:faults) { "https://ws5.responsys.net/webservices/services/ResponsysWSService/_resources_/xsd/ResponsysWSFaults_Schema.xsd" }

    it "resolves xs imports" do
      mock_requests!  # comment out to test against the real service

      expect(interface).to have(172).types

      # element from the schema file
      expect(interface.types.keys.sort).to include("AccountFault")

      # element from the faults file
      expect(interface.types.keys.sort).to include("LoginResult")
    end

    def mock_requests!
      wsdl_response   = new_response(:responsys)
      schema_response = new_response(:responsys_schema, :xsd)
      faults_response = new_response(:responsys_faults, :xsd)

      HTTPI.should_receive(:get) {
        HTTPI.should_receive(:get) {
          HTTPI.should_receive(:get) { faults_response }
          schema_response
        }
        wsdl_response
      }
    end

    def new_response(*fixture_name)
      HTTPI::Response.new(200, {}, fixture(*fixture_name).read)
    end

  end
end
