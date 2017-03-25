---
categories: rails
comments: true
date: 2015-11-29T23:06:56Z
title: rails で /users/:id ではなく /:username な routing にする方法
url: /blog/2015/11/29/rails-routing-with-username-instead-of-id/
---

rails で普通に scaffold すると id が URL に入って `example.com/users/:id` となる。  
これを `twitter.com/takady7` とか `github.com/takady` みたいにしたい時がある。  
実現には 2 通りの方法があると思われる。  

# to_param を使う方法
activerecord に [to_param](http://railsdoc.com/references/to_param) というメソッドがあって、これを使うと URL の :id の部分に id 以外を指定できるようになる。  

## user.rb
```ruby
class User < ActiveRecord::Base
  validates_presence_of :username
  validates_uniqueness_of :username, case_sensitive: false

  def to_param
    username
  end
end
```

## users_controller.rb
```ruby
class UsersController < ApplicationController
  def show
    @user = User.find_by(username: params[:id])
  end
end
```

## routes.rb
```ruby
Rails.application.routes.draw do
  resources :users, path: '/', only: [:show, :edit, :update, :destroy]
end
```

    $ rake routes
        Prefix Verb   URI Pattern                        Controller#Action
     edit_user GET    /:id/edit(.:format)                users#edit
          user GET    /:id(.:format)                     users#show
               PATCH  /:id(.:format)                     users#update
               PUT    /:id(.:format)                     users#update
               DELETE /:id(.:format)                     users#destroy


# routing で param を設定する方法

User クラスに to_param を定義せずに、 routes.rb で設定する方法。  
`params[:username]` というふうに渡ってくるので、こちらの方が素直な気がして個人的にはこちらを使いたい。  

## users_controller.rb
```ruby
class UsersController < ApplicationController
  def show
    @user = User.find_by(username: params[:username])
  end
end
```


## routes.rb
```ruby
Rails.application.routes.draw do
  resources :users, param: :username, path: '/', only: [:show, :edit, :update, :destroy]
end
```

    $ rake routes
        Prefix Verb   URI Pattern                        Controller#Action
     edit_user GET    /:username/edit(.:format)          users#edit
          user GET    /:username(.:format)               users#show
               PATCH  /:username(.:format)               users#update
               PUT    /:username(.:format)               users#update
               DELETE /:username(.:format)               users#destroy


# 参考
- [ruby - Rails route to username instead of id - Stack Overflow](http://stackoverflow.com/questions/7735315/rails-route-to-username-instead-of-id)
- [to_param - リファレンス - - Railsドキュメント](http://railsdoc.com/references/to_param)
- [Github みたいにパスの最初のセグメントでユーザー名を使う方法 - present](http://tnakamura.hatenablog.com/entry/2014/01/31/185214)
