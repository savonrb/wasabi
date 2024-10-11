# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: authentication.wsdl" do

    subject { Wasabi::Document.new fixture(:authentication).read }

    describe '#namespace' do
      subject { super().namespace }
      it { should == "http://v1_0.ws.auth.order.example.com/" }
    end

    describe '#endpoint' do
      subject { super().endpoint }
      it { should == URI("http://example.com/validation/1.0/AuthenticationService") }
    end

    describe '#element_form_default' do
      subject { super().element_form_default }
      it { should == :unqualified }
    end

    it 'has 1 operation' do
      expect(subject.operations.size).to eq(1)
    end

    describe '#operations' do
      subject { super().operations }
      it do
      should == {
        :authenticate => { :name=>"authenticate", :input => "authenticate", :output => "authenticateResponse", :action => "authenticate", :namespace_identifier => "tns" }
      }
    end
    end

  end
end
