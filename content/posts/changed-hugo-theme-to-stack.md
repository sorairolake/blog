+++
title = "ブログで使うテーマを変更した話"
date = 2024-03-21T10:43:38+09:00
lastmod = 2024-03-21T10:43:38+09:00
draft = false
description = ""
summary = ""
categories = ["雑記"]
tags = ["hugo", "theme"]
+++

このブログで使用するHugoのテーマを[PaperMod](https://github.com/adityatelange/hugo-PaperMod)から[Stack](https://github.com/CaiJimmy/hugo-theme-stack)に変更しました。

## きっかけ

テーマを変更したきっかけはこの直前にHugo Modulesを使用するように変更したことです。
当初はPaperModのままでこれを行いましたが、`go.mod`でテーマのバージョンを固定することが難しかったので、これを解決するついでにテーマを変更しました。

## 手順

### テーマの変更

設定ファイルを編集してテーマを変更しました。

```diff
[[module.imports]]
-path = "github.com/adityatelange/hugo-PaperMod"
+path = "github.com/CaiJimmy/hugo-theme-stack/v3"
```

### 構成の変更

従来は単一の設定ファイルで全てを管理していましたが、複数のファイルに分割した上で設定用のディレクトリを使う構成に変更しました。
