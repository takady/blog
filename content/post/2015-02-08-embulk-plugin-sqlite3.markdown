---
categories: ruby embulk
comments: true
date: 2015-02-08T22:17:00Z
title: embulk-plugin-sqlite3を作った
url: /blog/2015/02/08/embulk-plugin-sqlite3/
---

[takady/embulk-plugin-sqlite3](https://github.com/takady/embulk-plugin-sqlite3)

# embulkとは
いわゆるbulk loaderと言われる並列にデータを移動させるためのプロダクトの一つ．embulkがユニークなのはinput/outputなどの部分がpluggableになっている点．  
つまり，データの移動に際して発生するリソースへの接続処理の実装や，データのクレンジング・フォーマット変換，その他必要になる雑多な処理をプラグインという形で定義しておくことで，再利用しやすくなるというわけ．  

## Fluentdとの違い
同じくTreasure Data社が開発しているFluentdも，input/outputのpluginをrubyで書けるなど，一見同じ感じである．  
ただ，Fluentdのユースケースは__リアルタイム__にlogを流すという部分であり，一方でembulkは__バッチ処理__でデータをimport/exportする用途にフォーカスしているというところに違いがある．  

# 導入
[embulkのREADME.md](https://github.com/embulk/embulk)にはjarをdownloadしてきて使う方法だけが書かれているが，普通にrubygems.orgにリリースされているので`gem install`で入れられる．

    $ gem install embulk

そして，`embulk gem install`でpluginをinstallする．

    $ embulk gem install embulk-plugin-sqlite3
    Fetching: jdbc-sqlite3-3.8.7.gem (100%)
    Successfully installed jdbc-sqlite3-3.8.7
    Fetching: embulk-plugin-sqlite3-0.0.1.gem (100%)
    Successfully installed embulk-plugin-sqlite3-0.0.1
    2 gems installed

# 実行
今回はexampleのcsvファイルを，sqlite3のテーブルにloadしてみる.

下記で，exampleのcsvファイルを生成する．

    $ embulk example /tmp
    $ embulk guess /tmp/example.yml -o /tmp/config.yml

`/tmp/config.yml`のoutputの設定を下記のように修正する．

```yaml
out:
  type: sqlite3
  database: '/tmp/test.db'
  table: 'load01'
```

`embulk run`する．

    $ embulk run /tmp/config.yml
    2015-02-08 22:29:38,623 [INFO]: main:org.embulk.standards.LocalFileInputPlugin: Listing local files with prefix '/tmp/csv'
    2015-02-08 22:29:38,885 [INFO]: main:org.embulk.exec.LocalExecutor: Running 1 tasks using 8 local threads
    2015-02-08 22:29:38,885 [INFO]: main:org.embulk.exec.LocalExecutor: {done:  0 / 1, running: 0}
    2015-02-08 22:29:39,035 [INFO]: main:org.embulk.exec.LocalExecutor: {done:  1 / 1, running: 0}
    Output finished. Commit reports = [{"records":4}]
    2015-02-08 22:29:39,041 [INFO]: main:org.embulk.command.Runner: next config: {"in":{},"out":{}}

テーブルの中身を確認すると，insertできていることがわかる．

    $ sqlite3 /tmp/test.db
    SQLite version 3.7.13 2012-07-17 17:46:21
    Enter ".help" for instructions
    Enter SQL statements terminated with a ";"
    sqlite> .schema load01
    CREATE TABLE load01(`id` integer,`account` integer,`time` text,`purchase` text,`comment` text);
    sqlite> select * from load01;
    1|32864|2015-01-27 19:23:49 UTC|2015-01-27 00:00:00 UTC|embulk
    2|14824|2015-01-27 19:01:23 UTC|2015-01-27 00:00:00 UTC|embulk jruby
    3|27559|2015-01-28 02:20:02 UTC|2015-01-28 00:00:00 UTC|embulk core
    4|11270|2015-01-29 11:54:36 UTC|2015-01-29 00:00:00 UTC|Embulk "csv" parser plugin
    sqlite>

# まとめ
embulk自体がjrubyで書かれており，pluginでC拡張のgemは使えないみたい．  
なので，DB接続する場合はjdbc-sqlite3などのgemを使うことになる．(間違ってたら指摘お願いします)  
あと，pluginの作り方のベスト・プラクティスがまだわからない．  

# 参考
- [embulk/embulk](https://github.com/embulk/embulk)
- [Treasure Dataの新データ転送ツールEmbulkを触ってみた #dtm_meetup ｜ Developers.IO](http://dev.classmethod.jp/tool/embulk-ataglance/)
- [Embulk, an open-source plugin-based parallel bulk data loader](http://www.slideshare.net/frsyuki/embuk-making-data-integration-works-relaxed)
- [frsyuki/embulk-plugin-postgres-json](https://github.com/frsyuki/embulk-plugin-postgres-json)
- [takebayashi/embulk-plugin-input-hbase](https://github.com/takebayashi/embulk-plugin-input-hbase)
- [jruby/activerecord-jdbc-adapter](https://github.com/jruby/activerecord-jdbc-adapter)
- [xerial / sqlite-jdbc — Bitbucket](https://bitbucket.org/xerial/sqlite-jdbc/overview)
