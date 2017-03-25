---
categories: terminal tmux
comments: true
date: 2015-04-20T16:54:18Z
title: tmuxにpowerlineを導入した
url: /blog/2015/04/20/powerline-config/
---

# powerlineの導入
下記の記事を参考にした．  
[tmux - Powerline導入例 - Qiita](http://qiita.com/tkhr/items/8cc17c02dea1803be9c6)  

## フォントが綺麗に表示されない場合
自分の環境では，`brew reinstall --powerline --vim-powerline ricty`でpowerline用のRictyを入れても綺麗に表示されなかったので，自分でfontを合成した．  

    $ git clone https://github.com/yascentur/Ricty.git
    $ cd Ricty
    
    $ git clone https://github.com/powerline/fonts.git
    
    $ wget http://sourceforge.jp/frs/redir.php\?m\=jaist\&f\=%2Fmix-mplus-ipa%2F59022%2Fmigu-1m-20130617.zip -O migu-1m-20130617.zip
    $ unzip migu-1m-20130617.zip
    $ ./ricty_generator.sh fonts/Inconsolata/Inconsolata\ for\ Powerline.otf migu-1m-20130617/migu-1m-regular.ttf migu-1m-20130617/migu-1m-bold.ttf
    
    $ cp -f ./Ricty*.ttf ~/Library/Fonts
    $ fc-cache -vf

# カスタマイズ
デフォルトは水色．  
![before](/images/powerline_config_01.png)  

[powerline/configuration.rst](https://github.com/powerline/powerline/blob/develop/docs/source/configuration.rst)に設定方法は書いてある．  
カスタマイズしたいconfigファイルを`powerline/config_files`から`~/.config/powerline`以下にパスそのままにコピーしてきて，それを編集する．  

    $ mkdir -p ~/.config/powerline/colorschemes/tmux
    $ cp -i powerline/config_files/colorschemes/tmux/default.json ~/.config/powerline/colorschemes/tmux/.

## ~/.config/powerline/colorschemes/tmux/default.json

例えば色を変えてみる．  
色は`powerline/config_files/colors.json`に定義されているものも使える．  

```json
{
  "groups": {
    "active_window_status": {"fg": "gray70", "bg": "gray0",       "attrs": []},
    "window:current":       {"fg": "black",  "bg": "brightgreen", "attrs": []},
    "window_name":          {"fg": "black",  "bg": "brightgreen", "attrs": ["bold"]},
    "session:prefix":       {"fg": "black",  "bg": "brightgreen", "attrs": ["bold"]}
  }
}
```

### 修正後
![after](/images/powerline_config_02.png)  


# その他
ちなみに，tmuxの設定をreloadするために毎回tmuxを再起動するのは面倒なので，`.tmux.conf`に下記のように設定を再読み込みするよう定義しておくと捗る．  

```text
bind C-r source-file "${HOME}/.tmux.conf"
```


# まとめ
もっとこだわるなら表示する情報とかもカスタマイズできるので，やりたくなったらやるつもり．  

# 参考
- [powerline/configuration.rst at develop · powerline/powerline](https://github.com/powerline/powerline/blob/develop/docs/source/configuration.rst)
- [takady/dotfiles](https://github.com/takady/dotfiles)
