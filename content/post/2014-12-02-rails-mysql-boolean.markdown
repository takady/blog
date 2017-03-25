---
categories: rails
comments: true
date: 2014-12-02T18:07:11Z
title: railsでmysqlのbooleanなカラムをエイリアスで扱う時の注意事
url: /blog/2014/12/02/rails-mysql-boolean/
---

rails+mysqlな環境では、booleanで定義したカラムはtinyint(1)で作られ、中身はtrue/falseではなく、0/1が入る。  
そして、railsアプリケーション上でmysqlのtinyint(1)型データを扱う時、値は自動的にtrue/falseとして扱われる。  
そこまでは知っていたんだけど、`select('foobar_flg as fb_flg')`というふうに、カラム名をエイリアスして取り出すと値が0/1なのは知らなかった。  

具体的には下記のとおりである。  

    pry(main)> p = User.select(:foobar_flg)
      User Load (10.5ms)  SELECT  `users`.`foobar_flg` FROM `users`
    => [#<User id: nil, foobar_flg: false>]
    pry(main)> p.first.foobar_flg
    => false

    pry(main)> p = User.select('foobar_flg as fb_flg')
      User Load (5.8ms)  SELECT  foobar_flg as fb_flg FROM `users`
    => [#<User id: nil>]
    pry(main)> p.first.fb_flg
    => 0

ちなみに、selectメソッドの引数に文字列を指定したから0/1が返ってくるというわけではない。  
下記のようにエイリアス無しなら、文字列で指定してもtrue/falseに解釈される。  

    pry(main)> p = User.select('foobar_flg')
      User Load (10.0ms)  SELECT  `users`.`foobar_flg` FROM `users`
    => [#<User id: nil, foobar_flg: false>]
    pry(main)> p.first.foobar_flg
    => false

このままだと結構困る。  
結論としては、__as使わない__で済むならそれが最善手だと思う。  
が、それが無理なら、例えば下記のようにModelのattributeメソッドをoverrideしちゃうのが良さそう。  

```ruby
def fb_flg
  read_attribute(:fb_flg) == 1
end
```

# 参考
[ruby on rails - Override ActiveRecord attribute methods - Stack Overflow](http://stackoverflow.com/questions/373731/override-activerecord-attribute-methods)  
