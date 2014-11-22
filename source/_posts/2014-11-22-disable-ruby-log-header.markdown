---
layout: post
title: "rubyのloggerでlogのヘッダを出力しない"
date: 2014-11-22 13:11:18 +0900
comments: true
categories: ruby
---
rubyのLoggerを使っていると、Logger.newした際に生成されるlogファイルには、デフォルトで下記のようなヘッダが出力される。  
`# Logfile created on 2014-11-22 13:15:26 +0900 by logger.rb/44203`  

これを出したくない場合は、下記のようにヘッダをつける[Logger::LogDevice#add_log_header](https://github.com/ruby/ruby/blob/trunk/lib/logger.rb#L649-L653)メソッドを空にoverrideすると良い。

```ruby
class Logger::LogDevice
  def add_log_header(file)
  end
end

log = Logger.new('info.log')
```

# 参考
[Can I disable the log header for ruby logger? - Stack Overflow](http://stackoverflow.com/questions/4096336/can-i-disable-the-log-header-for-ruby-logger)
