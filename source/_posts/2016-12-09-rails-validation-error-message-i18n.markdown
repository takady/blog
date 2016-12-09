---
layout: post
title: 'rails の validation error message の i18n 対応'
date: 2016-12-09 21:20:43 +0900
comments: true
categories: rails
---

rails で Custom validatior や Custom validation method を定義して、その中で `errors.add` する際に、
message として使われる I18n のパスをどう書くのが良いのかっていうのが気になった。  
結論としては、下記のように書くのがスッキリして良さそう。  

## Custom Validators

特定のモデルによらないエラーメッセージの場合は、下記のように `locales/en.yml` を書くことで、`record.errors.add(attribute, :something_invalid)`と書ける。  

```yml
en:
  errors:
    messages:
      something_invalid: Invalid something.
```

```ruby
class MyCheckValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless check_something(value)
      record.errors.add(attribute, :something_invalid)
      #=> record.errors.add(attribute, I18n.t('errors.messages.something_invalid')) と同じ
    end
  end

  def check_something(value)
   # Something
  end
end

class MyModel < ActiveRecord::Base
  validates :name, my_check: true
end
```

## Custom Methods

特定のモデルの特定の項目のエラーメッセージの場合は、下記のようにymlを書くことで、適切にメッセージを参照してくれる。

```yml
en:
  activerecord:
    errors:
      models:
        my_model:
          attributes:
            start_date:
              cannot_be_after_end_date: It cannot be after the end date.
            end_date:
              cannot_be_before_start_date: It cannot be before the start date.
```

```ruby
class MyModel < ActiveRecord::Base
  validate :start_date_cannot_be_after_end_date, if: -> { start_date.present? && end_date.present? }

  private

  def start_date_cannot_be_after_end_date
    return if start_date <= end_date

    errors.add(:start_date, :cannot_be_after_end_date)
    #=> errors.add(:start_date, I18n.t('activerecord.errors.models.my_model.attributes.start_date.cannot_be_after_end_date')) と同じ
    errors.add(:end_date, :cannot_be_before_start_date)
    #=> errors.add(:end_date, I18n.t('activerecord.errors.models.my_model.attributes.end_date.cannot_be_before_start_date')) と同じ
  end
end
```

### 参考
- [Active Record Validations — Ruby on Rails Guides](http://guides.rubyonrails.org/active_record_validations.html)
