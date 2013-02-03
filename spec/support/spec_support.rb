require "support/fixture"
require "support/parser"

module SpecSupport

  def new_parser(fixture_name)
    Wasabi.parser fixture(fixture_name).read
  end

  def new_interface(fixture_name)
    Wasabi.interface fixture(fixture_name).read
  end

  def fixture(*args)
    Fixture.new(*args)
  end

end
