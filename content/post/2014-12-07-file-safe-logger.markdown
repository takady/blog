---
categories: ruby
comments: true
date: 2014-12-07T18:01:52Z
title: rubyのloggerをnewした後にログファイルを削除するとどうなるのか
url: /blog/2014/12/07/file-safe-logger/
---

__この投稿は[Ruby Advent Calendar 2014](http://qiita.com/advent-calendar/2014/ruby)の7日目の記事です。__

rubyには標準添付ライブラリにloggerクラスがある。  
そのloggerクラス、newした後に出力先のログファイルが削除された時の挙動について調べた。  
そして、[file_safe_logger](https://github.com/takady/file_safe_logger)というgemを作った。  

# 検証
下記のようにして、`Logger.new`と`logger.info`の間でファイルを削除してみる  

```ruby
require 'logger'
require 'fileutils'

logfile = 'test.log'
logger = Logger.new(logfile)
FileUtils.rm(logfile)
logger.info('this is test')
```

これは、結果としてはエラーにはならず正常終了するが、test.logというファイルはカレントディレクトリに存在せず、もちろん`this is test`というlogも残っていない。  

# FileSafeLogger
ファイルが削除されるとlogging出来ないというのが困る時がある。  
なので、[file_safe_logger](https://github.com/takady/file_safe_logger)というgemを作った。  
やってることはいたって単純で、[Logger::LogDevice.#write](https://github.com/ruby/ruby/blob/trunk/lib/logger.rb#L593-L612)メソッドをoverrideして、ファイルが存在しない場合は作成しているだけである。  
[file_safe_logger](https://github.com/takady/file_safe_logger)を使って、先ほどのlogging処理と同じ処理をやってみる。  

```ruby
require 'file_safe_logger'
require 'fileutils'

logfile = 'test.log'
logger = FileSafeLogger.new(logfile)
FileUtils.rm(logfile)
logger.info('this is test')
```

これの実行後、カレントディレクトリには`test.log`が存在し、下記のようにlogが書き出されている。  

    $ cat test.log
    # Logfile created on 2014-12-06 17:07:53 +0900 by logger.rb/44203
    I, [2014-12-06T17:07:53.884806 #1547]  INFO -- : this is test

# 参考
[sonots/process_safe_logger](https://github.com/sonots/process_safe_logger)  
