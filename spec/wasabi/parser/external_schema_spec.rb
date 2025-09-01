# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Parser do
  context "external schemas" do
    let(:wsdl_path) { File.expand_path("../../fixtures/wsdl_with_external_schemas.xml", __dir__) }
    
    describe 'loading WSDL with external schemas' do
      context "when loading from file path" do
        subject { Wasabi::Document.new(wsdl_path) }
        
        it "loads types from included XSD files" do
          # AddressType is loaded via xs:include
          address_type = subject.type_definition("AddressType")
          expect(address_type).to be_a(Hash)
          expect(address_type[:fields]).to have_key("street")
          expect(address_type[:fields]).to have_key("city")
        end
        
        it "loads types from imported XSD files" do
          # UserType is loaded via xs:import
          user_type = subject.type_definition("UserType")
          expect(user_type).to be_a(Hash)
          expect(user_type[:fields]).to have_key("username")
          expect(user_type[:fields]).to have_key("email")
        end
        
        it "resolves types used in operations" do
          # The create_user operation uses both external types
          input_type = subject.operation_input_type(:create_user)
          expect(input_type).to be_a(Hash)
          expect(input_type[:name]).to eq("CreateUserRequest")
        end
      end
      
      
      context "when loading from string without document option" do
        subject { Wasabi::Document.new(File.read(wsdl_path)) }
        
        it "cannot load external schemas without base path" do
          # Without a base path, external schemas can't be resolved
          address_type = subject.type_definition("AddressType")
          expect(address_type).to be_nil
        end
      end
    end
  end
end