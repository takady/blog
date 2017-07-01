+++
Description = ""
Tags = []
date = "2017-07-01T17:28:33+09:00"
title = "Reactビギナーズガイド を読んだ"

+++

<a target="_blank"  href="https://www.amazon.co.jp/gp/product/4873117887/ref=as_li_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=4873117887&linkCode=as2&tag=takadayuichi-22&linkId=7f4e6601420eec8bc27438573ff786fa"><img border="0" src="//ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&MarketPlace=JP&ASIN=4873117887&ServiceVersion=20070822&ID=AsinImage&WS=1&Format=_SL250_&tag=takadayuichi-22" >
<p>Reactビギナーズガイド ―コンポーネントベースのフロントエンド開発入門</p>
</a>

React はプライベートで書いているけども、一度ちゃんと基礎を抑えておきたいので読んだ。  
本書を読む前に、どこかのサイトでの本書のレビューとして、`React.createClass` を使った古い書き方が一部あって云々みたいな記述を見かけていたので若干内容が古いのかなと思っていた。  
ただ実際に読んでみると、前半はたしかに class を使った書き方をしていないが、これはトランスパイル無しでブラウザで React をまずは動かそうという主旨もあり es2015 の記法を使っていないだけなのかなと思った。後半ではちゃんと babel でトランスパイルして es2015 以降の class を使った書き方をしている。  

本書が良いのは、著者が Facebook に所属している React の開発者の人というところで、おかげで安心して読める。  
今まで React を書く時に、サードパーティーの npm パッケージは使うべきかどうかが判断出来なくて使っていなかったけど、例えば [classnames](https://github.com/JedWatson/classnames) については本書でも利用されているので、今後使っていこうという気になった。  
他にも、flow でカスタムの型を使えば React の propTypes は不要になるし実行時の型チェックが不要になる分、処理速度に良い影響があるなど、実践的でどういうメリットがあるかまで説明されている。  
広く使われているから使った方がいいのかなくらいに思っていた周辺ライブラリやツールについて、使う動機を示してくれているのが良かった。  

その他にも、いくつかの慣例などについても触れられていて、ネットで細切れの情報をかき集めて学ぶだけではなかなか把握しづらいところも、やはり本で体系的に学ぶことで得られるものは多かった。  
