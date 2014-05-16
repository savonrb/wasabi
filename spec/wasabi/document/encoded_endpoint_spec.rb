require "spec_helper"

describe Wasabi::Document do
  context "with: encoded_endpoint.wsdl" do

    subject { Wasabi::Document.new fixture(:encoded_endpoint).read }

    describe '#endpoint' do
      subject { super().endpoint }
      it { should == URI("http://localhost/soapservice/execute?path=/base/includes/Test+Soap/Return+Rows") }
    end

  end
end
