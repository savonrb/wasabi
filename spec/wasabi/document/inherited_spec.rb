require "spec_helper"

describe Wasabi::Document do
  context "with: inherited.xml" do

    subject { Wasabi::Document.new fixture(:inherited).read }

    its(:type_definitions) do
      should include([["Account", "Id"], "ID"])
      should include([["Account", "ProcessId"], "ID"])
      should include([["Account", "CreatedDate"], "dateTime"])
      should include([["Account", "Description"], "string"])
      should include([["Account", "fieldsToNull"], "string"])
    end

    it "should position base class attributes before subclass attributes in :order! array" do
      account = subject.parser.types["Account"]
      account[:order!].should == ["fieldsToNull", "Id", "Description", "ProcessId", "CreatedDate"]
    end

    it "should have each type's hash remember it's base type in :base_type element" do
      account = subject.parser.types["Account"]
      account[:base_type].should == "baseObject"

      base_object = subject.parser.types["baseObject"]
      base_object.should_not have_key(:base_type)
    end

    it "should have element's hash contain all these attributes (:nillable, :minOccurs, :maxOccurs) in addition to :type" do
      base_object = subject.parser.types["baseObject"]
      fields_to_null = base_object["fieldsToNull"]
      fields_to_null[:nillable].should == "true"
      fields_to_null[:minOccurs].should == "0"
      fields_to_null[:maxOccurs].should == "unbounded"
    end
  end
end

