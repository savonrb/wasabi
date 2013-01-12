require "spec_helper"

describe Wasabi::Interpreter do
  context "with: pos_gateway.wsdl" do

    subject(:interpreter) { Wasabi.interpreter(wsdl) }

    let(:wsdl)   { "https://posgateway.cert.secureexchange.net/Hps.Exchange.PosGateway.UAT/PosGatewayService.asmx?wsdl" }
    let(:schema) { "https://posgateway.cert.secureexchange.net/Hps.Exchange.PosGateway.UAT/PosGatewayService.asmx?schema=schema1" }

    it "resolves xsd imports" do
      mock_requests!  # doesn't work with without mocking, because the service
                      # does not seem to be available from all around the world

      expect(interpreter).to have(142).types

      # element from the schema file
      expect(interpreter.types.keys.sort).to include("CredentialDataType")
    end

    def mock_requests!
      schema_response = new_response(:pos_gateway, :xsd)
      wsdl_response   = new_response(:pos_gateway)

      HTTPI.should_receive(:get) {
        HTTPI.should_receive(:get) { schema_response }
        wsdl_response
      }
    end

    def new_response(*fixture_name)
      HTTPI::Response.new(200, {}, fixture(*fixture_name).read)
    end

  end
end
