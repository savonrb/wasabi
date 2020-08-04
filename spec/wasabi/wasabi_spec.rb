# frozen_string_literal: true

require "spec_helper"

describe Wasabi do

  describe ".document" do
    it "should return a new Wasabi::Document" do
      document = Wasabi.document fixture(:authentication).read
      expect(document).to be_a(Wasabi::Document)
    end
  end

end
