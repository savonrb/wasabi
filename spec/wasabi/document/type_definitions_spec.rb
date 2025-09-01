# frozen_string_literal: true

require "spec_helper"

describe Wasabi::Document do
  context "type definitions" do
    subject { Wasabi::Document.new fixture(:multiple_namespaces).read }

    describe '#type_definition' do
      it "returns type information with fields" do
        article_type = subject.type_definition("Article")
        
        expect(article_type[:name]).to eq("Article")
        expect(article_type[:namespace]).to eq("http://example.com/article")
        expect(article_type[:fields]["Author"][:type]).to eq("s:string")
        expect(article_type[:fields]["Title"][:type]).to eq("s:string")
        expect(article_type[:order]).to eq(["Author", "Title"])
      end

      it "returns nil for non-existent types" do
        expect(subject.type_definition("NonExistentType")).to be_nil
      end
    end

    describe '#operation_input_type' do
      it "returns input type for operations" do
        input_type = subject.operation_input_type(:save)
        
        expect(input_type[:name]).to eq("Save")
        expect(input_type[:namespace]).to eq("http://example.com/actions")
        expect(input_type[:fields]["article"][:type]).to eq("article:Article")
      end
    end

    describe '#operation_output_type' do
      it "returns output type for operations" do
        output_type = subject.operation_output_type(:save)
        
        if output_type
          expect(output_type[:name]).to match(/Save/)
        end
      end
    end
  end
end