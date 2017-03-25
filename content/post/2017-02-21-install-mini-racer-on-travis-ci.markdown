---
categories: rails
comments: true
date: 2017-02-21T23:07:09Z
title: Travis CI で mini_racer と mysql を使うビルドが失敗する
url: /blog/2017/02/21/install-mini-racer-on-travis-ci/
---

rails プロジェクトの CI に Travis CI を利用しているが、ある日 mini_racer を Gemfile に追加してビルドを試みたところ、bundle install で `Gem::Ext::BuildError: ERROR: Failed to build gem native extension.` なエラーが出てしまった。

Travis CI のデフォルトの環境では mini_racer が入らないってことのようで、[mini_racer の README.md](https://github.com/discourse/mini_racer#travis-ci) には下記の対応方法が記載されている。  

    sudo: required
    dist: trusty

これで実際に、mini_racer は install 出来るようになる。  

ただ、rails のプロジェクトの DB として mysql を使っていたため、新たに別の問題が発生する。  
2017年2月の時点で、[Trusty の環境には mysql が入ってない](https://docs.travis-ci.com/user/trusty-ci-environment/#Data-Stores)ので `rake db:migrate` あたりで DB に接続できませんということでビルドが失敗する。  

[この辺の issue](https://github.com/travis-ci/travis-ci/issues/6842#issuecomment-278601433) など参考にしながら、ひとまず mysql を自分で入れるってことと、mysql の接続ユーザを `root` にする事で回避した。  

    dist: trusty
    sudo: required
    addons:
      apt:
        packages:
        - mysql-server-5.6
        - mysql-client-core-5.6
        - mysql-client-5.6

きびしい。

## 参考
- https://github.com/discourse/mini_racer#travis-ci
- ["Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock'" · Issue #6842 · travis-ci/travis-ci](https://github.com/travis-ci/travis-ci/issues/6842#issuecomment-278601433)
