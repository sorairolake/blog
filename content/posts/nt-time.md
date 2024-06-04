+++
title = "RustでWindowsのファイル時刻を扱うためのライブラリのnt-timeの紹介"
date = 2023-08-03T19:53:18+09:00
lastmod = 2024-06-04T12:48:55+09:00
draft = false
description = ""
summary = ""
categories = ["プログラミング"]
tags = ["date", "rust", "time", "windows"]
+++

RustでWindowsの[ファイル時刻](https://learn.microsoft.com/ja-jp/windows/win32/sysinfo/file-times)を扱うためのライブラリの[`nt-time`](https://crates.io/crates/nt-time)を開発したので紹介します。

## ファイル時刻とは

`nt-time`クレートについて説明する前に、ファイル時刻について説明します。

ファイル時刻は、1601年1月1日0時0分0秒 (UTC) から経過した100ナノ秒間隔の数を表す64ビット整数値で、Unix系のシステムにおけるUNIX時間に相当するものです。
ファイル時刻は、NTFSや7zのタイムスタンプとして利用されています[^1][^2]。
ファイル時刻は、Win32 APIでは[`GetSystemTime()`](https://learn.microsoft.com/ja-jp/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemtime)を使用することで取得することができ、.NETでは[`DateTime.ToFileTime()`](https://learn.microsoft.com/ja-jp/dotnet/api/system.datetime.tofiletime)を使用することで取得することができます。
最大値は60056年5月28日5時36分10秒955161500 (UTC) ですが、WindowsのAPIでは最大値は64ビット符号付き整数の最大値に制限されます。

## nt-timeとは

`nt-time`クレートはこのファイル時刻を扱うためのライブラリです。

ファイル時刻を表す型として[`nt_time::FileTime`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html)を定義しています。
この型はNew Type Patternを利用しており、内部的には[`u64`](https://doc.rust-lang.org/core/primitive.u64.html)です。

`FileTime`は以下のような機能を実装しています。

1. [`core::time::Duration`](https://doc.rust-lang.org/core/time/struct.Duration.html)などとの加算や減算
2. [`std`](https://doc.rust-lang.org/std/index.html)や[`time`](https://crates.io/crates/time)クレートや[`chrono`](https://crates.io/crates/chrono)クレートの時間を表す型との相互変換
3. UNIX時間との相互変換
4. [Serde](https://serde.rs/)を利用したシリアライズとデシリアライズ

### コード例

```rs
use core::time::Duration;

use nt_time::{
    time::{macros::datetime, OffsetDateTime},
    FileTime,
};

let ft = FileTime::NT_TIME_EPOCH;
assert_eq!(
    OffsetDateTime::try_from(ft).unwrap(),
    datetime!(1601-01-01 00:00 UTC)
);

let ft = ft + Duration::from_secs(11_644_473_600);
assert_eq!(
    OffsetDateTime::try_from(ft).unwrap(),
    OffsetDateTime::UNIX_EPOCH
);
assert_eq!(ft.to_raw(), 116_444_736_000_000_000);

assert_eq!(FileTime::new(u64::MAX), FileTime::MAX);
```

### 定数

以下の3つの定数を定義しています。

- [`FileTime::NT_TIME_EPOCH`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#associatedconstant.NT_TIME_EPOCH) - NT time epoch (1601-01-01 00:00:00 UTC) を表します
- [`FileTime::UNIX_EPOCH`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#associatedconstant.UNIX_EPOCH) - Unix epoch (1970-01-01 00:00:00 UTC) を表します
- [`FileTime::MAX`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#associatedconstant.MAX) - `FileTime`が表すことのできる最大値 (+60056-05-28 05:36:10.955161500 UTC) を表します

### 演算

`FileTime`は[`Add`](https://doc.rust-lang.org/core/ops/trait.Add.html)を実装しているので、`core::time::Duration`や[`time::Duration`](https://docs.rs/time/0.3.23/time/struct.Duration.html)の値を加算することができます。
[`Sub`](https://doc.rust-lang.org/core/ops/trait.Sub.html)ではこれらに加えて[`std::time::SystemTime`](https://doc.rust-lang.org/std/time/struct.SystemTime.html)などの時間を表す型との演算を実装しているので、`FileTime`からこれらの型の値を減算することができます。
`core::time::Duration`との演算ではオーバーフローした場合に飽和するメソッド ([`FileTime::saturating_add()`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.saturating_add)、[`FileTime::saturating_sub()`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.saturating_sub)) や`None`を返すメソッド ([`FileTime::checked_add()`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.checked_add)、[`FileTime::checked_sub()`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.checked_sub)) を定義しています。
また、[`PartialEq`](https://doc.rust-lang.org/core/cmp/trait.PartialEq.html)と[`PartialOrd`](https://doc.rust-lang.org/core/cmp/trait.PartialOrd.html)も実装しているので、これらの期間や時間を表す型との同値関係と順序関係を比較することができます。

### 相互変換

`FileTime`は[`From`](https://doc.rust-lang.org/core/convert/trait.From.html)や[`TryFrom`](https://doc.rust-lang.org/core/convert/trait.TryFrom.html)によって`std::time::SystemTime`、[`time::OffsetDateTime`](https://docs.rs/time/0.3.23/time/struct.OffsetDateTime.html)、[`chrono::DateTime<chrono::offset::Utc>`](https://docs.rs/chrono/0.4.26/chrono/struct.DateTime.html)と相互変換することができます。
これらは変換元の値が変換先の型の範囲外の場合は`TryFrom`を使うようになっています。
また、`u64`の値から`FileTime`を作成すること ([`FileTime::new()`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.new)) とその逆 ([`FileTime::to_raw()`](https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.to_raw)) にも対応しています。

UNIX時間との相互変換については、秒単位とナノ秒単位に対応しています[^3][^4][^5][^6]。

### シリアライズとデシリアライズ

Serdeを利用してISO 8601形式、RFC 2822形式、RFC 3339形式、UNIX時間との間でシリアライズとデシリアライズを行うことができます。

```rs
use nt_time::{
    serde::{Deserialize, Serialize},
    serde_with::iso_8601,
    FileTime,
};

#[derive(Debug, Deserialize, PartialEq, Serialize)]
struct DateTime(#[serde(with = "iso_8601")] FileTime);

let json = serde_json::to_string(&DateTime(FileTime::UNIX_EPOCH)).unwrap();
assert_eq!(json, r#""+001970-01-01T00:00:00.000000000Z""#);

assert_eq!(
    serde_json::from_str::<DateTime>(&json).unwrap(),
    DateTime(FileTime::UNIX_EPOCH)
);
```

## 終わりに

RustでWindowsのファイル時刻を扱うためのライブラリの`nt-time`クレートを紹介しました。

詳細なドキュメントは[Docs.rs](https://docs.rs/nt-time)で確認することができます。

気に入ってもらえたら[sorairolake/nt-time](https://github.com/sorairolake/nt-time)でStarを付けてもらえるとありがたいです。
`nt-time`クレートの改善のために[Issue](https://github.com/sorairolake/nt-time/issues)や[Pull Request](https://github.com/sorairolake/nt-time/pulls)もお待ちしています。

[^1]: <https://learn.microsoft.com/ja-jp/windows/win32/sysinfo/file-times>

[^2]: <https://py7zr.readthedocs.io/en/v0.20.5/archive_format.html#filetime>

[^3]: <https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.to_unix_time>

[^4]: <https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.to_unix_time_nanos>

[^5]: <https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.from_unix_time>

[^6]: <https://docs.rs/nt-time/0.5.1/nt_time/struct.FileTime.html#method.from_unix_time_nanos>
