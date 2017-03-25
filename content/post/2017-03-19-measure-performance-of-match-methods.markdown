---
categories: ruby
comments: true
date: 2017-03-19T17:36:07Z
title: Ruby の文字列マッチ判定のパフォーマンス
url: /blog/2017/03/19/measure-performance-of-match-methods/
---

下記のようなよくある文字列のマッチ判定を Ruby でやる場合に、String クラスのメソッドを使った場合と正規表現を使った場合それぞれのベンチマーク結果を見てみた。  
w
- 部分文字列が含まれているか
- 指定の文字列で始まっているか
- 指定の文字列で終わっているか

String のメソッドの方がパフォーマンスが良い。  

```
$ ruby benchmarker.rb
                           user     system      total        real
[string]include        0.110000   0.000000   0.110000 (  0.116923)
[regexp]include        0.230000   0.000000   0.230000 (  0.229775)
[string]start_with     0.090000   0.010000   0.100000 (  0.087478)
[regexp]start_with     0.230000   0.000000   0.230000 (  0.234467)
[string]end_with       0.090000   0.000000   0.090000 (  0.091226)
[regexp]end_with       0.250000   0.000000   0.250000 (  0.249781)
```

コード。  
生成コストが入らないように定数で宣言したものでベンチマーク取った。  

```ruby
require 'benchmark'

n = 1_000_000

TEST = 'test'.freeze
TE = 'te'.freeze
ST = 'st'.freeze
REGEXP_TEST = /test/.freeze
REGEXP_TE = /\Ate/.freeze
REGEXP_ST = /st\z/.freeze

Benchmark.bm(20) do |b|
  b.report('[string]include') { (1..n).each { TEST.include?(TE) } }
  b.report('[regexp]include') { (1..n).each { REGEXP_TEST === TEST } }
  b.report('[string]start_with') { (1..n).each { TEST.start_with?(TE) } }
  b.report('[regexp]start_with') { (1..n).each { REGEXP_TE === TEST } }
  b.report('[string]end_with') { (1..n).each { TEST.end_with?(ST) } }
  b.report('[regexp]end_with') { (1..n).each { REGEXP_ST === TEST } }
end
```

ちなみに、`start_with?`、 `end_with?` は、引数に2つ以上文字列を指定できて、いずれかにマッチすれば true が返る。  

```ruby
[1] pry(main)> 'test'.start_with?('ab', 'te')
=> true
```
