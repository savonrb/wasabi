require "spec_helper"

describe Wasabi::SAX do

  subject(:sax) { new_sax(:authentication) }

  context "with authentication.wsdl" do
    it "knows the target namespace" do
      expect(sax.target_namespace).to eq("http://v1_0.ws.auth.order.example.com/")
    end

    it "knows the elementFormDefault value" do
      expect(sax.element_form_default).to eq("unqualified")
    end

    it "knows the attributeFormDefault value" do
      expect(sax.attribute_form_default).to eq("unqualified")
    end

    it "knows the elements" do
      expect(sax).to have(4).elements

      expect(sax.elements["authenticate"]).to eq("type" => "tns:authenticate")
    end

    it "knows the complex types" do
      expect(sax).to have(4).complex_types

      expect(sax.complex_types["authenticationResult"]).to eq(
        "sequence" => {
          "element" => [
            { "name" => "authenticationValue", "type" => "tns:authenticationValue", "minOccurs" => "0", "nillable" => "true" },
            { "name" => "success", "type" => "xs:boolean" }
          ]
        }
      )

      expect(sax.complex_types["authenticationValue"]).to eq(
        "sequence" => {
          "element" => [
            { "name" => "token",     "type" => "xs:string" },
            { "name" => "tokenHash", "type" => "xs:string" },
            { "name" => "client",    "type" => "xs:string" }
          ]
        }
      )
    end

    it "knows the messages" do
      expect(sax.messages).to eql(
        "authenticate"         => [{ "name" => "parameters", "element" => "tns:authenticate" }],
        "authenticateResponse" => [{ "name" => "parameters", "element" => "tns:authenticateResponse" }]
      )
    end

    it "knows the bindings" do
      expect(sax.bindings).to eq(
        "AuthenticationWebServiceImplServiceSoapBinding" => {
          "type"            => "tns:AuthenticationWebService",
          "transport"       => "http://schemas.xmlsoap.org/soap/http",
          "namespace"       => Wasabi::NAMESPACES["soap"],
          "operations"      => {
            "authenticate"  => {
              "namespace"   => Wasabi::NAMESPACES["soap"],
              "soap_action" => "",
              "style"       => "document",
              "input"       => { "authenticate"         => { "body" => { "use" => "literal" } } },
              "output"      => { "authenticateResponse" => { "body" => { "use" => "literal" } } }
            }
          }
        }
      )
    end

    it "knows the port types" do
      expect(sax.port_types).to eq(
        "AuthenticationWebService" => {
          "operations"     => {
            "authenticate" => {
              "input"      => { "authenticate"         => { "message" => "tns:authenticate" } },
              "output"     => { "authenticateResponse" => { "message" => "tns:authenticateResponse" } }
            }
          }
        }
      )
    end

    it "knows the services" do
      expect(sax.services).to eql(
        "AuthenticationWebServiceImplService" => {
          "AuthenticationWebServiceImplPort" => {
            "namespace" => Wasabi::NAMESPACES["soap"],
            "location"  => "http://example.com/validation/1.0/AuthenticationService",
            "binding"   => "tns:AuthenticationWebServiceImplServiceSoapBinding"
          }
        }
      )
    end
  end

end
