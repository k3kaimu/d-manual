---
layout: post
title:  "16 共用体"
date:   2014-08-31 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は専用ページでご覧ください。}}

{% tree %}

## 共用体とは？

構造体は複数の型を一つにまとめた新たな型を作るものでした。
共用体も複数の型をまとめた新しい型を作ります。

共用体と構造体の違いは、構造体は直積的であるのに対して、共用体は直和的です。
つまり、もっと簡単な言葉を使えば、構造体は「複数の型の値のペア」であるのに対して、共用体は「一つの値が複数の型になり得る」のです。

共用体と構造体のメモリ上でのメンバの配置は次のようになります。
構造体はメンバそれぞれに領域が割り当てられるのに対して、共用体ではすべてのメンバで領域を共有します。

![union memory]({{ site.baseurl }}/assets/img/union_memory.svg)

たとえば、`int`型と`string`型から成る共用体型の値には、`int`型の値も格納可能ですし、`string`型の値も格納可能です。
メンバは互いにメモリを共有しているため、あるメンバへ書き込みを行えば他のメンバの値を破壊します。
そのため、あるメンバへ書き込みをした後に違うメンバを読むと、意図しない値になる可能性があります。

~~~~~d
import std.stdio;

union IntOrString
{
    int n;
    string str;
}

void main()
{
    IntOrString ios = {str : "123"};

    writeln(ios.str);       // 123

    writeln(ios.n);         // ???
}
~~~~~


## 共用体みたいな、より安全な型

共用体はうかつに触るべきではありません。
共用体の危険性を理解し、安全に運用できる自身がある人が、適切な場面のみで使用すべきユーザー定義型なのです。

では、一般的な場面で共用体のような振る舞いをする型が欲しい場合はどうしたら良いのでしょうか。
このような場面では、Phobosの`std.variant`にある`Algebraic`, もしくは`Variant`がベストな選択肢です。

`Algebraic`は、共用体のように複数の指定された型の値を格納可能です。
また、現在格納している値はどの型なのかという情報をもっているので、安全に運用することが出来ます。

~~~~d
/// test.d
import std.variant;
import std.stdio;

void main()
{
    alias IoS = Algebraic!(int, string);
    IoS ios = "123";
    writeln(ios);       // 123

    ios = 12;
    writeln(ios);       // 12

    // v.peek!T はAlgebraicが持っている値へのポインタを返す
    // Algebraicがその値を持っていないなら null
    if(int* p = ios.peek!int)
        writeln("int value --- ", *p);
    else if(auto p = ios.peek!string)
        writeln("string value --- ", *p);
}
~~~~~

~~~~~
$ rdmd test
123
12
int value --- 12
~~~~~


`std.variant.Variant`は、Algebraicとは違って持てる値の型に制限はありません。
つまり、数値型であろうが、配列、構造体、後ほど出てくるクラスであったとしても、D言語のすべての型の値を持つことが出来ます。

~~~~~d
/// test.d
import std.variant;
import std.stdio;

void main()
{
    Variant v = 123;        // 数値
    writeln(v);             // 123

    v = [1, 2, 3];          // 配列
    writeln(v[2]);          // 3

    v = "abcdef"
    writeln(v);             // abcdef

    v = 10;
    v += v * v;             // 演算できる！
    writeln(v);             // 110

    struct S { int a = 12; ubyte[1024] big; }
    v = S();    // 巨大なネスト構造体であろうと
    // peekはAlgebraic同様にポインタを返す
    writeln(v.peek!S.a);    // 12

    // ラムダ関数を代入してみる
    v = () => writeln("Hello, World!");
    v();    // 関数呼び出し可能
}
~~~~~~

~~~~~
$ rdmd test
123
3
abcdef
110
12
Hello, World!
~~~~~


## おわりに, まとめ

共用体は一つの変数で複数の型の値を代入できるので、使い方を誤らないのであれば非常に有用なプログラムを書くことができます。
その典型的な例として、動的型付け言語とのデータのやりとりが挙げられます。
D言語は静的型付け言語ですから、すべてのデータは何らかの型に属していることがコンパイル時に決定されています。
対して、RubyやPython、JavaScriptなどの動的型付けな言語では、そのデータがどの型に属しているかは実行時にしかわかりません。
そのような動的型付けされたデータを静的型付け言語に渡す場合には、共用体のように複数の型の値をまとめることができるデータ型が必要となります。

しかし、共用体をそのまま扱うことは非常に危険を伴いますから、Dの標準ライブラリには安全なデータ型が定義されています。
それが、`Variant`とか`Algebraic`というデータ型で、`std.variant`で定義されています。
これら2つの型をうまく使うにはこの章よりももっと後の章の知識を必要としますから、ここの章ではあまり詳しく説明しませんでした。
もし共用体を使いたくなった場合には`Variant`や`Algebraic`という安全な型が存在することを思い出してみてください。

## キーワード

* 共用体(`union`)
* `std.variant`
* `Variant`
* `Algebraic`

## 仕様

* 共用体 [英語](http://dlang.org/struct.html) [日本語訳](http://www.kmonos.net/alang/d/struct.html)
* `std.variant` [英語](http://dlang.org/phobos/std_variant.html) [日本語訳](http://www.kmonos.net/alang/d/phobos/std_variant.html)
