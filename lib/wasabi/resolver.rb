# frozen_string_literal: true

require "faraday"

module Wasabi

  # = Wasabi::Resolver
  #
  # Resolves local and remote WSDL documents.
  class Resolver

    class HTTPError < StandardError
      def initialize(message, response=nil)
        super(message)
        @response = response
      end
      attr_reader :response
    end

    URL = /^http[s]?:/
    XML = /^</

    def initialize(document, request = nil, adapter = nil)
      @document = document
      @request  = request || Faraday.new
      @adapter  = adapter
    end

    attr_reader :document, :request, :adapter

    def resolve
      raise ArgumentError, "Unable to resolve: #{document.inspect}" unless document

      case document
        when URL then load_from_remote
        when XML then document
        else          load_from_disc
      end
    end

    private

    def load_from_remote
      request.adapter *adapter if adapter
      response = request.get(document)

      raise HTTPError.new("Error: #{response.status} for url #{document}", response) unless response.success?

      response.body
    end

    def load_from_disc
      File.read(document)
    end

  end
end
