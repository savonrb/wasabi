# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: geotrust.wsdl" do

    subject { Wasabi::Document.new fixture(:geotrust).read }

    describe '#namespace' do
      subject { super().namespace }
      it { should == "http://api.geotrust.com/webtrust/query" }
    end

    describe '#endpoint' do
      subject { super().endpoint }
      it { should == URI("https://test-api.geotrust.com:443/webtrust/query.jws") }
    end

    describe '#element_form_default' do
      subject { super().element_form_default }
      it { should == :qualified }
    end

    it 'has 2 operations' do
      expect(subject.operations.size).to eq(2)
    end

    describe '#operations' do
      subject { super().operations }
      it do
        should include(
          {
            get_quick_approver_list: {
              input: "GetQuickApproverList",
              output: "GetQuickApproverListResponse",
              action: "GetQuickApproverList",
              namespace_identifier: "s1",
              parameters: {
                Request: {
                  name: "Request",
                  type: "GetQuickApproverListInput"
                }
              }
            }
          },
          {
            hello: {
              input: "hello",
              output: "helloResponse",
              action: "hello",
              namespace_identifier: "s1",
              parameters: {
                Input: {
                  name: "Input",
                  type: "string"
                }
              }
            }
          }
        )
      end
    end

  end
end
