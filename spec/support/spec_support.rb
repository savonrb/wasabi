require "support/fixture"
require "support/sax"

module SpecSupport

  def new_interpreter(fixture_name)
    Wasabi.interpreter fixture(fixture_name).read
  end

  def new_sax(fixture_name)
    Wasabi.sax fixture(fixture_name).read
  end

  def fixture(*args)
    Fixture.new(*args)
  end

end
