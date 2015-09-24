---
layout: post
title: "WEB+DB PRESS plus の DB 本 3冊を読んだ"
date: 2015-09-24 18:43:39 +0900
comments: true
categories: "book"
---

# 理論から学ぶデータベース実践入門 ~リレーショナルモデルによる効率的なSQL (WEB+DB PRESS plus)
http://www.amazon.co.jp/dp/4774171972

# SQL実践入門──高速でわかりやすいクエリの書き方 (WEB+DB PRESS plus)
http://www.amazon.co.jp/dp/4774173010

# Webエンジニアのための データベース技術[実践]入門 (Software Design plus)
http://www.amazon.co.jp/dp/4774150207


特に、index の仕組みのところは集中して読んだ。

# B+Tree
データ構造が木みたいだから。  
頭の中で B+Tree をイメージすると、効果的な index をイメージしやすい。  
あと、前方一致の特徴などからも やはり index は、本の索引をイメージするとわかりやすい。  

# index を貼ることのデメリット
- 更新処理が遅くなる
- データ量が増える

## index をはらない方が良い場合
参照の際に、index を参照してからデータ領域を参照することになるので、データ件数が少ない場合は逆にテーブルフルスキャンの方が速い。  
boolean なカラムのように取りうる値にバラつきが少ないカラムや、大半のレコードに同じ値が入っているカラムには、 index を貼っても効果が少ない。  

# index は前方一致に対してのみ有効

これは index 有効。
`WHERE name LIKE '高田%'`

これは index 効かない。
`WHERE name LIKE '%祐一'`

# 演算や関数にかけてしまうと index は効かない

col1 に index を貼っていても、下記のクエリは index が効かない。

`WHERE col1 * 10 > 123`

index を効かせたい場合は、こうする。

`WHERE col1 > 123 / 10`

# マルチカラムインデックスでは、カラムの順番も意味がある

これに対して、 (col1, col2) な index は効かない。(col2, col1) な index を貼る必要がある。前方一致な事を思い出す。

`WHERE col1 > 100 AND col2 = 3`

# index オンリースキャン

index を貼ると、index をまず見てから、データ領域を参照する事になる。
しかし、index の参照だけで取得できるようなクエリだと、データ領域への参照が必要無いのでさらに高速になる。

(col1, col2) というindex を貼ってあるテーブル tbl に対して、下記のクエリを発行すると、index の参照だけで済む。
`SELECT col1 FROM tbl WHERE col1 = 1 AND col2 > 100;`

集計関数の場合も、うまく使えば index だけで済ませられる。

`SELECT COUNT(1) FROM tbl WHERE col1 = 1 AND col2 > 100;`


# まとめ
index という概念が導入される前の hiveQL を長年使っていたので、 SQL は書けるけど index に対しては理解弱かったので、勉強になった。  
