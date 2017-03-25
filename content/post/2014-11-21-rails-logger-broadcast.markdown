---
categories: rails
comments: true
date: 2014-11-21T18:57:07Z
title: railsで、複数の出力先にlogを出力する
url: /blog/2014/11/21/rails-logger-broadcast/
---

railsアプリケーションで、error以上のレベルのログだけ、２箇所にログを出力したいと思った。

# 前提
ruby 2.1.2  
rails 4.1.4

# 方法
まず、複数の出力先にロギングするには、[ActiveSupport::Logger.#broadcast](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/logger.rb#L10-L42)というメソッドが使える。  
config/application.rbのMyapp::Applicationクラス内に下記のように書いてみた。

```ruby
logger = ActiveSupport::Logger.new(config.paths["log"].first)
error_logger = ActiveSupport::Logger.new("log/error.log")
error_logger.level = Logger::ERROR
logger.extend ActiveSupport::Logger.broadcast(error_logger)
config.logger = logger
```

これで、複数箇所にログが出力されるようにはなった。  
しかし、今回やりたかったのは、__ERROR以上の時だけ__２箇所にロギングしたいというもので、上記のようにconfig/application.rbでextendした場合、error_loggerのlevelをERRORにセットしていても、Rails.loggerのlevelと同じlevelでのloggingになってしまう。  
全く同じエラーログを複数箇所に吐かせたいというだけであれば、上記の方法で良いと思う。(その際、上記の`error_logger.level = Logger::ERROR`は意味が無いので消した方が良い)

error_logger.levelの指定が効くようにするには、`run Rails.application`よりも後で、error_loggerをRails.loggerにextendすると良い。  
config.ruに下記を追記する。

```ruby
run Rails.application

error_logger = ActiveSupport::Logger.new("log/error.log")
error_logger.level = Logger::ERROR
Rails.logger.extend ActiveSupport::Logger.broadcast(error_logger)
```

これで、log/error.logへは、ERRORレベル以上のログだけが出力されるようになった。  
もちろん、log/development.logには、これまでどおりDEBUGレベルまで含めた全てのlogが出ている。  

# 参考
[[Ruby] 例えば、Rails の標準ログを止める - sonots:blog](http://blog.livedoor.jp/sonots/archives/38927788.html)  
[RailsDoc - ActiveSupport::Logger](http://railsdoc.eiel.info/active_support/logger/)  
[【Rails】バッチの実行ログを専用のログファイルと標準出力の両方に出す - おどるダメ人間](http://mitsu877.hatenablog.com/entry/2014/11/15/193547)
