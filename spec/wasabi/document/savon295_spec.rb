# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: savon295.wsdl" do

    subject { Wasabi::Document.new fixture(:savon295).read }

    describe '#operations' do
      subject { super().operations }
      it do
      should include(
          {
            sendsms: {
              input: "sendsms",
              output: "sendsmsResponse",
              action: "sendsms",
              namespace_identifier: "tns"
            }
          }
      )
    end
    end

  end
end
