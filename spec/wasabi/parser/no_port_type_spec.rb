require "spec_helper"

describe Wasabi::Parser do
  context "with: no_port_type.wsdl" do
    
    subject { Wasabi::Document.new fixture(:no_port_type).read }

    its(:operations) { should == { :save => { :action=>"http://example.com/actions.Save", :input => "Save", :namespace_identifier => nil } } }

  end
end