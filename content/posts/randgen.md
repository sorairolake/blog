+++
title = "ランダムなバイト列を生成するコマンドを作成しました"
date = 2025-03-13T16:54:48+09:00
lastmod = 2025-03-13T16:54:48+09:00
draft = false
description = ""
summary = ""
categories = ["プログラミング"]
tags = ["random", "rust"]
+++

擬似乱数列生成器（PRNG）を使ってランダムなバイト列を生成するコマンドの[`randgen`](https://github.com/sorairolake/randgen)を作成しました。
[Rust](https://www.rust-lang.org/)で実装しています。

## インストール方法

`randgen`は[crates.io](https://crates.io/crates/randgen)で公開しているので[`cargo install`](https://doc.rust-lang.org/cargo/commands/cargo-install.html)でインストールできます。

```sh
cargo install randgen
```

また、[リリースページ](https://github.com/sorairolake/randgen/releases)でLinux、macOS、Windows向けのバイナリを公開しています。

## 使い方

`randgen [オプション]... 生成するバイト数`という形で利用できます。
`生成するバイト数`には`1KiB`や`2 MB`のように単位付きの値を指定できます。
`256`のように数値だけを指定したときは`256 B`を指定したとみなします。

以下の例は1 KiBのランダムなバイト列を生成して標準出力に出力します。

```sh
randgen 1KiB
```

### 出力形式

生成したランダムなバイト列は以下の形式で出力できます。

- `raw`（生のバイト列）
- `base64`（[base64](https://datatracker.ietf.org/doc/html/rfc4648#section-4)にエンコードして出力する）
- `base64url`（[URLセーフなbase64](https://datatracker.ietf.org/doc/html/rfc4648#section-5)にエンコードして出力する）
- `hex`（16進数文字列にエンコードして出力する）

デフォルトでは`raw`形式で出力します。
出力形式を指定するには`-f`オプションが利用できます。

以下の例は256 Bのランダムなバイト列を生成して、それをbase64にエンコードして標準出力に出力します。

```sh
randgen -f base64 256
```

### 対応しているPRNG

`randgen`はランダムなバイト列を生成するときに以下のPRNGを利用できます。

- [ISAAC](https://www.burtleburtle.net/bob/rand/isaacafa.html)（コンパイル時に有効にしている場合）
- [メルセンヌ・ツイスタ](https://www.math.sci.hiroshima-u.ac.jp/m-mat/MT/mt.html)（コンパイル時に有効にしている場合）
- [PCG](https://www.pcg-random.org/)（コンパイル時に有効にしている場合）
- [SFC](https://pracrand.sourceforge.net/RNG_engines.txt)（コンパイル時に有効にしている場合）
- [Xorshift系](https://prng.di.unimi.it/)
  - SplitMix64
  - Xorshift（コンパイル時に有効にしている場合）
  - xoroshiro
  - xoshiro

また、以下の暗号論的擬似乱数生成器（CSPRNG）を利用できます。

- [ChaCha](https://cr.yp.to/chacha.html)ベースのCSPRNG
- [HC-128](https://en.wikipedia.org/wiki/HC-128)ベースのCSPRNG（コンパイル時に有効にしている場合）

デフォルトでは`chacha12`をPRNGとして利用します。
PRNGを指定するには`-r`オプションが利用できます。

以下の例はPRNGとしてpcg64を使用して2 MBのランダムなバイト列を生成して標準出力に出力します。

```sh
randgen -r pcg64 "2 MB"
```

### シード値の指定

`-s`オプションを使うことでPRNGで使用するシード値を指定できます。
シード値には符号なし64ビット整数を指定できます。
このオプションが指定されていないときは、シード値はLinuxの[`getrandom`](https://man7.org/linux/man-pages/man2/getrandom.2.html)システムコールなどのOSの乱数列生成器から生成されます。

以下の例はシード値として`8`を指定し、PRNGとしてsfc32を使用して32 Bのランダムなバイト列を生成して、それを16進数文字列にエンコードして標準出力に出力します。

```sh
$ randgen -f hex -r sfc32 -s 8 32B
24f48cd0c3f6a1c6e8d7b4dcff9578864aced749e4eb1805dfba8b6e21d0cba0
```

## 作った理由

2月にSFCのRust実装の[`rand_sfc`](https://crates.io/crates/rand_sfc)クレートを作りましたが、これを使った何かを作りたいと思ったので作りました。
複数のPRNGのサポートとシード値が指定できるところは[PractRand](https://pracrand.sourceforge.net/)の[`RNG_output`](https://pracrand.sourceforge.net/tools.txt)を参考にし、複数の形式で出力できるところは[`openssl-rand`](https://docs.openssl.org/master/man1/openssl-rand/)を参考にしています。
