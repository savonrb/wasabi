require "spec_helper"

describe Wasabi::Interpreter do
  context "with: responsys.wsdl" do

    subject(:interpreter) { Wasabi.interpreter(wsdl) }

    let(:wsdl)   { "https://ws5.responsys.net/webservices/wsdl/ResponsysWS_Level1.wsdl" }
    let(:types)  { "https://ws5.responsys.net/webservices/services/ResponsysWSService/_resources_/xsd/ResponsysWSTypes_Schema.xsd" }
    let(:faults) { "https://ws5.responsys.net/webservices/services/ResponsysWSService/_resources_/xsd/ResponsysWSFaults_Schema.xsd" }

    it "resolves xsd imports" do
      mock_requests!  # comment out to test against the real service

      expect(interpreter).to have(172).types

      # element from the schema file
      expect(interpreter.types.keys.sort).to include("AccountFault")

      # element from the faults file
      expect(interpreter.types.keys.sort).to include("LoginResult")
    end

    def mock_requests!
      faults_response = new_response(:responsys_faults, :xsd)
      schema_response = new_response(:responsys_schema, :xsd)
      wsdl_response   = new_response(:responsys)

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
