+++
Description = ""
Tags = []
date = "2017-10-28T14:49:00+09:00"
title = "PHP で json の POST request の body を参照するには"

+++

PHP で web アプリケーションを作るに当たって、POST リクエストの body の内容は  `$_POST` に入ってくるというふうに、いろんなドキュメントには書いてある。  

json でやり取りする web api なんかを PHP で作るにあたって、POST された json の内容を取得したい事は多い。  
しかし、`$_POST` を参照しても、中身は空だった。  

公式ドキュメントサイトを見てみると、

> Content-Type に application/x-www-form-urlencoded あるいは multipart/form-data を用いた HTTP リクエストで、 HTTP POST メソッドから現在のスクリプトに渡された変数の連想配列です。
> http://php.net/manual/ja/reserved.variables.post.php

とのこと。つまり、Content-Type が `application/json` の POST リクエストの場合は、`$_POST` には入ってこないらしい。

json の POST request body を参照するには、 `php://input` というストリームを使ってリクエストの生の body を取得する事になる。  
下記のような感じだと思う。  

```php
$params = json_decode(file_get_contents('php://input'), true);  // NOTE 第2引数に true を指定しているのは連想配列にするため
echo $params['title'];
```
