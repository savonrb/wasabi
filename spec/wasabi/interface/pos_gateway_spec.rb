require "spec_helper"

describe Wasabi::Interface do
  context "with: pos_gateway.wsdl" do

    subject(:interface) { Wasabi.interface(wsdl) }

    let(:wsdl)   { "https://posgateway.cert.secureexchange.net/Hps.Exchange.PosGateway.UAT/PosGatewayService.asmx?wsdl" }
    let(:wsdl2)  { "https://posgateway.cert.secureexchange.net/Hps.Exchange.PosGateway.UAT/PosGatewayService.asmx?wsdl=wsdl" }
    let(:schema) { "https://posgateway.cert.secureexchange.net/Hps.Exchange.PosGateway.UAT/PosGatewayService.asmx?schema=schema1" }

    it "resolves wsdl imports" do
      mock_requests!  # doesn't work with without mocking, because the service
                      # does not seem to be available from all around the world

      expect(interface).to have(1).operations
    end

    it "resolves xs imports" do
      mock_requests!  # doesn't work with without mocking, because the service
                      # does not seem to be available from all around the world

      expect(interface).to have(142).types

      # element from the schema file
      expect(interface.types.keys.sort).to include("CredentialDataType")
    end

    def mock_requests!
      wsdl_response   = new_response(:pos_gateway)
      wsdl2_response  = new_response(:pos_gateway2)
      schema_response = new_response(:pos_gateway, :xsd)

      HTTPI.should_receive(:get) {
        HTTPI.should_receive(:get) { wsdl2_response }
        HTTPI.should_receive(:get) { schema_response }
        wsdl_response
      }
    end

    def new_response(*fixture_name)
      HTTPI::Response.new(200, {}, fixture(*fixture_name).read)
    end

  end
end
