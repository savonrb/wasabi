# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: soap12.wsdl" do

    subject { Wasabi::Document.new fixture(:soap12).read }

    describe '#endpoint' do
      subject { super().endpoint }
      it { should == URI("http://blogsite.example.com/endpoint12") }
    end

  end
end
