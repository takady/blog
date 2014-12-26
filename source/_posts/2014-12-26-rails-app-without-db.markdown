---
layout: post
title: "DBを使わないrailsアプリケーションの初期設定"
date: 2014-12-26 17:28:02 +0900
comments: true
categories: rails
---
外部のweb apiをマッシュアップするだけのrailsアプリケーションを作りたい時に、DBを使わない、つまりactive_recordを使わない事がある。  
その場合は、config/以下のファイルから下記のactive_record用の記述を削除する。  

# config/application.rb

    -  require "active_record/railtie"
    
    -  # Do not swallow errors in after_commit/after_rollback callbacks.
    -  config.active_record.raise_in_transactional_callbacks = true


# config/environments/development.rb

    -  # Raise an error on page load if there are pending migrations.
    -  config.active_record.migration_error = :page_load


# config/environments/production.rb

    -  # Do not dump schema after migrations.
    -  config.active_record.dump_schema_after_migration = false

# config/database.yml
削除する
