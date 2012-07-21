require "spec_helper"

describe Wasabi::Matcher do

  let(:stack) { [] }

  it "matches a single node" do
    stack << "wsdl:definitions"
    matcher("wsdl:definitions").should === stack
  end

  it "does not match a single different node" do
    stack << "wsdl:service"
    matcher("wsdl:definitions").should_not === stack
  end

  it "matches multiple nodes" do
    stack << "wsdl:definitions" << "wsdl:service"
    matcher("wsdl:definitions > wsdl:service").should === stack
  end

  it "does not match a different stack" do
    stack << "wsdl:definitions" << "wsdl:service"
    matcher("wsdl:definitions > wsdl:binding").should_not === stack
  end

  it "works for multiple namespaces" do
    stack << "wsdl:definitions" << "wsdl:service" << "wsdl:port" << "soap:address"

    matcher = matcher("wsdl:definitions > wsdl:service > wsdl:port > soap|soap2|http:address")
    matcher.should === stack

    stack.pop
    stack << "http:address"
    matcher.should === stack

    stack.pop
    stack << "wsdl:address"
    matcher.should_not === stack
  end

  it "works with a wildcard" do
    stack << "wsdl:definitions" << "wsdl:types" << "xs:schema" << "xs:complexType"

    matcher = matcher("wsdl:definitions > wsdl:types > xs:schema > xs:complexType > *")
    matcher.should_not === stack

    stack << "xs:sequence"
    matcher.should === stack

    stack << "xs:element"
    matcher.should === stack
  end

  def matcher(matcher)
    Wasabi::Matcher.create(matcher)
  end

end
