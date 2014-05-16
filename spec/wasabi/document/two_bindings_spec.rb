require "spec_helper"

describe Wasabi::Document do
  context "with: two_bindings.wsdl" do

    subject { Wasabi::Document.new fixture(:two_bindings).read }

    describe '#element_form_default' do
      subject { super().element_form_default }
      it { should == :unqualified }
    end

    it 'has 3 operations' do
      expect(subject.operations.size).to eq(3)
    end

    describe '#operations' do
      subject { super().operations }
      it do
      should include(
        { :post => { :input => "Post", :action => "Post" } },
        { :post11only => { :input => "Post11only", :action => "Post11only" } },
        { :post12only => { :input => "Post12only", :action => "Post12only" } }
      )
    end
    end

  end
end
