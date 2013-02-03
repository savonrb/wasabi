require "spec_helper"

describe Wasabi::Parser do
  include SpecSupport::Parser

  subject(:parser) { new_parser(:namespaced_actions).definition }

  context "with namespaced_actions.wsdl" do
    it "knows the target namespace" do
      expect(parser[:target_namespace]).to eq("http://api.example.com/api/")
    end

    it "knows the elements" do
      expect(count_elements(:elements)).to eq(8)

      element = find_element(:elements, "User.GetApiKey")
      expect(element).to eq(
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

      element = find_element(:elements, "Result")
      expect(element).to eq("nillable" => "true", "type" => "tns:Result")
    end

    it "knows the complex types" do
      expect(count_elements(:complex_types)).to eq(3)

      element = find_element(:complex_types, "Result")
      expect(element).to eq(
        "sequence"  => {
          "element" => [
            { "minOccurs" => "1", "maxOccurs" => "1", "name" => "Code",    "type" => "s:int" },
            { "minOccurs" => "0", "maxOccurs" => "1", "name" => "Message", "type" => "s:string" }
          ]
        }
      )
    end

    it "knows the messages" do
      expect(parser[:messages].count).to eq(18)

      expect(parser[:messages]["User.GetClientsSoapIn"]).to eql(
        [{ "name" => "parameters", "element" => "tns:User.GetClients" }]
      )

      expect(parser[:messages]["User.GetApiKeyHttpGetIn"]).to eql(
        [
          { "name" => "SiteUrl",  "type" => "s:string" },
          { "name" => "Username", "type" => "s:string" },
          { "name" => "Password", "type" => "s:string" }
        ]
      )
    end

    it "knows the bindings" do
      expect(parser[:bindings]).to eq(
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
      expect(parser[:port_types]).to eq(
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

    it "knows the services" do
      expect(parser[:services]).to eql(
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
  end

end
