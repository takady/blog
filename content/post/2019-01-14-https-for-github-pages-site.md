+++
Description = ""
Tags = []
date = "2019-01-14T10:39:16+09:00"
title = "https 対応した"

+++

このブログは [Hugo](https://gohugo.io/) を使っていて、Github pages にホストしているんだけど、https 対応を今更やった。

# hugo 側の設定

## config.toml

```toml
diff --git a/config.toml b/config.toml
index 9aa98a1..4949f9d 100644
--- a/config.toml
+++ b/config.toml
@@ -1,4 +1,4 @@
-baseurl = "http://blog.takady.net/"
+baseurl = "https://blog.takady.net/"
 languageCode = "ja"
 hasCJKLanguage = "true"
 title = "Yuichi Takada"
```

## robots.txt

```
diff --git a/static/robots.txt b/static/robots.txt
index 0752adc..b3f03e0 100644
--- a/static/robots.txt
+++ b/static/robots.txt
@@ -1,4 +1,4 @@
 User-agent: *
 Disallow:

-Sitemap: http://blog.takady.net/sitemap.xml
+Sitemap: https://blog.takady.net/sitemap.xml
```

# Github 側の利用設定
https://help.github.com/articles/securing-your-github-pages-site-with-https/#enforcing-https-for-your-github-pages-site に書いてあるとおり、 `Enforce HTTPS` にチェックを入れる。  


以上。
