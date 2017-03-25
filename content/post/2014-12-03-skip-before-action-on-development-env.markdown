---
categories: rails
comments: true
date: 2014-12-03T21:02:25Z
title: development環境だけbefore_actionをスキップする
url: /blog/2014/12/03/skip-before-action-on-development-env/
---

最近railsでapi開発をしていて、もちろんテストコード書いてるんだけど、  
たまにブラウザからGETリクエスト送ってサクッとjsonの中を見たいって時に、認証があって見れない。。。ってパターンがかなりある。  
開発環境では、認証しなくていいやと思った。  
下記のようにすることで、before_actionをdevelopment環境ではスキップさせられる。  

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate unless Rails.env.development?

  def authenticate
    ...
  end
```

# 参考
[Rails.env.development?でdevelopment環境かどうかを判定できる - memo.yomukaku.net](http://memo.yomukaku.net/entries/127)
