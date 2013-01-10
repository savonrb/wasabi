require "wasabi/sax"

module Wasabi
  class Interpreter

    def initialize(sax)
      @sax = sax
    end

    def soap_endpoint
      # XXX: should we check for the soap 1.2 namespace as well?
      #      are there services with only a soap 1.2 endpoint?
      soap_namespace = Wasabi::NAMESPACES["soap"]
      endpoints[soap_namespace]
    end

    def endpoints
      @endpoints ||= endpoints!
    end

    private

    def endpoints!
      endpoints = {}

      @sax.services.each { |service_name, ports|
        ports.each { |port_name, details|
          endpoints.update(details["namespace"] => details["location"])
        }
      }

      endpoints
    end

  end
end