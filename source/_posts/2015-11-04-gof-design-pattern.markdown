---
layout: post
title: "オブジェクト指向における再利用のためのデザインパターン を読んだ"
date: 2015-11-04 20:45:35 +0900
comments: true
categories: book
---

いわゆる GoF 本を読んだ。  

<br />

<iframe src="http://rcm-fe.amazon-adsystem.com/e/cm?t=takadayuichi-22&o=9&p=8&l=as1&asins=4797311126&ref=qf_sp_asin_til&fc1=000000&IS2=1&lt1=_blank&m=amazon&lc1=0000FF&bc1=000000&bg1=FFFFFF&f=ifr" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>

# 動機
こういう設計に関する本は今まで読んだことがなくて、なんとなくそういうことは本で勉強するより実践から身につけるものなんだろうという考えがあったんだけど、チームリーダーからそういう本も読んでみたらいいよと言われたこともあり、どうせ読むなら一番ベタなやつをということでこの本を選んだ。  

# 感想
書いてあるパターンには、よく知っているものから、よくわからないものまであった。  
今までなんとなく書いていた書き方に、oo パターンという名前が付いたような感じ。  
ただ、違いがいまいち理解出来ないものもあったりして、引き続き勉強しないとなと思った。  

役に立ちそうなところとか、良かったと思ったことはこの辺だろうか。  

- 共通の設計用語が身につく
  - oo パターンという名前によって伝えられるので、他の人にも伝えやすい。
  - 他の開発者とのコミュニケーションの助けになると思う。

- 先人の知恵を借りられる
  - 実践の中でぼんやりと見えてくるであろう良い設計というものが、この本を読むことで学べた。かもしれない。

- リファクタリングの道すじを考えやすくなる
  - そもそも最初からデザインパターンを適用して設計すれば、リファクタリングの必要性すら減るのかもしれない。
  - 既存のコードに対してリファクタリングをする際には、デザインパターンを適用出来ないか検討してみたい。拡張・保守しやすいものにするために。
  - もちろんそれを振りかざしてはいけないと思う。

実際に開発をするときには rails などのフレームワークを使うことがほぼ 100% なわけで、そのフレームワークが自然に求める書き方をするべきだと思っている。そうしないとそのフレームワークを選ぶ意味が無いから。同じように言語自体の特性というものもあるだろう。  
言語、フレームワークとデザインパターンを上手く使いこなしていきたいし、アイデアの引き出しを増やす意味でもこの本を読んだ意味があったと思う。  

# その他
サンプルが C++ なのがつらくて、Ruby で書いてあるものを探したら <a rel="nofollow" href="http://www.amazon.co.jp/gp/product/4894712857/ref=as_li_qf_sp_asin_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=4894712857&linkCode=as2&tag=takadayuichi-22">Rubyによるデザインパターン</a><img src="http://ir-jp.amazon-adsystem.com/e/ir?t=takadayuichi-22&l=as2&o=9&a=4894712857" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /> という本が見つかったが、残念ながら絶版になっていた。  
web 上の記事としては [Ruby 2.0.0で学ぶ、14個のデザインパターンを作りました[GoF][Design Pattern] - 酒と泪とRubyとRailsと](http://morizyun.github.io/blog/ruby-design-pattern-matome-mokuzi/) がかなり参考になった。  
