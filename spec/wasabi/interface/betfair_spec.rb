require "spec_helper"

describe Wasabi::Interface do
  context "with: betfair.wsdl" do

    subject(:interpreter) { Wasabi.interface(wsdl) }

    let(:wsdl) { "https://api.betfair.com/exchange/v5/BFExchangeService.wsdl" }

    before do
      mock_requests!  # comment out to test against the real service
    end

    it "knows the SOAP endpoint" do
      endpoint = "https://api.betfair.com/exchange/v5/BFExchangeService"
      expect(interpreter.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "http://www.betfair.com/publicapi/v5/BFExchangeService/"
      expect(interpreter.target_namespace).to eq(namespace)
    end

    it "knows whether elements should be namespaced" do
      pending "elementFormDefault belongs to a schema. needs to be refactored!"
      expect(interpreter.element_form_default).to eq(:unqualified)
    end

    it "knows the namespaces" do
      namespace = { "xmlns:tns" => "http://www.betfair.com/publicapi/v5/BFExchangeService/"}
      expect(interpreter.namespaces).to include(namespace)
    end

    it "knows the available operations" do
      operation = {
        :cancel_bets => {
          :input       => ["tns", "cancelBets"],
          :output      => ["tns", "cancelBetsResponse"],
          :soap_action => "cancelBets"
        }
      }

      expect(interpreter).to have(30).operations
      expect(interpreter.operations).to include(operation)
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
