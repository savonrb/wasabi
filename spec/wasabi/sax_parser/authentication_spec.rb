require "spec_helper"

describe Wasabi::SAX do
  include SpecSupport::SAX

  subject(:sax) { new_sax(:authentication).definition }

  context "with authentication.wsdl" do
    it "knows the target namespace" do
      expect(sax[:target_namespace]).to eq("http://v1_0.ws.auth.order.example.com/")
    end

    it "knows the elements" do
      expect(count_elements(:elements)).to eq(4)

      element = find_element(:elements, "authenticate")
      expect(element).to eq("type" => "tns:authenticate")
    end

    it "knows the complex types" do
      expect(count_elements(:complex_types)).to eq(4)

      element = find_element(:complex_types, "authenticationResult")
      expect(element).to eq(
        "sequence" => {
          "element" => [
            { "name" => "authenticationValue", "type" => "tns:authenticationValue", "minOccurs" => "0", "nillable" => "true" },
            { "name" => "success", "type" => "xs:boolean" }
          ]
        }
      )

      element = find_element(:complex_types, "authenticationValue")
      expect(element).to eq(
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
      expect(sax[:messages]).to eql(
        "authenticate"         => [{ "name" => "parameters", "element" => "tns:authenticate" }],
        "authenticateResponse" => [{ "name" => "parameters", "element" => "tns:authenticateResponse" }]
      )
    end

    it "knows the bindings" do
      expect(sax[:bindings]).to eq(
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
      expect(sax[:port_types]).to eq(
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
      expect(sax[:services]).to eql(
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
