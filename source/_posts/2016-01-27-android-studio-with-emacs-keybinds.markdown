---
layout: post
title: "Android Studio で emacs キーバインドでコードを書く"
date: 2016-01-27 23:15:54 +0900
comments: true
categories: android
---

Android Studio でコードを書こうと思ったのだが、キーバインドが全然しっくり来なくて嫌になりそうだったのでキーバインドの設定をはじめにした。  
Android Studio には、Emacs キーバインドの設定が元々用意されているのでそれを使った。  
普段は Karabinar を使って Emacs キーバインドにしているからそれで良いかとも思ったけど、IDE 側のキーバインドと競合したりしてつらいので Android Studio の時は Karabinar が OFF になるようにして Android Studio のキーバインド設定を使うことにした。  

まず Karabinar の Emacs キーバインドの設定を Android Studio の時は無効になるようにする。  
[ここの設定](https://github.com/tekezo/Karabiner/blob/version_10.15.0/src/core/server/Resources/replacementdef.xml#L104-L114) を private.xml でこんな感じに上書きした。  

```xml
  <replacementdef>
    <replacementname>EMACS_MODE_IGNORE_APPS</replacementname>
    <replacementvalue>
      EMACS,
      REMOTEDESKTOPCONNECTION,
      TERMINAL,
      VI,
      VIRTUALMACHINE,
      X11,
      ANDROID_STUDIO,
    </replacementvalue>
  </replacementdef>
```

書き換えたら Karabinar の Preference で Reload XML すれば設定が反映される。  
次に Android Studio の Preference > Keymap で `Keymaps: Emacs` に設定すれば OK。  
