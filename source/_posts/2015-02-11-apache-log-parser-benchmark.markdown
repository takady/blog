---
layout: post
title: "apache_log-parserを修正してBenchmarkをとってみた"
date: 2015-02-11 16:53:46 +0900
comments: true
categories: ruby
---

[takady/apache_log-parser](https://github.com/takady/apache_log-parser)

先週，とある機会に，とあるエンジニアの方が，僕が作った[apache_log-parser](https://github.com/takady/apache_log-parser)というrubyのgemに対してアドバイスをしてくれた．  
「parseメソッド呼ぶ度に毎回Patternクラスのインスタンスとか作ったりしてるけど，Parserをクラスにして，最初にインスタンス作る時に1回だけやるようにした方が効率良いよ」みたいな指摘だった．確かにその通りだった．指摘ありがとうございます！  
ついでに，修正する前と後でパフォーマンスどれだけ良くなったのかを，rubyの標準ライブラリのBenchmarkを使って計測してみた．  

benchmark.rb自体はこんな感じで，100万行parseするのにかかる時間を計測している．  

```ruby
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'apache_log/parser'
require 'benchmark'

common_line = '127.0.0.1 - - [20/May/2014:20:04:04 +0900] "GET /test/indx.html HTTP/1.1" 200 4576'
combined_line = '192.168.0.1 - - [07/Jun/2014:14:58:55 +0900] "GET /category/electronics HTTP/1.1" 200 128 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"'
customized_line = '192.168.0.1 - - [07/Feb/2011:10:59:59 +0900] "GET /x/i.cgi/net/0000/ HTTP/1.1" 200 9891 "-" "DoCoMo/2.0 P03B(c500;TB;W24H16)" virtualhost.example.jp "192.0.2.16794832933550" "09011112222333_xx.ezweb.ne.jp" 533593'

common_parser = ApacheLog::Parser.new('common')
combined_parser = ApacheLog::Parser.new('combined')
customized_parser = ApacheLog::Parser.new('combined', %w(vhost usertrack mobileid request_duration))

n = 1_000_000
Benchmark.bm(12) do |x|
  x.report('common:')     { (1..n).each{common_parser.parse(common_line)} }
  x.report('combined:')   { (1..n).each{combined_parser.parse(combined_line)} }
  x.report('customized:') { (1..n).each{customized_parser.parse(customized_line)} }
end
```

## Before
まず，修正前のコードでのベンチマーク．

    $ ruby benchmark.rb
                       user     system      total        real
    common:      125.630000   0.180000 125.810000 (125.889122)
    combined:    151.530000   0.440000 151.970000 (152.090644)
    customized:  186.610000   0.460000 187.070000 (187.200379)

## After
次に，修正後のコードでのベンチマーク．

    $ ruby benchmark.rb
                       user     system      total        real
    common:       20.770000   0.020000  20.790000 ( 20.797196)
    combined:     30.090000   0.050000  30.140000 ( 30.161369)
    customized:   40.240000   0.070000  40.310000 ( 40.388290)


めちゃくちゃ改善された！！

# 参考
[RubyでのBenchmarkの取り方をば。](http://a-newcomer.com/29)
