require 'spec_helper'

describe Wasabi::Document do
  context 'with: soap12.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:soap12).read }

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { is_expected.to eq(URI('http%3A%2F%2Fblogsite.example.com%2Fendpoint12')) }
    end
  end
end
