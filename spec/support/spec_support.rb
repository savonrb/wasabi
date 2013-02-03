require "support/fixture"
require "support/sax"

module SpecSupport

  def new_interface(fixture_name)
    Wasabi.interface fixture(fixture_name).read
  end

  def new_sax(fixture_name)
    Wasabi.sax fixture(fixture_name).read
  end

  def fixture(*args)
    Fixture.new(*args)
  end

end
