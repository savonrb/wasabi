require "spec_helper"

describe Wasabi::Interpreter do
  context "with: wasmuth.wsdl" do

    subject(:interpreter) { Wasabi.interpreter(wsdl) }

    let(:wsdl)    { "http://www3.mediaservice-wasmuth.de/online-ws-2.0/OnlineSync?wsdl" }
    let(:schema1) { "http://www3.mediaservice-wasmuth.de:80/online-ws-2.0/OnlineSync?xsd=1" }
    let(:schema2) { "http://www3.mediaservice-wasmuth.de:80/online-ws-2.0/OnlineSync?xsd=2" }

    before do
      #mock_requests!  # comment out to test against the real service
    end

    it "knows the SOAP endpoint" do
      endpoint = "http://www3.mediaservice-wasmuth.de:80/online-ws-2.0/OnlineSync"
      expect(interpreter.soap_endpoint).to eq(endpoint)
    end

    it "knows the target namespace" do
      namespace = "http://ws.online.msw/"
      expect(interpreter.target_namespace).to eq(namespace)
    end

    it "knows whether elements should be namespaced" do
      expect(interpreter.element_form_default).to eq(:unqualified)
    end

    it "knows the namespaces" do
      namespace = { "xmlns:tns" => "http://ws.online.msw/"}
      expect(interpreter.namespaces).to include(namespace)
    end

    it "knows the available operations" do
      operation = {
        :get_vermarkter_list => {
          :input       => ["tns", "getVermarkterList"],
          :output      => ["tns", "getVermarkterListResponse"],
          :soap_action => "getVermarkterList"
        }
      }

      expect(interpreter).to have(7).operations
      expect(interpreter.operations).to include(operation)
    end

    def mock_requests!
      wsdl_response    = new_response(:wasmuth)
      schema1_response = new_response(:wasmuth1, :xsd)
      schema2_response = new_response(:wasmuth2, :xsd)

      HTTPI.should_receive(:get) {
        HTTPI.should_receive(:get) {
          HTTPI.should_receive(:get) { schema2_response }
          schema1_response
        }
        wsdl_response
      }
    end

    def new_response(*fixture_name)
      HTTPI::Response.new(200, {}, fixture(*fixture_name).read)
    end

  end
end
