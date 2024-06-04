+++
title = "データの暗号化のためのファイルフォーマットを作成しました"
date = 2023-10-03T07:02:05+09:00
lastmod = 2023-10-03T07:02:05+09:00
draft = false
description = ""
summary = ""
categories = ["プログラミング"]
tags = ["abcrypt", "crypto", "rust"]
+++

シンプルでモダンでセキュアなファイル暗号化ツールとファイルフォーマットとRustのライブラリの**abcrypt**を作成したので紹介します。

## abcrypt暗号化データフォーマットとは

**abcrypt暗号化データフォーマット** (英語: **abcrypt encrypted data format**) は、認証付きのモダンなファイル暗号化フォーマットです。

このファイルフォーマットは[scrypt encrypted data format](https://www.tarsnap.com/scrypt.html)から着想を得ており、秘密鍵の導出には[Argon2id](https://datatracker.ietf.org/doc/html/rfc9106)を使用し、ヘッダーの認証には[BLAKE2b-512-MAC](https://datatracker.ietf.org/doc/html/rfc7693)を使用し、データの暗号化には[XChaCha20-Poly1305](https://datatracker.ietf.org/doc/html/draft-arciszewski-xchacha-03)を使用しています。
このファイルフォーマットを作成したのは、scrypt encrypted data formatの秘密鍵の導出の部分をArgon2に変更したものを作成してみたいと思ったのがきっかけです。
scrypt encrypted data formatではヘッダーの認証にHMAC-SHA-256を使用していますが、abcryptフォーマットではArgon2idがBLAKE2bを使用していることと、BLAKE2bがHMACを使わないでそれ自体でメッセージ認証コード (MAC) を出力することができるので、BLAKE2b-512-MACを使用しています。
データの暗号化部分はBLAKE2bと同様に[ChaCha](https://ja.wikipedia.org/wiki/Salsa20#ChaCha)をベースとしていることと、認証付き暗号であることと、ChaCha20-Poly1305とは異なりノンスに暗号論的擬似乱数生成器 (CSPRNG) で生成した値を使用できるので[^1][^2]、XChaCha20-Poly1305を使用しています。

詳細な仕様は<https://sorairolake.github.io/abcrypt/book/format.html>を参照して下さい。

## ライブラリについて

abcryptフォーマットを実装したRustのライブラリの[`abcrypt`](https://crates.io/crates/abcrypt)を作成しました。
これは私が以前に作成したscrypt encrypted data formatの実装の[`scryptenc`](https://crates.io/crates/scryptenc)をベースにしています。

このライブラリは`no_std`環境で使用することができ、`default` featureを無効にすることで使用することができます。
この場合にヒープの使用を許容できる場合は、`alloc` featureを有効にします[^3]。
`alloc` featureを有効にした場合は暗号化や復号したデータを`Vec<u8>`として出力することができ、暗号化や復号するデータの長さが事前に分かっていない場合に使用できます。
このライブラリでは暗号化や復号するデータはスライス (`[u8]`) で保持しており、暗号化や復号するデータの長さが事前に分かっている場合は出力を書き込むためのバッファを固定長の配列で確保して処理することもできるので、メモリ効率は良いはずです。

APIの詳細は<https://docs.rs/abcrypt>を参照して下さい。

### バインディングについて

このライブラリをC言語でも利用できるようにするためにバインディングの[`abcrypt-capi`](https://crates.io/crates/abcrypt-capi)も作成しました。

C言語のAPI (ヘッダーファイル) の詳細は<https://sorairolake.github.io/abcrypt/book/capi/capi.html>を、RustのAPIの詳細は<https://docs.rs/abcrypt-capi>参照して下さい。

## ファイル暗号化ツールについて

abcryptフォーマットを利用してファイルの暗号化を行うためのコマンドラインユーティリティの[`abcrypt-cli`](https://crates.io/crates/abcrypt-cli)を作成しました。
コマンド名は`abcrypt`です。
これは私が以前に作成した`scrypt(1)`のRust実装の[`scryptenc-cli`](https://crates.io/crates/scryptenc-cli)をベースにしています。

基本的なファイルの暗号化は以下のコマンドで行います。

```sh
abcrypt encrypt data.txt > data.txt.abcrypt
```

また、基本的なファイルの復号は以下のコマンドで行います。

```sh
abcrypt decrypt data.txt.abcrypt > data.txt
```

暗号化時にはコマンドラインオプションでArgon2パラメータを指定することができます[^4]。
パスフレーズは`/dev/tty`、標準入力、環境変数またはファイルから入力することができます。
また、コマンドラインオプションでシェル補完スクリプトを生成することもできます。

詳細な利用方法は<https://sorairolake.github.io/abcrypt/book/cli/index.html>やmanページを参照して下さい。

## 終わりに

abcryptの紹介をしました。

気に入ってもらえたら[sorairolake/abcrypt](https://github.com/sorairolake/abcrypt)でStarを付けてもらえるとありがたいです。
abcryptの改善のために[Issue](https://github.com/sorairolake/abcrypt/issues)や[Pull Request](https://github.com/sorairolake/abcrypt/pulls)もお待ちしています。

[^1]: [XChaCha20-Poly1305 construction - libsodium](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction)

[^2]: [Motivation for XChaCha20-Poly1305](https://datatracker.ietf.org/doc/html/draft-arciszewski-xchacha-03#section-2.1)

[^3]: 有効にしない場合はArgon2で秘密鍵を導出する際に使用するメモリブロックの大きさが制限されます (v0.2.5の時点では256 KiB)。

[^4]: 指定しない場合は[OWASP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#argon2id)の推奨値を使用します。
