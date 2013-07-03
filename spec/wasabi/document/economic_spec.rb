require 'spec_helper'

describe Wasabi::Document do
  context 'with: economic.wsdl' do

    subject { Wasabi::Document.new fixture(:economic).read }

    it 'has an ok parse-time for huge wsdl files' do
      expect(subject.operations.count).to eq(1511)
    end

  end
end
