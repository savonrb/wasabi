require 'benchmark'
require 'method_profiler'

module SpecSupport

  def benchmark(&block)
    puts "Benchmark:"
    puts Benchmark.measure(&block)
  end

  def profile_methods
    profiler = MethodProfiler.observe(Wasabi::Parser)
    yield
    puts profiler.report
  end

end
