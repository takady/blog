---
categories: ruby tmux
comments: true
date: 2015-04-24T13:11:11Z
title: bundle openでtmuxのpaneを開く
url: /blog/2015/04/24/bundle-open-tmux/
---

`bundle open`でgemのソースをエディタで開いたり，`bundle show`でgemのパスを見たりすることができるので，gemの挙動を知りたくてコードを見たい時にこれらのコマンドをよく使ってる．  
便利なんだけど，gemのディレクトリがtmuxのペインで開いてくれるともっと使いやすいと思って，やってみた．  

```sh
export BUNDLER_EDITOR="tmux split-window -c"
```

上記を`~/.zshrc`あたりに定義して，コマンドラインで`bundle open`を実行すれば，tmuxのpaneが開いてそのgemのディレクトリを見ることができる．  

    $ bundle open activerecord

# bundle openを上書きしたくない場合
`bundle open`の挙動はそのまま残したいという場合には，`BUNDLER_EDITOR`で設定するのではなく，下記のような関数を別途定義して使うと良い．

```sh
function bundle_open_tmux() {
    if [ -n "$1" ]; then
        local dir=$(bundle show "$1")
        tmux split-window -c "$dir"
    fi
}
```

下記のように実行すると，同じように動作する．

    $ bundle_open_tmux activerecord


# 参考
- [Rebuild: 41: Kids These Days Don't Know Shell (Naoya Ito)](http://rebuild.fm/41/)
