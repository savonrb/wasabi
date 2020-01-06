require 'spec_helper'

describe Wasabi::Document do
  context 'with: encoded_endpoint.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:encoded_endpoint).read }

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { should == URI('http%3A%2F%2Flocalhost%2Fsoapservice%2Fexecute%3Fpath%3D%2Fbase%2Fincludes%2FTest+Soap%2FReturn+Rows') }
    end

  end
end
