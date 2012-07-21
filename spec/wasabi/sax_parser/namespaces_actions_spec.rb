require "spec_helper"

describe Wasabi::SAXParser, :fixture => :namespaced_actions do
  include SAXParserHelper

  subject(:sax) { Wasabi::SAXParser.new }

  context "with #{metadata[:fixture]}.wsdl" do
    before :all do
      fixture = self.class.metadata[:fixture]
      report_parse_time(fixture) { parse(fixture) }  # 0.0061 sec
    end

    it "knows the target namespace" do
      expect(sax.target_namespace).to eq("http://api.example.com/api/")
    end

    it "knows the elementFormDefault value" do
      expect(sax.element_form_default).to eq("qualified")
    end

    it "knows the attributeFormDefault value" do
      expect(sax.attribute_form_default).to eq("unqualified")
    end

    it "knows the elements" do
      expect(sax).to have(8).elements

      expect(sax.elements["User.GetApiKey"]). to eq(
        "complexType" => {
          "sequence"  => {
            "element" => [
              { "minOccurs" => "0", "maxOccurs" => "1", "name" => "SiteUrl",  "type" => "s:string" },
              { "minOccurs" => "0", "maxOccurs" => "1", "name" => "Username", "type" => "s:string" },
              { "minOccurs" => "0", "maxOccurs" => "1", "name" => "Password", "type" => "s:string" }
            ]
          }
        }
      )

      expect(sax.elements["Result"]).to eq("nillable" => "true", "type" => "tns:Result")
    end

    it "knows the complex types" do
      expect(sax).to have(3).complex_types

      expect(sax.complex_types["Result"]).to eq(
        "sequence"  => {
          "element" => [
            { "minOccurs" => "1", "maxOccurs" => "1", "name" => "Code",    "type" => "s:int" },
            { "minOccurs" => "0", "maxOccurs" => "1", "name" => "Message", "type" => "s:string" }
          ]
        }
      )
    end

    it "knows the services" do
      expect(sax.services).to eql(
        "api" => {
          "apiSoap"     => {
            "namespace" => Wasabi::NAMESPACES["soap"],
            "location"  => "https://api.example.com/api/api.asmx",
            "binding"   => "tns:apiSoap"
          },
          "apiSoap12"   => {
            "namespace" => Wasabi::NAMESPACES["soap2"],
            "location"  => "https://api.example.com/api/api.asmx",
            "binding"   => "tns:apiSoap12"
          },
          "apiHttpGet"  => {
            "namespace" => Wasabi::NAMESPACES["http"],
            "location"  => "https://api.example.com/api/api.asmx",
            "binding"   => "tns:apiHttpGet"
          },
          "apiHttpPost" => {
            "namespace" => Wasabi::NAMESPACES["http"],
            "location"  => "https://api.example.com/api/api.asmx",
            "binding"   => "tns:apiHttpPost"
          }
        }
      )
    end

    it "knows the bindings" do
      expect(sax.bindings).to eq(
        "apiSoap"           => {
          "type"            => "tns:apiSoap",
          "transport"       => "http://schemas.xmlsoap.org/soap/http",
          "namespace"       => Wasabi::NAMESPACES["soap"],
          "operations"      => {
            "GetApiKey"     => {
              "namespace"   => Wasabi::NAMESPACES["soap"],
              "soap_action" => "http://api.example.com/api/User.GetApiKey",
              "style"       => "document",
              "input"       => { "User.GetApiKey" => { "body" => { "use" => "literal" } } },
              "output"      => { "User.GetApiKey" => { "body" => { "use" => "literal" } } }
            },
            "DeleteClient"  => {
              "namespace"   => Wasabi::NAMESPACES["soap"],
              "soap_action" => "http://api.example.com/api/Client.Delete",
              "style"       => "document",
              "input"       => { "Client.Delete" => { "body" => { "use" => "literal" } } },
              "output"      => { "Client.Delete" => { "body" => { "use" => "literal" } } }
            },
            "GetClients"    => {
              "namespace"   => Wasabi::NAMESPACES["soap"],
              "soap_action" => "http://api.example.com/api/User.GetClients",
              "style"       => "document",
              "input"       => { "User.GetClients" => { "body" => { "use" => "literal" } } },
              "output"      => { "User.GetClients" => { "body" => { "use" => "literal" } } }
            }
          }
        },
        "apiSoap12"         => {
          "type"            => "tns:apiSoap",
          "transport"       => "http://schemas.xmlsoap.org/soap/http",
          "namespace"       => Wasabi::NAMESPACES["soap2"],
          "operations"      => {
            "GetApiKey"     => {
              "namespace"   => Wasabi::NAMESPACES["soap2"],
              "soap_action" => "http://api.example.com/api/User.GetApiKey",
              "style"       => "document",
              "input"       => { "User.GetApiKey" => { "body" => { "use" => "literal" } } },
              "output"      => { "User.GetApiKey" => { "body" => { "use" => "literal" } } }
            },
            "DeleteClient"  => {
              "namespace"   => Wasabi::NAMESPACES["soap2"],
              "soap_action" => "http://api.example.com/api/Client.Delete",
              "style"       => "document",
              "input"       => { "Client.Delete" => { "body" => { "use" => "literal" } } },
              "output"      => { "Client.Delete" => { "body" => { "use" => "literal" } } }
            },
            "GetClients"    => {
              "namespace"   => Wasabi::NAMESPACES["soap2"],
              "soap_action" => "http://api.example.com/api/User.GetClients",
              "style"       => "document",
              "input"       => { "User.GetClients" => { "body" => { "use" => "literal" } } },
              "output"      => { "User.GetClients" => { "body" => { "use" => "literal" } } }
            }
          }
        },
        "apiHttpGet"       => {
          "type"           => "tns:apiHttpGet",
          "verb"           => "GET",
          "namespace"      => Wasabi::NAMESPACES["http"],
          "operations"     => {
            "GetApiKey"    => {
              "namespace"  => Wasabi::NAMESPACES["http"],
              "location"   => "/User.GetApiKey",
              "input"      => { "User.GetApiKey" => {} },
              "output"     => { "User.GetApiKey" => {} }
            },
            "DeleteClient" => {
              "namespace"  => Wasabi::NAMESPACES["http"],
              "location"   => "/Client.Delete",
              "input"      => { "Client.Delete" => {} },
              "output"     => { "Client.Delete" => {} }
            },
            "GetClients"   => {
              "namespace"  => Wasabi::NAMESPACES["http"],
              "location"   => "/User.GetClients",
              "input"      => { "User.GetClients" => {} },
              "output"     => { "User.GetClients" => {} }
            }
          }
        },
        "apiHttpPost"      => {
          "type"           => "tns:apiHttpPost",
          "verb"           => "POST",
          "namespace"      => Wasabi::NAMESPACES["http"],
          "operations"     => {
            "GetApiKey"    => {
              "namespace"  => Wasabi::NAMESPACES["http"],
              "location"   => "/User.GetApiKey",
              "input"      => { "User.GetApiKey" => {} },
              "output"     => { "User.GetApiKey" => {} }
            },
            "DeleteClient" => {
              "namespace"  => Wasabi::NAMESPACES["http"],
              "location"   => "/Client.Delete",
              "input"      => { "Client.Delete" => {} },
              "output"     => { "Client.Delete" => {} }
            },
            "GetClients"   => {
              "namespace"  => Wasabi::NAMESPACES["http"],
              "location"   => "/User.GetClients",
              "input"      => { "User.GetClients" => {} },
              "output"     => { "User.GetClients" => {} }
            }
          }
        }
      )
    end

    it "knows the port types" do
      expect(sax.port_types).to eq(
        "apiSoap"          => {
          "operations"     => {
            "GetApiKey"    => {
              "input"      => { "User.GetApiKey" => { "message" => "tns:User.GetApiKeySoapIn" } },
              "output"     => { "User.GetApiKey" => { "message" => "tns:User.GetApiKeySoapOut" } }
            },
            "DeleteClient" => {
              "input"      => { "Client.Delete" => { "message" => "tns:Client.DeleteSoapIn" } },
              "output"     => { "Client.Delete" => { "message" => "tns:Client.DeleteSoapOut" } }
            },
            "GetClients"   => {
              "input"      => { "User.GetClients" => { "message" => "tns:User.GetClientsSoapIn" } },
              "output"     => { "User.GetClients" => { "message" => "tns:User.GetClientsSoapOut" } }
            }
          }
        },
        "apiHttpGet"       => {
          "operations"     => {
            "GetApiKey"    => {
              "input"      => { "User.GetApiKey" => { "message" => "tns:User.GetApiKeyHttpGetIn" } },
              "output"     => { "User.GetApiKey" => { "message" => "tns:User.GetApiKeyHttpGetOut" } }
            },
            "DeleteClient" => {
              "input"      => { "Client.Delete" => { "message" => "tns:Client.DeleteHttpGetIn" } },
              "output"     => { "Client.Delete" => { "message" => "tns:Client.DeleteHttpGetOut" } }
            },
            "GetClients"   => {
              "input"      => { "User.GetClients" => { "message" => "tns:User.GetClientsHttpGetIn" } },
              "output"     => { "User.GetClients" => { "message" => "tns:User.GetClientsHttpGetOut" } }
            }
          }
        },
        "apiHttpPost"      => {
          "operations"     => {
            "GetApiKey"    => {
              "input"      => { "User.GetApiKey" => { "message" => "tns:User.GetApiKeyHttpPostIn" } },
              "output"     => { "User.GetApiKey" => { "message" => "tns:User.GetApiKeyHttpPostOut" } }
            },
            "DeleteClient" => {
              "input"      => { "Client.Delete" => { "message" => "tns:Client.DeleteHttpPostIn" } },
              "output"     => { "Client.Delete" => { "message" => "tns:Client.DeleteHttpPostOut" } }
            },
            "GetClients"   => {
              "input"      => { "User.GetClients" => { "message" => "tns:User.GetClientsHttpPostIn" } },
              "output"     => { "User.GetClients" => { "message" => "tns:User.GetClientsHttpPostOut" } }
            }
          }
        }
      )
    end
  end

end
