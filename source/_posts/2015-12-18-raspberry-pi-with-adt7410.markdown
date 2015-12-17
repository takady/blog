---
layout: post
title: "Raspberry Pi と温度センサーで自宅の温度を可視化"
date: 2015-12-18 00:46:37 +0900
comments: true
categories: 'Raspberry Pi'
---

この記事は [Sansan Advent Calendar 2015](http://qiita.com/advent-calendar/2015/sansan) の 18日目の記事です。  

Raspberry Pi と ADT7410 温度センサーで自宅の温度を測り、 [focusligt](https://github.com/focuslight/focuslight) でグラフにした。  
動機は 2年くらい前に買ったまま放置してた Raspberry Pi に備わっている GPIO のことがずっと気になっていたから。  


# 用意したもの
- Raspberry Pi Model B
- [ADT7410使用 高精度・高分解能 I2C・16Bit 温度センサモジュール](http://akizukidenshi.com/catalog/g/gM-06675/)
- [ブレッドボード BB-801](http://akizukidenshi.com/catalog/g/gP-05294/)
- [ブレッドボード・ジャンパーコード（オス-メス） 15cm（黒）](http://akizukidenshi.com/catalog/g/gC-08932/) x 4本
- <a rel="nofollow" href="http://www.amazon.co.jp/gp/product/B0016VDGIA/ref=as_li_qf_sp_asin_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=B0016VDGIA&linkCode=as2&tag=takadayuichi-22">goot 一般電気用はんだこて KS-30R</a><img src="http://ir-jp.amazon-adsystem.com/e/ir?t=takadayuichi-22&l=as2&o=9&a=B0016VDGIA" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
- <a rel="nofollow" href="http://www.amazon.co.jp/gp/product/B0029LGAJI/ref=as_li_qf_sp_asin_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=B0029LGAJI&linkCode=as2&tag=takadayuichi-22">goot 高密度集積基板用はんだ SD-60</a><img src="http://ir-jp.amazon-adsystem.com/e/ir?t=takadayuichi-22&l=as2&o=9&a=B0029LGAJI" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />



# 工程
まず Raspberry Pi の初期設定をした。  
詳細は割愛するが、RASPBIAN JESSIE の最新版を [Download Raspbian for Raspberry Pi](https://www.raspberrypi.org/downloads/raspbian/) からダウンロードして SD に焼き、本体を起動して設定。  
[公式のインストールガイド](https://www.raspberrypi.org/documentation/installation/installing-images/README.md)を参考にすれば問題ないと思われる。  


次に、温度センサーをブレッドボードにつなぐために、付属のピンヘッダをはんだ付けする。  
小さいので、ブリッジしないように注意する。(15年ぶりくらいにやったけど意外と出来た)  

![](/images/2015-12-18-raspberry-pi-with-adt7410/IMG_5876.JPG)

![](/images/2015-12-18-raspberry-pi-with-adt7410/IMG_5877.JPG)

温度センサーを下記のようにブリッジボード経由で GND, VDD, SDA, SCL につなぐ。  
どのピンが何なのかは [こちら](https://www.raspberrypi.org/documentation/usage/gpio/)で確認。  

![](/images/2015-12-18-raspberry-pi-with-adt7410/ADT7410_raspi_breadboard.png)

![](/images/2015-12-18-raspberry-pi-with-adt7410/IMG_5878.JPG)

そして `/etc/modules` に `i2c-bcm2708` を追記する。  

    pi@raspberrypi:~ $ cat /etc/modules
    # /etc/modules: kernel modules to load at boot time.
    #
    # This file contains the names of kernel modules that should be loaded
    # at boot time, one per line. Lines beginning with "#" are ignored.
    
    i2c-dev
    i2c-bcm2708


`/boot/config.txt` を編集。  

    pi@raspberrypi:~ $ sudo vim /boot/config.txt
    
    device_tree=bcm2708-rpi-b.dtb
    device_tree_param=i2c1=on
    device_tree_param=spi=on


再起動。  

    pi@raspberrypi:~ $ sudo reboot

これでデバイスとつながった。  

    pi@raspberrypi:~ $ sudo /usr/sbin/i2cdetect -y 1
         0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
    00:          -- -- -- -- -- -- -- -- -- -- -- -- --
    10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    40: -- -- -- -- -- -- -- -- 48 -- -- -- -- -- -- --
    50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    70: -- -- -- -- -- -- -- --

温度が取れているようだ。  

    pi@raspberrypi:~ $ sudo i2cdump -y 1 0x48
    No size specified (using byte-data access)
         0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f    0123456789abcdef
    00: 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c    ????????????????
    10: 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c    ????????????????
    20: 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 0c 00    ???????????????.
    30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
    f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................


あとは、 ruby の `i2c-devices` という gem を利用して温度を取得するスクリプトを用意する。  
ちなみに ruby はデフォルトで入っている。  

    pi@raspberrypi:~ $ ruby -v
    ruby 2.1.5p273 (2014-11-13) [arm-linux-gnueabihf]

    pi@raspberrypi:~ $ sudo gem install i2c
    pi@raspberrypi:~ $ sudo gem install i2c-devices

    pi@raspberrypi:~ $ vim adt7410.rb

下記のような簡単なスクリプト。  

```ruby
#!/usr/bin/env ruby

require 'i2c/device/adt7410'
require 'i2c/driver/i2c-dev'

device = I2CDevice::ADT7410.new(driver: I2CDevice::Driver::I2CDev.new('/dev/i2c-1'), address: 0x48)

puts device.calculate_temperature.round
```

実行結果。  

    pi@raspberrypi:~ $ ruby adt7410.rb
    26

この数値を 5分おきに focusligt に送るように crontab に設定する。  

    pi@raspberrypi:~ $ crontab -l
    */5 * * * * curl -d number=`ruby adt7410.rb` http://localhost/api/myhome/living/temperature >> /home/pi/cron.log 2>&1


ブラウザから見てみると。  

![](/images/2015-12-18-raspberry-pi-with-adt7410/focuslight.png)

ちゃんと取れてる！  

# まとめ
Raspberry Pi と adt7410 で室内の温度を測ってグラフにした。  
これで外出先から自宅の温度が確認できるようになった。  
IRkit と組み合わせることで、外出先からもエアコンの消し忘れに気づき、電源を OFF にすることができる。  
ハードウェアを使って何かするというの、かなりおもしろいものだなと思った。これからも電子工作してきたい。  

# 参考
- [こじ研（Raspberry Pi）](http://www.myu.ac.jp/~xkozima/lab/raspTutorial1.html)
- [GPIO: Raspberry Pi Models A and B - Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/usage/gpio/)
- [ウェッブエンジニアのローレベルプログラミング / cho45 - YouTube](https://www.youtube.com/watch?v=Dz8hQGo3YwQ&feature=youtu.be)
- [cho45/ruby-i2c-devices](https://github.com/cho45/ruby-i2c-devices)
- [examples/ADT7410.fzz at master · MozOpenHard/examples](https://github.com/MozOpenHard/examples/blob/master/i2c-ADT7410/ADT7410.fzz)
- [電子回路設計ツール Fritzing を使ってみた | ε-ARK Project](http://www.e-ark.jp/2013/02/12/%E9%9B%BB%E5%AD%90%E5%9B%9E%E8%B7%AF%E8%A8%AD%E8%A8%88%E3%83%84%E3%83%BC%E3%83%AB-fritzing-%E3%82%92%E4%BD%BF%E3%81%A3%E3%81%A6%E3%81%BF%E3%81%9F/)
