require "spec_helper"

describe Wasabi::Document do
  context "with: savon295.wsdl" do

    subject { Wasabi::Document.new fixture(:savon295).read }

    describe '#operations' do
      subject { super().operations }
      it do
      should include(
        { :sendsms => { :input=>{"sendsms"=>{"sender"=>["xsd", "string"], "cellular"=>["xsd", "string"], "msg"=>["xsd", "string"], "smsnumgroup"=>["xsd", "string"], "emailaddr"=>["xsd", "string"], "udh"=>["xsd", "string"], "datetime"=>["xsd", "string"], "format"=>["xsd", "string"], "dlrurl"=>["xsd", "string"]}}, :output=>{"sendsms"=>{"body"=>["xsd", "string"]}}, :action => "sendsms", :namespace_identifier => 'tns' } }
      )
    end
    end

  end
end
