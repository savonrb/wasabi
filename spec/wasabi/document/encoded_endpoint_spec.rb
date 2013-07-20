require "spec_helper"

describe Wasabi::Document do
  context "with: encoded_endpoint.wsdl" do

    subject { Wasabi::Document.new fixture(:encoded_endpoint).read }

    its(:endpoint) { should == URI("http://localhost/soapservice/execute?path=/base/includes/Test+Soap/Return+Rows") }

  end
end
