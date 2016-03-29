require 'spec_helper'

describe Wasabi::Parser do
  context 'with: types_with_same_name_in_separate_namespaces.wsdl' do
    subject do
      parser = Wasabi::Parser.new Nokogiri::XML(xml)
      parser.parse
      parser
    end

    let(:xml) { fixture(:types_with_same_name_in_separate_namespaces).read }

    it 'parses two types in separate namespaces' do
      expect(subject.types['http://example.com/article'].keys.sort).to eq(['Article', 'Header'])
      expect(subject.types['http://example.com/actions'].keys.sort).to eq(['Header', 'Save'])
    end
    
    it 'assigns the correct type to the appropriate namespace' do
      expect(subject.types['http://example.com/article']['Header'][:order!]).to eq(['ArticleHeaderField1', 'Description'])
      expect(subject.types['http://example.com/article']['Header'][:namespace]).to eq('http://example.com/article')
      
      expect(subject.types['http://example.com/actions']['Header'][:order!]).to eq(['ActionHeaderField1', 'Description'])
      expect(subject.types['http://example.com/actions']['Header'][:namespace]).to eq('http://example.com/actions')      
    end
    
  end
end
