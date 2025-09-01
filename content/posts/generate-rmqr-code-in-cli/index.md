+++
title = "コマンドラインでrMQRコードを生成する"
date = 2025-09-02T06:34:28+09:00
lastmod = 2025-09-02T06:34:28+09:00
draft = false
description = ""
summary = ""
categories = ["雑記"]
tags = ["cli", "qrcode", "rmqr", "zint"]
+++

## はじめに

[rMQRコード](https://www.qrcode.com/codes/rmqr.html)を生成したくなり、コマンドラインでできないか調べたところ、[Zint](https://www.zint.org.uk/)を使うとできたのでその方法について記事にします。

## rMQRコードとは

rMQRコード（長方形マイクロQRコード）は、2022年5月に発表された長方形型の新しいQRコードで、従来のQRコードが印字できなかった狭いスペースへの印字や、[マイクロQRコード](https://www.qrcode.com/codes/microqr.html)より多くの情報を格納したいというニーズに対応します。
最大のコードの大きさは17×139セルで、その場合は数字で361文字、英数字で219文字、バイナリで150文字、漢字で92文字のデータを格納できます。
rMQRコードは2022年5月に[ISO/IEC 23941](https://www.iso.org/standard/77404.html)として規格化されています。

## Zintとは

Zint（libzint）は、バーコードを生成するためのオープンソースのライブラリです。
クロスプラットフォームに対応していて、50種類以上のバーコードの規格に対応しています。
ZintはQtを採用したGUI、CLIアプリ、C言語のライブラリとして利用できます。
Zintは従来のQRコード、マイクロQRコード、rMQRコードのいずれも対応しています。

## 方法

「QR Code」という文字列を格納したrMQRコードを生成するには以下のコマンドを実行します。

```sh
zint -b RMQR -d "QR Code" -o rmqr-code.png --quietzones --scale=4
```

![rMQRコード](rmqr-code.webp)

このrMQRコードは以下のQRコードとマイクロQRコードと同じ内容を格納しています。

```sh
zint -b QRCODE -d "QR Code" -o qr-code.png --quietzones --scale=4
zint -b MICROQR -d "QR Code" -o micro-qr-code.png --quietzones --scale=4
```

![QRコード](qr-code.webp)
![マイクロQRコード](micro-qr-code.webp)

`-b`オプションはバーコードの種類を指定します。
利用可能なバーコードの種類は`zint -t`で確認できます。
既定値は[Code 128](https://ja.wikipedia.org/wiki/CODE128)です。

データは`-d`オプションによってコマンドラインから、または`-i`オプションによってファイルから入力します。

`-o`オプションは出力ファイルを指定します。
これを指定しない場合は`out.png`に出力されます。
ファイル形式は拡張子または`--filetype`オプションに基づいて決定されます。

`--quietzones`オプションはマージンを追加します。
QRコードは4セル、マイクロQRコードとrMQRコードは2セルのマージンが必要なので仕様に準拠する場合にはこのオプションを指定します。

`--scale`オプションを指定すると画像のスケールを変更できます。

これら以外にも、色を変更するオプション、誤り訂正レベルを変更するオプションなど様々なオプションが存在します。

```sh
zint -b RMQR --fg=9C1313 -i input.txt -o colored-rmqr-code.png --quietzones --scale=4 --secure=4
```

![「Rectangular Micro QR Code」](colored-rmqr-code.webp)

## 終わりに

コマンドラインでQRコードとマイクロQRコードを生成する方法は[`qrencode`](https://fukuchi.org/works/qrencode/)や私が開発している[`qrtool`](https://crates.io/crates/qrtool)などを知っていましたが、rMQRコードを生成する方法は知らなかったので今回知ることができて良かったです。

## 参考文献

- <https://www.qrcode.com/codes/rmqr.html>
- <https://www.denso-wave.com/ja/adcd/info/detail__220525.html>
- <https://www.zint.org.uk/manual/chapter/4>
