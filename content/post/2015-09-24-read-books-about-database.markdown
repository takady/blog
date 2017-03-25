---
categories: book
comments: true
date: 2015-09-24T18:43:39Z
title: WEB+DB PRESS plus の DB 本 3冊を読んで index を学んだ
url: /blog/2015/09/24/read-books-about-database/
---

シルバーウィークに、この3冊を読んだ。  

- [Webエンジニアのための データベース技術[実践]入門 (Software Design plus)](http://www.amazon.co.jp/gp/product/4774150207/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=4774150207&linkCode=as2&tag=takadayuichi-22)

  - RDBMS としては mysql を題材にしている。
  - インデックスから my.cnf の項目の説明や mysql のソースコードを読む所まで、 mysql をメインに書かれている。


- [理論から学ぶデータベース実践入門 ~リレーショナルモデルによる効率的なSQL (WEB+DB PRESS plus)](http://www.amazon.co.jp/gp/product/4774171972/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=4774171972&linkCode=as2&tag=takadayuichi-22)

  - RDBMS の構造や設計についても書かれていて、正規化理論や NULL について、またインデックスの設計戦略までカバーされている。
  - 個別の RDBMS 製品に偏った記載はほぼ無い。
  - 著者は、[漢(オトコ)のコンピュータ道](http://nippondanji.blogspot.jp/) の人。


- [SQL実践入門──高速でわかりやすいクエリの書き方 (WEB+DB PRESS plus)](http://www.amazon.co.jp/gp/product/4774173010/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=4774173010&linkCode=as2&tag=takadayuichi-22)

  - SQL と実行計画を主軸に、効果的な SQL の書き方、実行計画の見方などについて書かれている。
  - クエリと実行計画のサンプルには、 Oracle と PostgresQL のものが使われている。

特に index について知りたかったのでその辺まとめとく。  

# B+Tree
RDBMS の index で最も使われている。  
データ構造が木みたいに、ルート、ブランチ、リーフから成っている。  
B+Tree は B-Tree と違って、必ずリーフノードに値を持つ。ブランチノードがコンパクトになり、検索の効率が良いらしい。  

# index を貼ることのデメリット
- 更新処理が遅くなる
- データ量が増える

# index をはらない方が良いケース
- データ件数が少ないテーブル
  - index を参照してからデータ領域を参照することになるので、データ件数が少ない場合は逆にテーブルフルスキャンの方が速い。  

- 値のばらつきが少ないカラム
  - boolean なカラムのように取りうる値にバラつきが少ないカラムや、大半のレコードに同じ値が入っているカラムには、 index を貼っても効果が少ない。逆に、1件に絞り込めるような値が入っているカラムは、インデックスが有効に作用する。  
  - 値のバラつきのことをカーディナリティ（集合の濃度）という。  


# index は前方一致に対してのみ有効

これは index 有効。

```sql
SELECT * WHERE name LIKE '高田%';
```

これは index 効かない。

```sql
SELECT * WHERE name LIKE '%祐一';
```

# 演算や関数にかけてしまうと index は効かない

col1 に index を貼っていても、下記のクエリは index が効かない。

```sql
SELECT * WHERE col1 * 10 > 123;
```

index を効かせたい場合は、こうする。

```sql
SELECT * WHERE col1 > 123 / 10;
```

# マルチカラムインデックスでは、カラムの順番も意味がある

下記のクエリに対して効果的な index は、(col1, col2) ではなく (col2, col1) な index である。  
index が前方一致な事を思い出す。  

```sql
SELECT * WHERE col1 > 100 AND col2 = 3;
```

# index オンリースキャン

index を貼ると、index を見てから、データ領域を参照する事になる。  
しかし、index の参照だけで取得できるようなクエリだと、データ領域への参照が必要無いのでさらに高速になる。  
(col1, col2) というindex を貼ってあるテーブル tbl に対して、下記のクエリを発行すると、index の参照だけで済む。  

```sql
SELECT col1, col2 FROM tbl WHERE col1 = 1 AND col2 > 100;
```

集計関数の場合も、うまく使えば index だけで済ませられる。

```sql
SELECT COUNT(1) FROM tbl WHERE col1 = 1 AND col2 > 100;
```


# B+Tree はキーの順にソートされて格納されている
index のキーはソートされているので、name に index があるテーブルに、下記のようなクエリを発行すると範囲検索とソートの両方にインデックスが使われるので高速。  

```sql
SELECT * FROM tbl WHERE name LIKE '高田%' ORDER BY name;
```

# まとめ
index という概念が導入される前の hiveQL を長年使っていたので、 SQL は書けるけど index に対しては理解弱かったので、勉強になった。  
頭の中で B+Tree をイメージすると、効果的な index をイメージしやすい気がする。  
あと、前方一致の特徴などからも やはり index は、本の索引をイメージするとわかりやすい。  

<br>
<br>
<br>

<iframe src="http://rcm-fe.amazon-adsystem.com/e/cm?t=takadayuichi-22&o=9&p=8&l=as1&asins=4774150207&ref=qf_sp_asin_til&fc1=000000&IS2=1&lt1=_blank&m=amazon&lc1=0000FF&bc1=000000&bg1=FFFFFF&f=ifr" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>

<iframe src="http://rcm-fe.amazon-adsystem.com/e/cm?t=takadayuichi-22&o=9&p=8&l=as1&asins=4774171972&ref=qf_sp_asin_til&fc1=000000&IS2=1&lt1=_blank&m=amazon&lc1=0000FF&bc1=000000&bg1=FFFFFF&f=ifr" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>

<iframe src="http://rcm-fe.amazon-adsystem.com/e/cm?t=takadayuichi-22&o=9&p=8&l=as1&asins=4774173010&ref=qf_sp_asin_til&fc1=000000&IS2=1&lt1=_blank&m=amazon&lc1=0000FF&bc1=000000&bg1=FFFFFF&f=ifr" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>

