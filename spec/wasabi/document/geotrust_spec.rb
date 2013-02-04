require "spec_helper"

describe Wasabi::Document do
  context "with: geotrust.wsdl" do

    subject { Wasabi::Document.new fixture(:geotrust).read }

    its(:namespace) { should == "http://api.geotrust.com/webtrust/query" }

    its(:endpoint) { should == URI("https://test-api.geotrust.com:443/webtrust/query.jws") }

    its(:element_form_default) { should == :qualified }

    it { should have(2).operations }

    its(:operations) do
      should include(
        { :get_quick_approver_list => { :input => "GetQuickApproverList", :action => "GetQuickApproverList", :parameters=>{:Request=>{:name=>"Request", :type=>"GetQuickApproverListInput"}}}},
        { :hello => { :input => "hello", :action => "hello", :parameters=>{:Input=>{:name=>"Input", :type=>"string"}} } }
      )
    end

  end
end
