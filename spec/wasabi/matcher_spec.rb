require "spec_helper"

describe Wasabi::Matcher do

  let(:stack) { [] }

  context "with a stack containing a single node" do
    it "matches the node" do
      stack.push("wsdl:definitions")
      matcher("wsdl:definitions").should === stack
    end

    it "does not match a different node" do
      stack.push("wsdl:service")
      matcher("wsdl:definitions").should_not === stack
    end
  end

  context "with a stack containing more than one node" do
    it "matches the nodes" do
      stack.push("wsdl:definitions")
      stack.push("wsdl:service")
      matcher("wsdl:definitions > wsdl:service").should === stack
    end

    it "does not match different nodes" do
      stack.push("wsdl:definitions")
      stack.push("wsdl:service")
      matcher("wsdl:definitions > wsdl:binding").should_not === stack
    end
  end

  context "with multiple namespaces" do
    it "matches the nodes" do
      stack.push("wsdl:definitions")
      stack.push("wsdl:service")
      stack.push("wsdl:port")
      stack.push("soap:address")

      matcher("wsdl:definitions > wsdl:service > wsdl:port > soap|soap2|http:address").should === stack
    end
  end

  def matcher(matcher)
    Wasabi::Matcher.new(matcher)
  end

end
