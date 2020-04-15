require 'spec_helper'

describe Wasabi::Document do
  context 'with: soap12.wsdl' do
    let(:document) { Wasabi::Document.new fixture(:soap12).read }

    describe '#endpoint' do
      subject(:endpoint) { document.endpoint }

      it { is_expected.to eq(URI('http://blogsite.example.com/endpoint12')) }
    end
  end
end
