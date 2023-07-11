+++
title = "scrypt暗号化データ形式のRust実装を作成しました"
date = 2022-11-22T13:22:14+09:00
lastmod = 2022-11-22T13:22:14+09:00
draft = false
description = ""
summary = ""
categories = ["プログラミング"]
tags = ["rust", "scrypt"]
+++

[scrypt暗号化データ形式][specification-url]を読み書きするためのライブラリの**scryptenc-rs** ([`scryptenc`][scryptenc-crates-io-url]) と、この形式のためのコマンドラインユーティリティである`scrypt(1)`のRust実装の**rscrypt** ([`scryptenc-cli`][scryptenc-cli-crates-io-url]) を作成しました。

[specification-url]: https://github.com/Tarsnap/scrypt/blob/d7a543fb19dca17688e34947aee4558a94200877/FORMAT
[scryptenc-crates-io-url]: https://crates.io/crates/scryptenc
[scryptenc-cli-crates-io-url]: https://crates.io/crates/scryptenc-cli
