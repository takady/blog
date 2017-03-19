---
layout: post
title: "Ruby の文字列マッチ判定のパフォーマンス"
date: 2017-03-19 17:36:07 +0900
comments: true
categories: ruby
---

下記のようなよくある文字列のマッチ判定を Ruby でやる場合に、String クラスのメソッドを使った場合と正規表現を使った場合それぞれのベンチマーク結果を見てみた。  

- 部分文字列が含まれているか
- 指定の文字列で始まっているか
- 指定の文字列で終わっているか

String のメソッドの方がパフォーマンスが良い。  

```
$ ruby benchmarker.rb
                           user     system      total        real
[string]include        0.170000   0.000000   0.170000 (  0.176603)
[regexp]include        0.330000   0.000000   0.330000 (  0.325735)
[string]start_with     0.140000   0.000000   0.140000 (  0.143240)
[regexp]start_with     0.310000   0.000000   0.310000 (  0.309559)
[string]end_with       0.130000   0.000000   0.130000 (  0.138091)
[regexp]end_with       0.340000   0.000000   0.340000 (  0.338614)
```

コード。

```ruby
require 'benchmark'

n = 1_000_000

Benchmark.bm(20) do |b|
  b.report('[string]include') { (1..n).each { 'test'.include?('es') } }
  b.report('[regexp]include') { (1..n).each { /es/ === 'test' } }
  b.report('[string]start_with') { (1..n).each { 'test'.start_with?('te') } }
  b.report('[regexp]start_with') { (1..n).each { /\Ate/ === 'test' } }
  b.report('[string]end_with') { (1..n).each { 'test'.end_with?('st') } }
  b.report('[regexp]end_with') { (1..n).each { /st\z/ === 'test' } }
end
```

ちなみに、`start_with?`、 `end_with?` は、引数に2つ以上文字列を指定できて、いずれかにマッチすれば true が返る。  

```ruby
[1] pry(main)> 'test'.start_with?('ab', 'te')
=> true
```
