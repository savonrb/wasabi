# frozen_string_literal: true

require 'spec_helper'

describe Wasabi::Parser do
  context 'with: tradetracker.wsdl' do
    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:tradetracker).read }

    it 'parses the operations' do
      expect(subject.operations[:get_feeds][:input]).to eq("GetFeedsMessage")
    end
  end
end
