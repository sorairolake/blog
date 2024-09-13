+++
title = "個人的にMarkdownよりAsciiDocが好きな理由"
date = 2024-09-13T20:12:40+09:00
lastmod = 2024-09-13T20:12:40+09:00
draft = false
description = ""
summary = ""
categories = ["雑記"]
tags = ["asciidoc", "markdown"]
toc = true
+++

この記事では私が個人的に[Markdown](https://daringfireball.net/projects/markdown/)より[AsciiDoc](https://asciidoc.org/)が好きな理由を述べたいと思います。

## 定義リストが標準で使える

AsciiDocは言語仕様に定義リストが含まれています。

```text
Fuchsia::

  Capability-based operating system developed by Google.

Redox::

  Operating system written in Rust.
```

これは以下のようなHTMLになります。

```html
<dl>
  <dt>Fuchsia</dt>
  <dd>
    <p>Capability-based operating system developed by Google.</p>
  </dd>
  <dt>Redox</dt>
  <dd>
    <p>Operating system written in Rust.</p>
  </dd>
</dl>
```

Markdownでも[Pandoc](https://pandoc.org/)のMarkdownなどの一部の方言では定義リストが使えますが、オリジナルのMarkdown、[CommonMark](https://commonmark.org/)、[GFM](https://github.github.com/gfm/)などは非対応なのでこれらではHTMLを直接書く必要があります。

## リストのネストをマーカーの個数で表現する

Markdownではリストをネストするときはインデントで表します。

```markdown
- チョコレート
  - ミルクチョコレート
  - ホワイトチョコレート
- キャラメル

1.  コロネ
    1.  チョココロネ
    2.  クリームコロネ
2.  メロンパン
```

AsciiDocではリストをネストするときはマーカーの個数で表します。

```text
* チョコレート
** ミルクチョコレート
** ホワイトチョコレート
* キャラメル

. コロネ
.. チョココロネ
.. クリームコロネ
. メロンパン
```

インデントを気にしなくていいので、個人的にはAsciiDocの書き方の方が好みです。

## 他のファイルを取り込める

AsciiDocは[`include`命令](https://docs.asciidoctor.org/asciidoc/latest/directives/include/)で他のファイルを取り込むことができます。
プログラムのソースコードなどのAsciiDoc以外のテキストファイルでも取り込めます。

```text
include::partial.adoc[]

[source,rs]
----
include::src/lib.rs[]
----
```

この機能は複数のドキュメントに共通の部分を含む場合や、プログラムのソースコードをドキュメントの一部として取り込みたいときに便利です。

## Markdownの方が良いところ

### 普及率

Markdownは普及率が高いからか対応ツールが多く、効率的に綺麗なドキュメントを書けるように思います。

### 他のフォーマットに綺麗に変換できる

[Asciidoctor](https://asciidoctor.org/)はAsciiDocを様々なフォーマットに変換できますが、対応していないフォーマットもあります。
そのような場合、PandocはAsciiDocを入力フォーマットとして対応していないので以下のように一度やHTMLに変換する必要があります。

```sh
asciidoctor -b docbook5 -o - README.adoc \
    | pandoc -f docbook -t org \
    > README.org
```

MarkdownはPandocの対応する入力フォーマットなので以下のようにPandocだけで変換できます。

```sh
pandoc -f gfm -t org README.md > README.org
```

個人的にはAsciidoctorとPandocでAsciiDocを任意のフォーマットに変換する場合よりも、PandocだけでMarkdownを任意のフォーマットに変換するときの方がより綺麗に変換できることが多いように思いました。
