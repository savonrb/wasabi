require "httpi"

module Wasabi

  # = Wasabi::Resolver
  #
  # Purpose:
  #   Resolves local and remote WSDL documents.
  class Resolver

    class HTTPError < StandardError; end

    def initialize(source, http_request = nil)
      @source       = source
      @http_request = http_request || HTTPI::Request.new
    end

    def xml
      case @source
        when /^http[s]?:/ then from_remote
        when /^</         then @source
        else                   from_fs
      end
    end

    private

    def from_remote
      @http_request.url = @source
      response = HTTPI.get(@http_request)

      if response.error?
        raise HTTPError.new(response)
      else
        response.body
      end
    end

    def from_fs
      File.read(@source)
    end

  end
end
