require "benchmark"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

require "wasabi"

RSpec::Core::RakeTask.new

FIXTURES = %w[authentication betfair ebay economic]

namespace :benchmark do

  def benchmark(fixture_name, n = 10)
    fixture = File.expand_path("../spec/fixtures/#{fixture_name}.wsdl", __FILE__)

    Benchmark.bm(20) do |x|
      x.report(fixture_name) do
        n.times do
          Wasabi.sax(fixture)
        end
      end
    end
  end

  FIXTURES.each do |f|
    desc "Benchmark #{f}.wsdl"
    task(f) { benchmark(f) }
  end

end

desc "Benchmark all fixtures"
task :benchmark => FIXTURES.map { |f| "benchmark:#{f}" }

task :default => :spec
task :test => :spec
