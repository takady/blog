---
layout: post
title: "はじめてのcoreos/rocket"
date: 2015-01-13 19:46:35 +0900
comments: true
categories: coreos
---

rocketとは,ざっくり言うとCoreOS社が開発しているDockerのalternative実装で, まだprototypeという位置づけである.  
[rocket/getting-started-guide.md at master · coreos/rocket](https://github.com/coreos/rocket/blob/master/Documentation/getting-started-guide.md)を通して,rocketをCoreOS上で動かしてみた.  

# vagrantでCoreOSのVMを用意
まず,CoreOSの環境を用意する.

    $ git clone https://github.com/coreos/coreos-vagrant/
    $ cd coreos-vagrant
    $ vagrant up
    $ vagrant ssh
    Last login: Tue Jan 13 08:50:19 2015 from 10.0.2.2
    CoreOS alpha (557.0.0)
    core@core-01 ~ $

# rkt, actool, goのinstall

## rkt

    core@core-01 ~ $ wget https://github.com/coreos/rocket/releases/download/v0.1.1/rocket-v0.1.1.tar.gz
    core@core-01 ~ $ tar zxf rocket-v0.1.1.tar.gz

## actool

    core@core-01 ~ $ wget https://github.com/appc/spec/releases/download/v0.1.1/appc-spec-v0.1.1.tar.gz
    core@core-01 ~ $ tar zxf appc-spec-v0.1.1.tar.gz

## go
[OSX + Vagrant + CoreOSでKubernetesを試してみた - Qiita](http://qiita.com/hnakamur/items/8cda520807f571409f6c#4-1)を参考にした.  
ちなみに, go1.4だと次のhello.goがうまくビルド出来くて, 断念して1.3系を入れた.([参考](https://github.com/coreos/rocket/issues/270))  

    core@core-01 ~ $ wget https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz
    core@core-01 ~ $ sudo mkdir /opt
    core@core-01 ~ $ sudo tar zxf go1.3.3.linux-amd64.tar.gz -C /opt/

## GOPATH等の設定
bash_profileはシムリンクを削除して実ファイルを用意した.

    core@core-01 ~ $ ls -l ~/.bash_profile
    lrwxrwxrwx 1 core core 34 Jan  9 04:47 /home/core/.bash_profile -> ../../usr/share/skel/.bash_profile

    core@core-01 ~ $ rm ~/.bash_profile
    core@core-01 ~ $ cat <<'EOF' >> ~/.bash_profile
    >
    > export GOROOT=/opt/go
    > export GOPATH=~/go
    > export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
    > EOF

    core@core-01 ~ $ mkdir ~/go
    core@core-01 ~ $ exec $SHELL -l
    core@core-01 ~ $ go version
    go version go1.3.3 linux/amd64

# サンプルアプリケーション作成
## hello.goの作成とビルド

```go
package main

import (
    "log"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        log.Printf("request from %v\n", r.RemoteAddr)
        w.Write([]byte("hello\n"))
    })
    log.Fatal(http.ListenAndServe(":5000", nil))
}
```

ビルドする.

    core@core-01 ~ $ CGO_ENABLED=0 GOOS=linux go build -a -tags netgo -ldflags '-w' hello.go

## manifest.jsonの作成

```json
{
    "acKind": "ImageManifest",
    "acVersion": "0.1.1",
    "name": "coreos.com/hello",
    "labels": [
        {
            "name": "version",
            "val": "1.0.0"
        },
        {
            "name": "arch",
            "val": "amd64"
        },
        {
            "name": "os",
            "val": "linux"
        }
    ],
    "app": {
        "user": "root",
        "group": "root",
        "exec": [
            "/bin/hello"
        ],
        "ports": [
        {
            "name": "www",
            "protocol": "tcp",
            "port": 5000
        }
        ]
    }
}
```

validationする.

    core@core-01 ~ $ ./appc-spec-v0.1.1/actool -debug validate manifest.json
    manifest.json: valid ImageManifest

# App Container Image(ACI)のBuild
    core@core-01 ~ $ mkdir -p hello-layout/rootfs/bin
    core@core-01 ~ $ cp -i manifest.json hello-layout/manifest
    core@core-01 ~ $ cp -i hello hello-layout/rootfs/bin/
    core@core-01 ~ $ ./appc-spec-v0.1.1/actool build hello-layout/ hello.aci
    core@core-01 ~ $ ./appc-spec-v0.1.1/actool -debug validate hello.aci
    hello.aci: valid app container image

ちなみに, ACIはtarなので,下記で中身を確認できる.

    core@core-01 ~ $ tar tvf hello.aci
    drwxr-xr-x 500/500           0 2015-01-13 10:26 rootfs
    drwxr-xr-x 500/500           0 2015-01-13 10:26 rootfs/bin
    -rwxr-xr-x 500/500     4383427 2015-01-13 10:26 rootfs/bin/hello
    -rw-r--r-- root/root       510 2015-01-13 10:27 manifest

# ACIの起動
ここでcontainerを起動し,helloアプリがhttpリクエストを受けられる状態になる.  
ちなみに,containerを落としたい時は`ctrl-]`を3回押す.  

    core@core-01 ~ $ sudo ./rocket-v0.1.1/rkt --debug run hello.aci
    2015/01/13 10:27:43 Unpacking stage1 rootfs
    2015/01/13 10:27:43 Writing stage1 init
    2015/01/13 10:27:43 Wrote filesystem to /var/lib/rkt/containers/5c59cdfd-648a-421f-8390-74f8cea7306c
    2015/01/13 10:27:43 Loading image sha256-9454dfc3433953623bbe91fe09608a4dd44a7d21dbb9da093adb2f9d44f97005
    2015/01/13 10:27:43 Writing container manifest
    2015/01/13 10:27:43 Pivoting to filesystem /var/lib/rkt/containers/5c59cdfd-648a-421f-8390-74f8cea7306c
    2015/01/13 10:27:43 Execing stage1/init
    Spawning container stage1 on /var/lib/rkt/containers/5c59cdfd-648a-421f-8390-74f8cea7306c/stage1.
    Press ^] three times within 1s to kill container.
    Timezone UTC does not exist in container, not updating container timezone.
    systemd 215 running in system mode. (-PAM -AUDIT -SELINUX +IMA -SYSVINIT +LIBCRYPTSETUP -GCRYPT -ACL -XZ +SECCOMP -APPARMOR)
    Detected virtualization 'systemd-nspawn'.
    Detected architecture 'x86-64'.
    
    Welcome to Linux!
    
    Initializing machine ID from container UUID.
    [  OK  ] Created slice -.slice.
    [  OK  ] Created slice system.slice.
             Starting Graceful exit watcher...
    [  OK  ] Started Graceful exit watcher.
             Starting coreos.com/hello...
    [  OK  ] Started coreos.com/hello.
    [  OK  ] Reached target Rocket apps target.


## アクセスしてみる
    core@core-01 ~ $ curl 127.0.0.1:5000
    hello

## アクセスログが表示される

    2015/01/13 10:31:30 request from 127.0.0.1:36742


# 環境
## OSX
- OSX 10.9.5
- Vagrant 1.6.5

## CoreOS
- CoreOS alpha (557.0.0)
- go 1.3.3

# 参考
- [rocket/getting-started-guide.md at master · coreos/rocket](https://github.com/coreos/rocket/blob/master/Documentation/getting-started-guide.md)
- [kelseyhightower/rocket-tutorial](https://github.com/kelseyhightower/rocket-tutorial)
- [CoreOS - はじめてのRocket - Qiita](http://qiita.com/mopemope/items/9f163e4715a8bb5846e9)
- [CoreOS 入門 - Qiita](http://qiita.com/mopemope/items/fa9424b094aae3eac580)
- [Vagrant + CoreOS + Docker でコンテナ環境体験 - Qiita](http://qiita.com/gom/items/0bfc1925a7fddfcdfdaf)
