---
layout: post
title: rails で FormObject を使う
date: 2016-08-29 19:38:49 +0900
comments: true
categories: rails
---

フォームでは日付の期間を入力し、それを日単位のレコードに保存するようなケースでは、FormObject を使えるかも。やってみた。  

<br />

![](/images/2016-08-29-rails-form-object/screenshot1.png)  

こういうフォーム。  


# Model
uniqueness など Model 単位でバリデーションしなければいけないものや、コンテキストに関係なくバリデーションするものは Model に書く。  

## app/models/foo_day.rb

```ruby
class FooDay < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :date, presence: true, uniqueness: {scope: :user_id}
end
```


# FormObject

FormObject の参考では、よく [virtus](https://github.com/solnic/virtus) を include しているサンプルがあるけど、Virtus の Type cast が効果的に使えそうなケース以外だと特に使わなくて良いかなと個人的に思った。  
例えば今回のケースだと、view から文字列で渡ってくる `YYY-MM-DD` を Date に変換したかったので、一度 Virtus を使ってみたけど、
例えば `2016-08-32` のように Date として解釈できないものが渡ってきた場合に、エラーにならずに文字列のまま変数に格納される挙動だったので、あまり積極的に使う理由が無かった。  
結局、日付の validation のために [validates_timeliness](https://github.com/adzap/validates_timeliness) という gem を使ったけど便利だった。  

## app/models/foo_day/registration_form.rb

```ruby
class FooDay::RegistrationForm
  include ActiveModel::Model

  attr_accessor :user_id, :from_date, :to_date

  validates :user_id, presence: true
  validates :from_date, presence: true, timeliness: {on_or_after: :today, type: :date}
  validates :to_date, allow_blank: true, timeliness: {on_or_after: :from_date, type: :date}

  def save
    return false unless valid?

    persist!
    true
  end

  private

  def foo_days
    @foo_days ||= build_foo_days
  end

  def build_foo_days
    if to_date.blank?
      [FooDay.new(date: from_date, user_id: user_id)]
    else
      (Date.parse(from_date)..Date.parse(to_date)).map {|date| FooDay.new(user_id: user_id, date: date) }
    end
  end

  def valid?
    return false unless super

    foo_days.each do |foo_day|
      next if foo_day.valid?

      foo_day.errors.full_messages.each do |message|
        errors.add(:base, I18n.t('activemodel.errors.invalid_foo_day', date: foo_day.date, message: message))
      end
    end

    return super
  end

  def persist!
    foo_days.each(&:save!)
  end
end
```


# Controller

## app/controllers/foo_days_controller.rb

```ruby
class FooDaysController < ApplicationController
  def new
    @registration_form = FooDay::RegistrationForm.new
  end

  def create
    @registration_form = FooDay::RegistrationForm.new(params[:foo_day_registration_form].merge(user_id: current_user.id))

    if @registration_form.save
      redirect_to new_foo_day_path, notice: '登録に成功しました'
    else
      flash.now[:alert] = '登録に失敗しました'

      render action: :new
    end
  end
end
```

# View

## app/views/foo_days/new.html.haml

```haml
.row
  %h1 日々の登録
  = form_for @registration_form, url: foo_days_path, method: :post do |f|
    - if @registration_form.errors.any?
      %ul
        - @registration_form.errors.full_messages.each do |msg|
          %li= msg

    = f.label '日付'
    = f.date_field :from_date
    %span 〜
    = f.date_field :to_date

    = f.submit '確定'
```


# Translation
## config/locales/ja.yml

```yaml
ja:
  activemodel:
    attributes:
      foo_day/registration_form:
        from_date: 開始日
        to_date: 終了日
    errors:
      invalid_foo_day: '%{date} %{message}'
      models:
        foo_day/registration_form:
          attributes:
            from_date:
              on_or_after: は %{restriction} 以降の日付を指定してください
            to_date:
              on_or_after: は 開始日 以降の日付を指定してください
```

# まとめ
フォームとモデルが1対1で対応しないケースもたまにあるので、その時は FormObject も選択肢の一つになるかも。  

# 参考
- [Creating Form Objects with ActiveModel and Virtus - We build Envato](http://webuild.envato.com/blog/creating-form-objects-with-activemodel-and-virtus/)
- [7 Patterns to Refactor Fat ActiveRecord Models - Code Climate Blog](http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/)
- [Form Object実装メモ - Qiita](http://qiita.com/quattro_4/items/6636efbf58cca13db02a)
- [Rails4でFormオブジェクトを作る際に気をつける3つのポイント｜江の島エンジニアBlog](http://blog.enogineer.com/2014/12/02/rails-form-object/)
