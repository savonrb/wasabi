require "spec_helper"

describe Wasabi::Interface do
  context "with: betfair.wsdl" do

    subject(:interface) { Wasabi.interface(wsdl) }

    let(:wsdl) { "https://api.betfair.com/exchange/v5/BFExchangeService.wsdl" }

    before do
      mock_requests!  # comment out to test against the real service
    end

    it "knows the SOAP endpoint" do
      endpoint = "https://api.betfair.com/exchange/v5/BFExchangeService"
      expect(interface.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "http://www.betfair.com/publicapi/v5/BFExchangeService/"
      expect(interface.target_namespace).to eq(namespace)
    end

    it "knows the namespaces" do
      namespace = { "xmlns:tns" => "http://www.betfair.com/publicapi/v5/BFExchangeService/"}
      expect(interface.namespaces).to include(namespace)
    end

    it "knows the available operations" do
      operation = {
        :cancel_bets => {
          :input       => ["tns", "cancelBets"],
          :output      => ["tns", "cancelBetsResponse"],
          :soap_action => "cancelBets"
        }
      }

      expect(interface).to have(30).operations
      expect(interface.operations).to include(operation)
    end

    def mock_requests!
      wsdl_response = new_response(:betfair)
      HTTPI.should_receive(:get) { wsdl_response }
    end

    def new_response(*fixture_name)
      HTTPI::Response.new(200, {}, fixture(*fixture_name).read)
    end

  end
end
