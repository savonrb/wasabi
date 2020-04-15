require 'spec_helper'

describe Wasabi::Document do
  context 'with: encoded_endpoint.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:encoded_endpoint).read }

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { should == URI('http://localhost/soapservice/execute?path=/base/includes/Test%20Soap/Return%20Rows') }
    end

  end
end
