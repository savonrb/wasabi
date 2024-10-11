# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "with: no_namespace.wsdl" do

    subject { Wasabi::Document.new fixture(:no_namespace).read }

    describe '#namespace' do
      subject { super().namespace }
      it { should == "urn:ActionWebService" }
    end

    describe '#endpoint' do
      subject { super().endpoint }
      it { should == URI("http://example.com/api/api") }
    end

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
          {
            get_user_login_by_id: {
              name: "GetUserLoginById",
              input: "GetUserLoginById",
              output: "GetUserLoginByIdResponse",
              action: "/api/api/GetUserLoginById",
              namespace_identifier: "typens"
            }
          },
          {
            get_all_contacts: {
              name: "GetAllContacts",
              input: "GetAllContacts",
              output: "GetAllContactsResponse",
              action: "/api/api/GetAllContacts",
              namespace_identifier: "typens"
            }
          },
          {
            search_user: {
              name: "SearchUser",
              input: "SearchUser",
              output: "SearchUserResponse",
              action: "/api/api/SearchUser",
              namespace_identifier: nil
            }
          }
        )
      end
    end

  end
end
