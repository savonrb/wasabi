require "spec_helper"

describe Wasabi::Document do
  context "with: inherited.xml" do

    subject { Wasabi::Document.new fixture(:inherited).read }

    describe '#type_definitions' do
      subject { super().type_definitions }
      it do
      should include([["Account", "Id"], "ID"])
      should include([["Account", "ProcessId"], "ID"])
      should include([["Account", "CreatedDate"], "dateTime"])
      should include([["Account", "Description"], "string"])
      should include([["Account", "fieldsToNull"], "string"])
    end
    end

    it "should position base class attributes before subclass attributes in :order! array" do
      account = subject.parser.types['http://object.api.example.com/']["Account"]
      expect(account[:order!]).to eq(["fieldsToNull", "Id", "Description", "ProcessId", "CreatedDate"])
    end

    it "should have each type's hash remember it's base type in :base_type element" do
      account = subject.parser.types['http://object.api.example.com/']["Account"]
      expect(account[:base_type]).to eq("baseObject")

      base_object = subject.parser.types['http://object.api.example.com/']["baseObject"]
      expect(base_object).not_to have_key(:base_type)
    end

    it "should have element's hash contain all these attributes (:nillable, :minOccurs, :maxOccurs) in addition to :type" do
      base_object = subject.parser.types['http://object.api.example.com/']["baseObject"]
      fields_to_null = base_object["fieldsToNull"]
      expect(fields_to_null[:nillable]).to eq("true")
      expect(fields_to_null[:minOccurs]).to eq("0")
      expect(fields_to_null[:maxOccurs]).to eq("unbounded")
    end
  end
end

