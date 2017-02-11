---
layout: post
title: "Let's Encrypt と Nginx で HTTPS 対応"
date: 2017-02-11 15:53:29 +0900
comments: true
categories:
---

個人的に作ってるサイトを HTTPS 対応させてみた。  
iptable ではまって2時間くらいかかってしまったけども、想像より手軽にできた。  

## Let's Encrypt
https://letsencrypt.jp/

無料で証明書を用意できるので今回利用した。

curl で実行ファイルを取ってきて、適切にオプションを付けて実行すると、対話形式にていくつかの確認に応え、証明書が作成される。  
以下、実行例。  

```
$ sudo certbot-auto certonly --webroot -w /path/to/app/current/public -d example.com --email your_email@example.com
```
webroot に指定したパスの下にファイルが置かれ、そこに対してリクエストを送って確認しているみたいなので、アクセスできるようにしておく必要がある。

これで `/etc/letsencrypt/live/example.com/` 以下に、証明書や秘密鍵が配置されるので(実際にはこれはシンボリックリンクなのだが)、これらのファイルを Nginx の設定で指定する。

## iptables

`/etc/sysconfig/iptables` を見て、80 と同様に 443 も許可されている事を確認しておく。  
されてない場合は追加することになるのだけど、このファイル直接編集は推奨されていないらしいので iptables コマンドで追加する。  
`sudo /sbin/iptables -L` で設定を確認できる。最後に `iptables save` するのを忘れずに。  
あとは iptables を再起動すると反映されるはず。

## Nginx
実際の Nginx の設定は下記のようにした。  
http のリクエストは https にリダイレクトさせるようにした。  
（unicorn を使ってるのでその記述があるが今回の件には直接関係無い。  

```nginx
upstream unicorn {
    server unix:/path/to/app/current/tmp/sockets/unicorn.sock;
}

server {
    listen 80;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com;

    ssl on;
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    access_log /var/log/nginx/example.com.access.log;
    root /path/to/app/current/public;
    try_files $uri @unicorn;

    location ~ ^/assets/ {
        root /path/to/app/shared/public;
    }

    location @unicorn {
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://unicorn;
    }

    location /robots.txt {
        alias /path/to/app/current/public/robots.txt;
    }
}
```

## SSL LABS
https://www.ssllabs.com/ssltest/

SSL の設定確認できるサイト。  
以下のようになればうまくいっている。  

![](/images/2017-02-11-lets-encrypt-with-nginx/screenshot.png =600x)  

## 参考
- [Let's EncryptとAmazon LinuxとNginxでamakan.netをHTTPSに対応させた - Programming](https://programming.wikihub.io/@r7kamura/20160702202711)
- [Linux(CentOS 6) - iptablesの設定を変更し、http、httpsでのアクセスを許可する - r_nobuホームページ](http://nobuneko.com/blog/archives/2013/05/linux_centos_6_iptables_http_https.html)

