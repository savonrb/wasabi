require "spec_helper"

describe Wasabi::CoreExt::String do

  describe ".snakecase" do
    it "lowercases one word CamelCase" do
      expect(Wasabi::CoreExt::String.snakecase("Merb")).to eq("merb")
    end

    it "makes one underscore snakecase two word CamelCase" do
      expect(Wasabi::CoreExt::String.snakecase("MerbCore")).to eq("merb_core")
    end

    it "handles CamelCase with more than 2 words" do
      expect(Wasabi::CoreExt::String.snakecase("SoYouWantContributeToMerbCore")).to eq("so_you_want_contribute_to_merb_core")
    end

    it "handles CamelCase with more than 2 capital letter in a row" do
      expect(Wasabi::CoreExt::String.snakecase("CNN")).to eq("cnn")
      expect(Wasabi::CoreExt::String.snakecase("CNNNews")).to eq("cnn_news")
      expect(Wasabi::CoreExt::String.snakecase("HeadlineCNNNews")).to eq("headline_cnn_news")
    end

    it "does NOT change one word lowercase" do
      expect(Wasabi::CoreExt::String.snakecase("merb")).to eq("merb")
    end

    it "leaves snake_case as is" do
      expect(Wasabi::CoreExt::String.snakecase("merb_core")).to eq("merb_core")
    end

    it "converts period characters to underscores" do
      expect(Wasabi::CoreExt::String.snakecase("User.GetEmail")).to eq("user_get_email")
    end
  end

end
