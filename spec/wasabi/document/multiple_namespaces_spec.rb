require "spec_helper"

describe Wasabi::Document do
  context "with: multiple_namespaces.wsdl" do

    subject { Wasabi::Document.new fixture(:multiple_namespaces).read }

    describe '#namespace' do
      subject { super().namespace }
      it { is_expected.to eq "http://example.com/actions" }
    end

    describe '#endpoint' do
      subject { super().endpoint }
      it { is_expected.to eq URI("http://example.com:1234/soap") }
    end

    describe '#element_form_default' do
      subject { super().element_form_default }
      it { is_expected.to eq :qualified }
    end

    it 'has 1 operation' do
      expect(subject.operations.size).to eq(1)
    end

    describe '#operations' do
      subject { super().operations }
      it do
        is_expected.to match({ :save => { :input => "Save", :output=>"SaveResponse", :action => "http://example.com/actions.Save", :namespace_identifier => "actions", :parameters => { :article => { :name => "article", :type => "Article" } } } })
      end
    end

    describe '#type_namespaces' do
      subject { super().type_namespaces }
      it do
        is_expected.to match([
          [["Save"], "http://example.com/actions"],
          [["Save", "article"], "http://example.com/actions"],
          [["Article"], "http://example.com/article"],
          [["Article", "Author"], "http://example.com/article"],
          [["Article", "Title"], "http://example.com/article"]
        ])
      end
    end

    describe '#type_definitions' do
      subject { super().type_definitions }
      it do
        is_expected.to match([ [["Save", "article"], "Article"] ])
      end
    end

  end
end
