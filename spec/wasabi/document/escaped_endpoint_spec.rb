
require "spec_helper"

describe Wasabi::Document do
  context "with: escaped_endpoint.wsdl" do

    subject(:document) { Wasabi::Document.new fixture(:escaped_endpoint).read }

    describe '#endpoint' do
      it "supports spaces in URIs" do
        expect(document.endpoint).to eq URI("http://localhost/soap%20service")
      end
    end

  end
end
