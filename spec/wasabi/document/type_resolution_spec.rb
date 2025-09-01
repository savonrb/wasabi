# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "type resolution" do
    describe 'qualified type names' do
      let(:wsdl) do
        %Q{<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://schemas.xmlsoap.org/wsdl/"
  xmlns:s="http://www.w3.org/2001/XMLSchema"
  xmlns:ns1="http://example.com/ns1"
  xmlns:ns2="http://example.com/ns2"
  targetNamespace="http://example.com/test">
  <types>
    <s:schema elementFormDefault="qualified" targetNamespace="http://example.com/ns1">
      <s:complexType name="Address">
        <s:sequence>
          <s:element name="street" type="s:string"/>
        </s:sequence>
      </s:complexType>
    </s:schema>
    <s:schema elementFormDefault="qualified" targetNamespace="http://example.com/ns2">
      <s:complexType name="Address">
        <s:sequence>
          <s:element name="country" type="s:string"/>
        </s:sequence>
      </s:complexType>
    </s:schema>
  </types>
</definitions>}
      end

      subject { Wasabi::Document.new wsdl }

      it "resolves same-named types in different namespaces" do
        ns1_type = subject.type_definition("ns1:Address")
        ns2_type = subject.type_definition("ns2:Address")
        
        expect(ns1_type[:fields]).to have_key("street")
        expect(ns2_type[:fields]).to have_key("country")
      end
    end

    describe 'Type suffix pattern' do
      let(:wsdl) do
        %Q{<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://schemas.xmlsoap.org/wsdl/"
  xmlns:s="http://www.w3.org/2001/XMLSchema"
  targetNamespace="http://example.com/test">
  <types>
    <s:schema elementFormDefault="qualified" targetNamespace="http://example.com/test">
      <s:complexType name="UserType">
        <s:sequence>
          <s:element name="username" type="s:string"/>
        </s:sequence>
      </s:complexType>
    </s:schema>
  </types>
</definitions>}
      end

      subject { Wasabi::Document.new wsdl }

      it "finds UserType when looking for User" do
        user_type = subject.type_definition("User")
        expect(user_type[:fields]).to have_key("username")
      end
    end
  end
end