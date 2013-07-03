module SpecSupport

  def benchmark(&block)
    require 'benchmark'

    puts "Benchmark:"
    puts Benchmark.measure(&block)
  end

  def profile_methods
    require 'method_profiler'

    profiler = MethodProfiler.observe(Wasabi::Parser)
    yield
    puts profiler.report
  end

end
