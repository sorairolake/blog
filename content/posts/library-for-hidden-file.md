+++
title = "クロスプラットフォームな隠しファイルを操作するコマンドとライブラリを開発したはなし"
date = 2024-04-02T16:47:16+09:00
lastmod = 2024-09-09T20:48:54+09:00
draft = false
description = ""
summary = ""
categories = ["プログラミング"]
tags = ["cli", "hf", "hidden", "library", "rust"]
+++

UnixとWindowsで共通のAPIで隠しファイルと隠しディレクトリを操作できるライブラリと、これを使ったコマンドラインユーティリティの[`hf`](https://github.com/sorairolake/hf)を開発しました。

## 概要

ライブラリとコマンドの両方ともRustで書かれており、クレートは同じです。

[crates.io](https://crates.io/crates/hf)

開発は2022年5月から始まっています。
当初は隠しファイルを操作するコマンドとして開発しており、ライブラリとしても使えるようにすることは想定していませんでした。
当初の目的は達成できたので開発は同年12月に一旦停止して以降放置していましたが、先月末から開発を再開してライブラリとしても利用できるようにしました。

広く知られているようにUnixとWindowsではファイルを隠しファイルとみなす条件が異なります。

Unix

: 名前がドット（`.`）で始まるファイル。

Windows

: 隠しファイル属性が設定されているファイル。

hfではこの差をできるだけ気にしないで共通のAPIで処理できるようにしてあります。

ライブラリのAPIとして主に次の3つの関数を提供しています:

1.  [`hf::is_hidden`](https://docs.rs/hf/0.3.2/hf/fn.is_hidden.html)
2.  [`hf::hide`](https://docs.rs/hf/0.3.2/hf/fn.hide.html)
3.  [`hf::show`](https://docs.rs/hf/0.3.2/hf/fn.show.html)

最初の`hf::is_hidden`はファイルが隠しファイルか否かを判定します。
Unixではファイル名がドットで始まるかを見て、Windowsでは隠しファイル属性が設定されているかを見ます。

2番目の`hf::hide`はファイルを隠しファイルにします。
Unixではファイル名をドットで始まるように改名し、Windowsでは隠しファイル属性を設定します。

最期の`hf::show`は`hf::hide`と逆の処理を行います。
Unixではファイル名の先頭の全てのドットを削除し、Windowsでは隠しファイル属性を解除します。

## コード例

```rs
use std::fs::File;

let temp_dir = tempfile::tempdir().unwrap();
let file_path = temp_dir.path().join("foo.txt");

File::create(&file_path).unwrap();
assert!(!hf::is_hidden(&file_path).unwrap());

hf::hide(&file_path).unwrap();
// ファイル名を`.`で始まるようにする。
#[cfg(unix)]
let file_path = hf::unix::hidden_file_name(&file_path).unwrap();
assert!(hf::is_hidden(&file_path).unwrap());

hf::show(&file_path).unwrap();
// ファイル名を`.`以外の文字で始まるようにする。
#[cfg(unix)]
let file_path = hf::unix::normal_file_name(&file_path).unwrap();
assert!(!hf::is_hidden(file_path).unwrap());
```

Unixでは隠しファイル化とその逆は改名によって行うので、処理した後のパスを取得するための関数の`hf::unix::hidden_file_name`と`hf::unix::normal_file_name`を提供しています。

## コマンド

コマンドラインユーティリティは`git clean`のように処理の前に対象となるファイルを確認してから実際の処理を行うようになっています。
処理が不要なファイルには何も行いませんが、どのファイルが処理の対象外かを確認できるようにしてあります。

### 隠しファイルにする

```sh
# 処理対象のファイルを確認
hf hide -n .gitignore README.md src/

# 処理を実行する
hf hide -f .gitignore README.md src/
```

### 通常のファイルにする

```sh
# 処理対象のファイルを確認
hf show -n .github/ .gitignore Cargo.toml

# 処理を実行する
hf show -f .github/ .gitignore Cargo.toml
```

## 終わりに

隠しファイルを操作できるライブラリとコマンドのhfの紹介をしました。

ソースコードは[GitHub](https://github.com/sorairolake/hf)で公開しているので試していただけると幸いです。

## 参考文献

- [ホームページ](https://sorairolake.github.io/hf/)
- [APIドキュメント](https://docs.rs/hf)
