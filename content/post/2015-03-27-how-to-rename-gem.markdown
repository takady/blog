---
categories: ruby
comments: true
date: 2015-03-27T00:56:07Z
title: rubygems.orgに公開しているgemの名前を変更する
url: /blog/2015/03/27/how-to-rename-gem/
---

必要になったので調べてみた．  
結論からいうと，renameはできない．ちなみにgithubのrepositoryはrenameできる．  
調べた結果，自分は下記の方法をとった．  

1. 新しい名前のgemのコードを用意する．既存repositoryをrenameする場合は，.gemspecなど漏れなく修正する．
1. 新しい名前のgemを`rake release`する．
1. `gem yank`で古い名前のgemをindexから外す．

`gem yank`してもrubygems.org上のページは残るのでその点注意．  

# 参考
- [Removing a published RubyGem / Gemcutter / Knowledge Base - RubyGems.org Support](http://help.rubygems.org/kb/gemcutter/removing-a-published-rubygem)

- [公開した gem を削除する方法 - ヽ( ・∀・)ノくまくまー - s21g](http://blog.s21g.com/articles/1755)

