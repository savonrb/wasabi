module SAXParserHelper

  def report_parse_time(fixture)
    start_time = Time.now
    yield
    end_time = Time.now

    if ENV["BENCHMARK"]
      puts "parse time for #{fixture} fixture: #{end_time - start_time}"
    end
  end

  def parse(fixture_name)
    parser = Nokogiri::XML::SAX::Parser.new(sax)
    parser.parse fixture(fixture_name).read
  end

end
