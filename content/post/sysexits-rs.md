+++
title = "Rust向けの<sysexits.h>を作成しました"
date = 2022-06-10T15:12:38+09:00
lastmod = 2022-11-22T13:22:14+09:00
draft = false
description = ""
summary = ""
categories = ["プログラミング"]
tags = ["rust", "sysexits"]
+++

[Rust][rust-official-url]の`main`関数の戻り値で[`<sysexits.h>`][sysexits-man-url]で定義されている終了コードを使えるようにするライブラリの**sysexits-rs** ([`sysexits`][sysexits-crates-io-url]) を作成しました。

Rust 1.61.0から`main`関数の戻り値で任意の終了コードを返せるようになったので、`<sysexits.h>`で定義されている終了コードをこれに利用できたら便利だと思ったのがこのライブラリを作成した理由です。

## 使用例

```rust
fn main() -> sysexits::ExitCode {
    let bytes = [0xf0, 0x9f, 0x92, 0x96];
    match std::str::from_utf8(&bytes) {
        Ok(string) => {
            println!("{string}");
            sysexits::ExitCode::Ok
        }
        Err(err) => {
            eprintln!("{err}");
            sysexits::ExitCode::DataErr
        }
    }
}
```

[rust-official-url]: https://www.rust-lang.org/
[sysexits-man-url]: https://man.openbsd.org/sysexits
[sysexits-crates-io-url]: https://crates.io/crates/sysexits
