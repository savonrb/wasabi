require "spec_helper"

describe Wasabi::Interpreter do
  context "with: responsys.wsdl" do

    subject(:interpreter) { Wasabi.interpreter(wsdl) }

    let(:wsdl) { "https://ws5.responsys.net/webservices/wsdl/responsys.wsdl" }

    it "resolves xsd imports" do
      mock_request wsdl, :responsys
      mock_request File.join(wsdl, "../services/ResponsysWSService/_resources_/xsd/responsys_schema.xsd"), :responsys_schema, :xsd
      mock_request File.join(wsdl, "../services/ResponsysWSService/_resources_/xsd/responsys_faults.xsd"), :responsys_faults, :xsd

      expect(interpreter).to have(172).types

      # element from responsys_schema.xsd
      expect(interpreter.types.keys.sort).to include("AccountFault")

      # element from responsys_faults.xsd
      expect(interpreter.types.keys.sort).to include("LoginResult")
    end

    def mock_request(source, *fixture_name)
      response = HTTPI::Response.new(200, {}, fixture(*fixture_name).read)

      HTTPI.should_receive(:get) { |request|
        expect(request.url).to eq(URI(source))
      }.once.and_return(response)
    end

  end
end
