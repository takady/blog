---
layout: post
title: "rails のログを fluentd で slack に通知する"
date: 2017-02-19 18:58:24 +0900
comments: true
categories:
---

Ubuntu に td-agent 入れて Slack に rails アプリのエラーを通知するようにしたときの備忘録。  

## td-agent

### インストール
td-agent のインストールは下記に書いてある通り。  
[Installing Fluentd Using deb Package | Fluentd](http://docs.fluentd.org/v0.12/articles/install-by-deb)

Ubuntu 16.04 なので下記で入れた。  

    $ curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-xenial-td-agent2.sh | sh

### プラグインのインストール
td-agent-gem で slack のプラグインをインストール。  

    $ td-agent-gem install fluent-plugin-slack

### 設定ファイルの修正
`/etc/td-agent/td-agent.conf` を下記のように修正。  
webhook の URL あらかじめ Slack 取得しておく。  

```
<source>
  @type forward
</source>

<match app.*>
  type copy
  <store>
    @type file
    path /var/log/app/web
    time_slice_wait 10m
    compress gzip
  </store>

  <store>
    @type rewrite_tag_filter
    rewriterule1 severity FATAL app.fatal
  </store>
</match>

<match app.fatal>
  @type slack
  webhook_url https://hooks.slack.com/services/xxxxxxxxxxx
  channel app_error
  username ErrorBot
  icon_emoji :astonished:
  message_keys messages
  flush_interval 5s
</match>

<match clear>
  @type null
</match>
```

### 再起動
td-agent を再起動する。  

    $ /etc/init.d/td-agent restart

## rails

### Gemfile
`act-fluent-logger-rails` と `lograge` をインストール。  

```
gem 'act-fluent-logger-rails'
gem 'lograge'
```

### config/environments/production.rb
loggerの設定。  

```ruby
config.log_level = :info
config.logger = ActFluentLoggerRails::Logger.new
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Json.new
```

### config/fluent-logger.yml
fluent用の設定ファイル。  

```yaml
production:
  fluent_host:   '127.0.0.1'
  fluent_port:   24224
  tag:           'app.web'
  messages_type: 'string'
```

## 結果
ログが下記に出るようになる。アプリケーションエラーが起きれば Slack にポストされる。  

    $ tail -f /var/log/app/web.20170219.b548df17385a3a314
    2017-02-19T09:51:42+00:00       app.web    {"messages":"{\"method\":\"GET\",\"path\":\"/\",\"format\":\"html\",\"controller\":\"FooController\",\"action\":\"index\",\"status\":200,\"duration\":1534.33,\"view\":1299.3,\"db\":0.0}","severity":"INFO"}
    2017-02-19T09:51:43+00:00       app.web    {"messages":"{\"method\":\"GET\",\"path\":\"/api/foo.json\",\"format\":\"json\",\"controller\":\"Api::FooController\",\"action\":\"index\",\"status\":200,\"duration\":374.19,\"view\":49.21,\"db\":0.0}","severity":"INFO"}


## 参考
- [actindi/act-fluent-logger-rails: Fluent logger](https://github.com/actindi/act-fluent-logger-rails)
- [Collecting and Analyzing Ruby on Rails Logs | Fluentd](http://www.fluentd.org/datasources/rails)
