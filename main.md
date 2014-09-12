---
layout: post
title:  "12 main関数"
date:   2013-11-16 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は専用ページでご覧ください。}}

{% tree %}

## `main`関数のシグネチャ

関数名, 関数の戻り値型, 関数が取る引数の型リストの3つをまとめてシグネチャ(signature)といいます。
今まで書いてきたmain関数のシグネチャは`void main();`だけですが、実際には以下のバリエーションがあります。

~~~~d
void main();
void main(string[] args);

// 以下2つは通常使われない
int main();
int main(string[] args);
~~~~

実は、**main関数は`string[]`型の引数を受け取ることができます！**


## コマンドライン引数と`std.getopt`

この`string[] args`にはコマンドライン引数が配列として格納されています。
コマンドライン引数とは、プログラムを起動する際にシェルやコマンドプロンプトから渡される引数のことです。
`dmd`を例にすると、`dmd`に対するコマンドライン引数は`dmd foo bar`と打ち込んだ際の`foo`や`bar`のことです。
では実際に次のソースコードをコンパイルして、次のようにコマンドライン引数を渡して実行してみましょう。

~~~~d
// io_main.d
import std.stdio;

void main(string[] args)
{
    writeln(args);
}
~~~~


[Windows]の場合:

~~~~
$ dmd io_main
$ ./io_main foo bar
[".\\io_main.exe", "foo", "bar"]
~~~~

実行してみると、`args`の1つ目の要素にはプログラム名、2つ目には`"foo"`, 3つ目には`"bar"`が格納されていることがわかりますね。
つまり、実際にコンソールで渡した"foo"や"bar"が配列の第2要素以降へ格納されているのです。
引数は、スペースを区切り文字として区切られ`args`に格納されますが、もし`"foo bar"`というように`""`で括っていれば、スペースで区切られずにそのままの表記となります。

~~~~
$ ./io_main "foo bar"
[".\\io_main.exe", "foo bar"]
~~~~

コマンドライン引数は、普通のプログラム、たとえば`dmd`だと`-run`とか`-m64`だとかのようにハイフン`-`と識別子を与えたり、`-version=Foo`のように値を設定したり, 対象のファイルのパスを指定するのに使用されます。

次のプログラムは2つのコマンドライン引数に設定された値の合計を出力するプログラムです。

~~~~d
// io_main.d
import std.stdio;
import std.conv;


void main(string[] args)
{
    int a, b;

    foreach(e; args[1 .. $]){
        if(e[0 .. 4] == "--a=")
            a = e[4 .. $].to!int();
        else if(e[0 .. 4] == "--b=")
            b = e[4 .. $].to!int();
    }

    writeln(a + b);
}
~~~~

~~~~
$ dmd io_main
$ ./io_main --a=10 --b=5
15
$ ./io_main --b=2 --a=5
7
~~~~

しかし、引数の種類が多くなってくるとプログラムに渡されたコマンドライン引数を処理するのは難しくなります。
そのため、D言語の標準ライブラリであるPhobosには`std.getopt`というモジュールが含まれています。
`std.getopt.getopt`を使えば簡単に引数から情報を得ることが出来ます。

~~~~d
import std.stdio;
import std.getopt;

void main(string[] msg)
{
    int a, b;

    getopt(msg,
           "a", &a,
           "b", &b);

    writeln(a + b);
}
~~~~

~~~~
$ dmd io_main
$ ./io_main --a=10 --b=5
15
$ ./io_main --b=2 --a=5
7
$ ./io_main --a 3 --b 2
5
$ ./io_main -a=10 -b=5
15
$ ./io_main -a 10 -b 5
15
~~~~


## 返り値

main関数の返り値の型は`void`もしくは`int`ですが、普通は`void`にしておきます。
あなたがC言語ユーザーであったり、低レイヤーを扱っている場合で無い限りは返り値の型は`void`でいいでしょう。

もし返り値の型が`void`の場合には、D言語のランタイムが、つまりあなたの代わりにプログラムが適切な値を返してくれます。
ランタイムに任せておけば、あなたは何も考える必要はありません。


## 問題

問題募集中


## キーワード

* メイン関数
* コマンドライン引数
* `std.getopt`
