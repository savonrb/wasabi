class FakeAdapterForTest < HTTPI::Adapter::Base

  register :fake_adapter_for_test

  def initialize(request)
    @@requests ||= []
    @@requests.push request
    @request = request
  end

  attr_reader :client

  def request(method)
    @@methods ||= []
    @@methods.push method
    HTTPI::Response.new(200, {}, 'wsdl_by_adapter')
  end
end
