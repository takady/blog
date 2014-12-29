---
layout: post
title: "facebook graph apiのAccess Tokenを取得するまで"
date: 2014-12-29 17:45:20 +0900
comments: true
categories: ruby
---
OAuth2について、わかってたつもりでわかってないので、  
[nov/fb_graph](https://github.com/nov/fb_graph)を通して、facebook graph apiでAccess Tokenを発行するところまでを追ってみた  

# TL;DR
この面倒なtoken生成作業は、[https://developers.facebook.com/](https://developers.facebook.com/)のTools > Graph API Explorerで、  
Get Access Tokenとボタンを押すと生成できるので、すぐtokenを生成したいのなら、下記を読まずにそこから生成するのが楽で良い

# 1.まずfacebookにappを登録
[https://developers.facebook.com/](https://developers.facebook.com/)のApps > Add a New Appで作成できる  
この時、リダイレクト先URLも下記から設定しておくこと  
Settings > Advanced > Security > Valid OAuth redirect URIs  

# 2.App IDとApp Secretを確認
先ほど作成したAppのDashboardに行って確認できる  

# 3.client_idとredirect_url付きのGETリクエストを送信
下記のようにリクエストする  

    GET https://graph.facebook.com/oauth/authorize?client_id=<Your App ID>&redirect_uri=<Your Redirect URL>

# 4.リダイレクトされたurlのAuthorization Codeパラメータの値を確認
下記のような感じである  

    http://example.com?code=<Your Authorization Code>

# 5.POSTリクエストを送信してAccess Tokenを取得
取得したAuthorization Codeを含め、パラメータとして下記をセットしてPOSTでリクエストする  

    POST https://graph.facebook.com/oauth/access_token

     grant_type: authorization_code
     code: <Your Authorization Code>
     redirect_uri: <Your Redirect URL>
     client_id: <Your App ID>
     client_secret: <Your App Secret>

レスポンスのbodyは下記のようになっている  

    access_token=<Your Access Token>  

この生成されたaccess_tokenを使って、facebook graph apiを利用する事ができる  

# 6.Access Tokenの有効期限を伸ばす
facebook graph apiの場合、このままだとAccess Tokenの有効期限が短すぎる  
下記のGETリクエストを送ることで、有効期限を60日間に伸ばす事ができる  

    GET https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&client_id=<Your App ID>&client_secret=<Your App Secret>&fb_exchange_token=<Your Access Token>  

# まとめ
OAuth2、Access Token取得後はそれだけでAPIとやりとりできるからシンプルで良いけど、Access Tokenを取得するまでがめんどくさい  
Facebookでは上記フローだが、twitterとかgithubとか他のサービスもまったく同じなわけじゃないので、他も触ってみたい  

# 参考
[ruby - Obtaining a Facebook auth token for a command-line (desktop) application - Stack Overflow](http://stackoverflow.com/questions/21978728/obtaining-a-facebook-auth-token-for-a-command-line-desktop-application)  
[Rebuild: 43: Kent is More Professional (Kenn Ejima)](http://rebuild.fm/43/)  
[Home · nov/fb_graph Wiki](https://github.com/nov/fb_graph/wiki)  
[公開中のFacebook EventをGraph APIから取得する - 酒と泪とRubyとRailsと](http://morizyun.github.io/blog/facebook-event-api-ruby-fb_graph/)  
