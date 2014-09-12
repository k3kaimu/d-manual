---
layout: post
title:  "05 反復処理"
date:   2013-5-26 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は専用ページでご覧ください。}}

{% tree %}

## ループとは？

反復処理(ループ)というのは、作業の繰り返しのことです。
プログラムでのループは、「決まった状態になるまで続ける」という処理を記述します。

## while文

while文は典型的なループ処理を記述できる文です。
たとえば、自然数を足していき、和が100を超えた時点での値を出力したいとします。

~~~~d
/// test00601.d
import std.stdio;

void main()
{
    int n = 1, sum;

    while(sum < 100){      // (sum < 100) がtrueの間は繰り返す
        sum += n;
        ++n;
    }

    writeln(n-1);
    writeln(sum);
}
~~~~

~~~~
$ rdmd test00601.d
14
105
~~~~

例の`while`は、数学をしらない人間が愚直に100になるまで足していく、という作業をそのまま表しています。
実際に`14`までの和は、`14 * (14 + 1) / 2 => 105`ですし、`13`までの和は`105 - 14 => 91`となりますから、正常に計算できているようです。

最後のほうで`writeln(n-1);`となっていますが、なぜ`n`じゃなくて`n-1`なのでしょうね？
少し考えればわかると思いますので、処理の流れを理解するいい練習になると思います。

さて、`while`の詳細ですが、`while`は`if`同様に`while(<expression>) <statement>`という形式を取ります。
`while`の意味は、「`<expression>`が`true`の間、`<statement>`を実行する」ということです。
もし、最初から`<expression>`が`false`であればどうなるでしょうか？
`<statement>`は一度も実行されなくなります。

~~~~d
/// test00602.d
import std.stdio;

void main()
{
    while(false)
        writeln("foooooooo");

    writeln("bar");
}
~~~~

~~~~
$ rdmd test00602.d
bar
~~~~


### 無限ループ

無限ループとは、入ったら永続的に実行され続けるループです。
`while`は無限ループを簡単に表現できます。

~~~~d
while(1)            //while(true)でもOK
    <statement>
~~~~

無限ループは後述する`for`で`for(;;)`とも書かれたりします。


## do文

`while`文の場合、条件`<expression>`が最初から`false`であれば一度も実行されないと書きました。
でも、一度は必ず実行して欲しい時があります。
その要望に答えるために、`do`文といい`do <statement> while(<expression>);`という文があります。

~~~~d
/// test00603.d
import std.stdio;

void main()
{
    int i;

    do
        writeln(i);
    while((++i) < 5);
}
~~~~

~~~~
$ rdmd test00603.d
0
1
2
3
4
~~~~

`do`文の処理の流れは、一度`<stamenet>`を実行してから、`<expression>`を評価し、`true`であればまた`<statement>`を実行し、`<expression>`を評価し、...というようになります。

`while`文とは、`<statement>`の実行と`<expression>`の評価の順序が入れ替わっただけですが、これによって絶対に1回は`<statement>`が実行されます。


## for文

一番最初に示した例`test00601.d`のループでは、条件式`sum < 100`と更新式`++n`を持つことがわかります。また、よく考えると`int n = 1, sum;`というのは`n = 1; sum = 0;`を表しているとも考えられます。これを初期化式といいます。

以上をまとめると、`test00601.d`のループには条件式と更新式、初期化式があることがわかりました。
実は、この3つを綺麗に書ける文があります。
`for`文といいます。

~~~~d
/// test00604.d
import std.stdio;

void main()
{
    int n, sum;

    for(n = 1, sum = 0; sum < 100; ++n)
        sum += n;

    writeln(n-1);
    writeln(sum);
}
~~~~

~~~~
$ rdmd test00604.d
14
105
~~~~

`for`文は、`for(初期化子; 条件式; 更新式) <statement>`という形式をとります。
処理の流れは、まず初期化子が実行され、条件式により判定されます。条件式が`true`であれば、文`<statement>`が実行されます。
`<statement>`が終われば、更新式が評価され、また条件式が通れば`<statement>`が実行され、更新式が評価され、....を繰り返します。

`for`文を`while`文で書き換えてみると、次のようになります。

~~~~d
{                   //新しいスコープを作る
    初期化子;
    while(条件式){
        <statement>
        更新式;
    }
}
~~~~

初期化式と書かずに初期化子と書いたのには理由があって、初期化子では変数の宣言ができます。
次の`for`文を使ったループの記述は、C言語の至る所で見る典型的な`for`の使い方です。  
(D言語では、後述する`foreach`を普通は使います)

~~~~d
/// test00605.d
import std.stdio;

void main()
{
    for(int i = 0; i < 5; ++i)
        writeln(i);
}
~~~~

~~~~
$ rdmd test00605.d
0
1
2
3
4
~~~~

変数`i`のスコープは、`for`文内のみなので、`for`文の外側では`i`にアクセスできません。


## foreach range文

`foreach range`文は、`for`文の特殊形式だと言えます。
`foreach(<identifier>; <exprLower> .. <exprUpper>) <statement>`という形式をとります。

`for`文で`foreach range`文を表すと、次のようになります。

~~~~d
foreach(<identifier>; <exprLower> .. <exprUpper>)
    <statement>

と、以下は同等

{                                       // 新しいスコープを作る
    auto index = <exprLower>;           // autoは型を自動でつけてくれる
    auto exprUpper = <exprUpper>;
    for(; index < exprUpper; ++index){
        auto <identifier> = index;      // <identifier>はindexのコピー
        <statement>
    }
}

さらにwhileで書き直すと

{                                       // 新しいスコープを作る
    auto index = <exprLower>;           // autoは型を自動でつけてくれる
    auto exprUpper = <exprUpper>;
    while(index < exprUpper){
        auto <identifier> = index;      // <identifier>はindexのコピー
        <statement>
        ++index;
    }
}
~~~~

たとえば、「1から10までの総和を取りたい」のなら、次のように記述します。

~~~~d
/// test00606.d
import std.stdio;

void main()
{
    int sum;

    foreach(i; 1 .. 11) //[1, 11)
        sum += i;

    writeln(sum);
}
~~~~

~~~~d
$ rdmd test00606.d
55
~~~~

`foreach range`文は、`for`文より用法が限られますが、単純な範囲を回すループを記述するのに役立ちます。

* 明示的に`<identifier>`の型を記述することも可能です。

~~~~d
foreach(ulong i; 0 .. 100)
    foo();
~~~~

* `foreach(ref <identifier>; <exprLower> .. <experUpper>)`とすることで、ループのインデックスを操作可能です。

~~~~d
foreach(ref <identifier>; <exprLower> .. <exprUpper>)
    <statement>

と、以下は同等

{                                       // 新しいスコープを作る
    auto <identifier> = <exprLower>;    // autoは型を自動でつけてくれる
    auto exprUpper = <exprUpper>;
    for(; <identifer> < exprUpper; ++<identifier>)
        <statement>
}

さらにwhileで書き直すと

{                                       // 新しいスコープを作る
    auto <identifier> = <exprLower>;    // autoは型を自動でつけてくれる
    auto exprUpper = <exprUpper>;
    while(<identifer> < exprUpper){
        <statement>
        ++<identifier>;
    }
}

例を示すと、以下のようになります。

~~~~d
/// test00607.d
import std.stdio;

void main()
{
    foreach(i; 0 .. 10){
        writef("%s, ", i);
        ++i;                // refナシなので意味なし
    }

    writeln();

    foreach(ref i; 0 .. 10){
        writef("%s, ", i);
        ++i;                // refアリなので見かけ上2ずつ進む
    }

}
~~~~

~~~~
$ rdmd test00607.d
0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
0, 2, 4, 6, 8,
~~~~


* イテレート可能な型  
`foreach range`文で、辿る範囲の型はインクリメント`++`と等価テスト`==`が定義されていればどのような型でも可能です。
たとえば、`double`などの浮動小数点型や、以下の例中に定義されている`struct Incrementable`は`++`と`==`が可能なので`foreach range`で使えます。

~~~~d
/// test00608.d
import std.stdio;

void main()
{
    foreach(i; 0.5 .. 5.5)
        writeln(i);


    foreach(e; Incrementable(0) ..  Incrementable(10))
        writeln(e);
}


struct Incrementable
{
    ref typeof(this) opUnary(string s : "++")()
    {
        ++_value;
        return this;
    }

  private:
    int _value;
}
~~~~

~~~~
$ rdmd test00608.d
0.5
1.5
2.5
3.5
4.5
Incrementable(0)
Incrementable(1)
Incrementable(2)
Incrementable(3)
Incrementable(4)
Incrementable(5)
Incrementable(6)
Incrementable(7)
Incrementable(8)
Incrementable(9)
~~~~


### foreach_reverse

`foreach range`文には、逆順に辿る`foreach_reverse`というものがあります。

~~~~d
/// test00609.d
import std.stdio;

void main()
{
    foreach(i; 0 .. 5)
        writeln(i);

    foreach_reverse(i; 0 .. 5)
        writeln(i);
}
~~~~

~~~~d
$ rdmd test00609.d
0
1
2
3
4
4
3
2
1
0
~~~~


## ループを抜ける, 次に進める

現実から抜け出したいことはよくありますよね。
少なくとも私は、毎日のように「現実を壊したい、人生をコンティニューしたい」と思ってます。
プログラムでも、ループから抜けだしたいことはありますし、コンティニューしたいことがあるんです。


### ループから抜け出す

`break`文は、ループという檻を破壊します。
つまり、ループから抜け出します。

~~~~d
/// test00610.d
import std.stdio;

void main()
{
    foreach(i; 0 .. 100){
        if(i > 10)
            break;

        writeln(i);
    }
}
~~~~

~~~~
$ rdmd test00610.d
0
1
2
3
4
5
6
7
8
9
10
~~~~

`break`文は実行されれば、最も内側のループを抜け出します。
ネストされた複数のループを抜けたい場合には、ループ文にラベルをつけて解決します。

~~~~d
import std.stdio;

void main()
{
  LbreakLabel0:
    while(1)
      LbreakLabel1:
        while(1)
            while(1)
                break LbreakLabel0;
}
~~~~

`break LbreakLabel0;`が無ければ、無限ループになって何時までたっても終わらなくなります。


### ループを次に進める

たとえば、1~50までの偶数のみの総和は`continue`を使うと次のようになります。

~~~~d
void main()
{
    int sum;

    for(int i = 0; i <= 50; ++i){
        if(i % 2 != 0)
            continue;

        sum += i;
    }

    writeln(sum);
}
~~~~

どういうことかというと、`continue`は文の実行を中止して、更新式`++i`と条件式`i <= 50`を評価します。
そして、その後また最初から文を実行します。

別の表現を使用すると、「ループされる文の最後までジャンプ」します。
例では、`sum += i;`の後までジャンプすると捉えることもできます。

また、`continue`もラベルを指定することができます。

~~~~d
import std.stdio;

void main()
{
  LcontinueLabel:
    do{
        while(1)
          LcontinueLabel1:
            while(1)
                continue LcontinueLabel;
    }while(0);
}
~~~~


## 問題 -> [解答]({{ site.baseurl }}/dmanual/answer#loop)

* `test00601.d`で、`writeln(n);`でなくて`writeln(n-1);`となっている理由は？

* `foreach_reverse`を`for`文で書き直すとどうなるでしょうか？

* 1000未満の自然数で、3の倍数もしくは5の倍数の総和を計算するプログラムをループを使って作ってください。(Project Euler Problem 1より)

* フィボナッチ数列`1, 2, 3, 5, 8, ...`を考える。数列の項の値が400万以下の偶数である項の合計を求めるプログラムを作ってください。(Project Euler Problem 2より)  

* 最初の100個の自然数の2乗の総和と、総和の2乗の差を出力するプログラムを`for`を使って作ってください。その後、`foreach`を使用するように書き換えてみましょう。(Project Euler Problem 6より)

* `while(1)`, `break`, `continue`を使って、「標準入力から得点を受け取り、平均を計算する。ただし、負の数を受け取った場合には平均と合計点を出力して終了する。また、10未満の得点は無視して平均や合計には含めないとする」ようなプログラムを作ってください。


## おわりに

おつかれさまです。
ループが書けるようになると、相当プログラムの幅が広くなります。
そのため、今回の問題の量はいつもより多いと思います。

次はその他の制御文として、`goto`, `switch`の紹介をしたいと思います。


## キーワード

* `while`
* `do-while`
* `for`
* `foreach range`
* `break`
* `continue`


## 仕様

* `while`: [英語](http://dlang.org/statement.html#WhileStatement) [日本語](http://www.kmonos.net/alang/d/statement.html#WhileStatement)
* `do-while`: [英語](http://dlang.org/statement.html#DoStatement) [日本語](http://www.kmonos.net/alang/d/statement.html#DoStatement)
* `for`: [英語](http://dlang.org/statement.html#ForStatement) [日本語](http://www.kmonos.net/alang/d/statement.html#ForStatement)
* `foreach range`: [英語](http://dlang.org/statement.html#ForeachRangeStatement) [日本語](http://www.kmonos.net/alang/d/statement.html#ForeachRangeStatement)
* `break`: [英語](http://dlang.org/statement.html#BreakStatement) [日本語](http://www.kmonos.net/alang/d/statement.html#BreakStatement)
* `continue`: [英語](http://dlang.org/statement.html#ContinueStatement) [日本語](http://www.kmonos.net/alang/d/statement.html#ContinueStatement)
