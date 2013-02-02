## Benchmarks

This contains the results of running `bundle exec rake benchmark` inside the project.
It's a manual collection that is supposed to be checked and updated from time to time.
This could propably be automated, but it's a simple start.

The benchmark task currently parses four different fixtures of varying sizes for ten times.


#### Don't trust benchmarks

If you want to compare these results with your own, please note that I'm running these
on my MacBook Air (Mid 2012). Here are some specs:

* 1,8 GHz Intel Core i5
* 4 GB 1600 MHz DDR3
* OS X 10.8.2
* Ruby 1.9.3


#### 2012-02-03

```
                           user     system      total        real
authentication         0.050000   0.000000   0.050000 (  0.049021)
betfair                1.120000   0.010000   1.130000 (  1.158795)
ebay                  30.380000   0.180000  30.560000 ( 31.236821)
economic              35.340000   0.170000  35.510000 ( 36.203274)
```
