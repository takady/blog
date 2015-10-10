---
layout: post
title: "#isucon 5 予選で惨敗してきました"
date: 2015-09-29 00:05:00 +0900
comments: true
categories: 
---

isucon5 予選で惨敗しました。

# 出場の動機
isucon というものの存在を知ってから、とにかく出てみたいと思っていた。  
年初くらいには [@tatsuyaoiw](https://twitter.com/tatsuyaoiw) に声を掛け快諾してくれていた。  

<blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr"><a href="https://twitter.com/takady7">@takady7</a> 出ましょう！ってまだだいぶ先じゃない？</p>&mdash; Tatsuya Oiwa (@tatsuyaoiw) <a href="https://twitter.com/tatsuyaoiw/status/565119787735330816">2015, 2月 10</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<br>

予選の募集が始まった頃、あと一人誰誘おうと話してて、[@tatsuyaoiw](https://twitter.com/tatsuyaoiw) が [@muratayusuke](https://twitter.com/muratayusuke) を誘って、前職の同期3人で出ることが決定。  
ちなみにチーム名の「八潮パークタウン」は、前職の会社の近くのバス停に停まるバスの行き先の名前で、たぶん3人の誰も実際に行ったことはない。  

# 準備期間
予選のちょうど1週間前の土曜日に一度集まって、その時に主に isucon 関連の知見を晒し合った。  
あと google cloud platform を触ってみたり、過去問をやったりした。  
その後の1週間は、 bitbucket のリポジトリに各々が調べた sysctl やら tcpdump やら mysql やら nginx やらの設定やコマンドなどを md ファイルでとにかく上げて集めていった。この過程で、カーネルやネットワーク、DB 関連の知識が結構増えた。  
このリポジトリを当日もかなり参考にしながら作業をしたので、とても役立った。  
連絡は slack でとっていた。  
個人的な反省点としては、いわゆる定石な実装をもっと試しておけば良かったと思っている。  
例えば mysql にデータを入れている処理を redis に載せ替える実装とか、一度過去問でやっておけば当日もやれたはずだけど、当日はその辺自信なく積極的に担当出来なかった。  

# 予選当日の朝
[@tatsuyaoiw](https://twitter.com/tatsuyaoiw) 邸に集まって作業した。  
最寄り駅に着いた頃に、開始が１時間遅れる事がアナウンスされた。  

<blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr">準備の兼ね合いで開始を1時間遅らせて11時開始、19時終了とします。寸前で申し訳ないですが宜しくお願いします。 <a href="https://twitter.com/hashtag/isucon?src=hash">#isucon</a></p>&mdash; くしい (@941) <a href="https://twitter.com/941/status/647570963026935808">2015, 9月 26</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

ちなみに、完璧な環境を用意してくれてた。  

![](/images/posts/image4.png =400x)  

# 予選
開始前にちょろっと最初に手を付けることをお互い話してて、git init やら nginx の設定やら mysql のスロークエリの設定を分担してやった。  
ちなみに、最初 `/etc/my.cnf` が読み込まれなくて地味に設定に手間取った。  
結果的に、 `/etc/mysql/conf.d/my.cnf` を作りそこに設定を書いた。  
終了後に知ったけど、 AppArmor の設定のせいだった。  

<br>
![](/images/posts/image2.png =600x)  
<br>


お題の web アプリは、`ISUxi` という mixi のようなサービスだった。  

<br>
![](/images/posts/image3.png =600x)  
<br>


最初の ruby 実装のスコアは200ちょっとくらい。  
最初のベンチが走った後は、出力された slow query を mysqldumpslow でサマって時間食ってるクエリを見て、「ここ index はるね」とか言って貼ったりして、スコアは 400 くらいに。  
あと [@tatsuyaoiw](https://twitter.com/tatsuyaoiw) による nginx 関連の設定、静的ファイルを nginx から返す設定などが入った。  
ここで [@muratayusuke](https://twitter.com/muratayusuke) が unicorn の worker 数を 8 に増やしたところスコアが 2000 まで上がる。ここで暫定4位に！  

そのあと、重いクエリの内、footprints （あしあと）テーブルへのクエリが遅いということで、コードを読み、カレントユーザーID と来訪ユーザーID をつなげたものをキーにして、来訪時間を値に持っておけば redis に持たせられるよねって話しをして、 [@muratayusuke](https://twitter.com/muratayusuke) が実装に取り掛かる。  

nginx の access.log を解析したところトップページが重いということで、`index.erb` で n+1 な処理になっているところがいくつかあったので解消するように修正する作業にとりかかる。  

先に footprints の redis 化が終わり、ベンチマークを回したところスコアが一気に 7000 までに上がる。この時点で暫定3位に！「いけるのでは？？」という期待がチームの中に高まる。  

ちなみに n+1 対応は結果あまり効果なし。（しかもバグってて後で revert した 🙇）  

`ORDER BY created_at` としている部分は `ORDER BY id` で良いじゃん！って事でスコアアップを期待して修正したが、さほどスコア伸びず。  

その後、トップページの html を非同期に生成して redis に入れておくという実装に [@muratayusuke](https://twitter.com/muratayusuke) がチャレンジしている間、1番のスロークエリであるトップページの最新のコメントを取ってくる SELECT 文をどうにか出来ないか試行錯誤してた。  

17時を過ぎた頃に、インスタンス再起動しても問題無く動くかを [@tatsuyaoiw](https://twitter.com/tatsuyaoiw) が確認。  
ちなみに、なぜか再起動前に 10000 を超えていたスコアが、再起動後は 8500 くらいになる。（再起動直後はキャッシュが温まってなかったのか？）  

一応、序盤から気になっていた mysql との接続を port から unixソケットに変える修正をするが効果は +100 くらい。  
もういっちょ気になってた session ストアを cookie から redis に変える修正もやって、 +1000 くらいでスコアは 9700 くらいに。  

終了時刻が迫ってきていて、他チームのスコアがどんどん上がっている中、やはり1番のスロークエリをなんとかするしかないという事で、 [@tatsuyaoiw](https://twitter.com/tatsuyaoiw) と話す中で、 join を無くすためにテーブルスキーマを非正規化する方法を思いつく。ここで残り30分。  
本番機と別のインスタンスでカラム追加とコード修正して OK そうだということで、「頼む〜」とか言いながら期待しつつ本番機にデプロイしてベンチを回すと、スコア 200 とかになって膝から崩れ落ちそうになる。（追加したカラムに初期データを入れてあげないといけなかったのかな多分。）  
結局 revert して、残り10分くらいで [@muratayusuke](https://twitter.com/muratayusuke) のトップページの html の非同期生成の実装が出来上がりデプロイ。が、ベンチが fail してしまう。  
残り2分ほどになり、旧コードに戻してベンチを掛けるが、19時になり、ベンチが間に合ったか不明。  

# まとめ
めちゃくちゃ楽しかったけど、めちゃくちゃ悔しい。  
自分の対応があまりスコアアップに貢献出来なくて残念だった。  
あとローカルでコードを動かせる環境を用意するのが初期データの点からも かなりめんどくさそうだったので、サーバ上でコード修正したりしたけど複数人で並行してやるのは結構気を使ったし、手元で動かせないと動くかの確認が出来なかったり、サーバにはいつもの git コマンドの alias が無くてイラッとしたり、エディタも vim で辛かったりした。この辺上手くできたら良かったな。  

今回は力不足を感じたけど、腕を磨いて来年またチャレンジしたい。  

ちなみに土曜日の予選には131組371人が参加してたらしい。  
運営の方々、決勝も残っていますが、ひとまずお疲れ様でした！ありがとうございました！  
[@tatsuyaoiw](https://twitter.com/tatsuyaoiw) [@muratayusuke](https://twitter.com/muratayusuke) ありがとう！  

# 2015/10/10 追記
2015/10/06(火) に [ISUCON5予選報告会 in GCPUG Tokyo](http://eventdots.jp/event/569858) で isucon5 予選の話を LT してきました。  

<div style="width: 65%">
  <script async class="speakerdeck-embed" data-id="d19476b7e9584f139cc5db92b7dd37f2" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>
</div>
