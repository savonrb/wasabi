# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: geotrust.wsdl" do

    let(:document) { Wasabi::Document.new(fixture(:geotrust).read) }

    describe '#namespace' do
      subject { document.namespace }
      it { should eq "http://api.geotrust.com/webtrust/query" }
    end

    describe '#endpoint' do
      subject { document.endpoint }
      it { should eq URI("https://test-api.geotrust.com:443/webtrust/query.jws") }
    end

    describe '#element_form_default' do
      subject { document.element_form_default }
      it { should be :qualified }
    end

    it 'has 2 operations' do
      expect(document.operations.size).to eq(2)
    end

    describe '#operations' do
      subject { document.operations }
      it do
        should include(
          {
            get_quick_approver_list: {
              input: "GetQuickApproverList",
              output: "GetQuickApproverList",
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
