+++
title = "Wikimedia Commonsのカテゴリにある画像を一括ダウンロードする"
date = 2024-09-09T23:32:34+09:00
lastmod = 2024-09-09T23:32:34+09:00
draft = false
description = ""
summary = ""
categories = ["雑記"]
tags = ["gallery-dl", "wikimedia-commons"]
+++

[Wikimedia Commons](https://commons.wikimedia.org/)のカテゴリに属している画像をダウンロードするときに以下の方法が便利だったのでメモ。

## 方法

結論として、[`gallery-dl`](https://github.com/mikf/gallery-dl)を使うことで簡単にダウンロードできます。
`gallery-dl`は画像向けの[`yt-dlp`](https://github.com/yt-dlp/yt-dlp)のようなコマンドで、`yt-dlp`と同じくPythonで書かれています。

[![Packaging status](https://repology.org/badge/vertical-allrepos/gallery-dl.svg?columns=3)](https://repology.org/project/gallery-dl/versions)

`gallery-dl`は多くのウェブサイトに対応していますが、その中の1つとしてWikimedia Commonsにも対応しています。

以下のコマンドで[Category:Official Python icons and direct derivatives](https://commons.wikimedia.org/wiki/Category:Official_Python_icons_and_direct_derivatives)に直接属している全ての画像をダウンロードできます。

```sh
gallery-dl "https://commons.wikimedia.org/wiki/Category:Official_Python_icons_and_direct_derivatives"
```

個々のファイルをダウンロードすることもできます。

```sh
gallery-dl "https://commons.wikimedia.org/wiki/File:Logo_of_Hugo_the_static_website_generator.svg"
```
