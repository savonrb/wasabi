require "spec_helper"

describe Wasabi::Matcher do

  let(:stack) { [] }

  context "with a stack containing a single node" do
    it "matches the node" do
      stack.push node("wsdl", "definitions")
      matcher("wsdl:definitions").should === stack
    end

    it "does not match a different node" do
      stack.push node("soap", "address")
      matcher("wsdl:definitions").should_not === stack
    end
  end

  context "with a stack containing more than one node" do
    it "matches the last node" do
      stack.push node("wsdl", "definitions")
      stack.push node("wsdl", "services")
      matcher("wsdl:services").should === stack
    end

    it "does not match a different node" do
      stack.push node("wsdl", "definitions")
      stack.push node("wsdl", "services")
      matcher("wsdl:services").should === stack
    end

    it "matches a node and its direct parent" do
      stack.push node("wsdl", "definitions")
      stack.push node("wsdl", "services")
      matcher("wsdl:definitions > wsdl:services").should === stack
    end

    it "does not match a node and its direct parent" do
      stack.push node("wsdl", "definitions")
      stack.push node("wsdl", "services")
      matcher("wsdl:definitions > wsdl:binding").should_not === stack
    end
  end

  def node(nsid, locale)
    Wasabi::Node.new(Wasabi::NAMESPACES[nsid], locale)
  end

  def matcher(matcher)
    Wasabi::Matcher.new(matcher)
  end

end
