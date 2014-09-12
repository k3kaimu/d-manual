---
layout: post
title:  "04 条件分岐"
date:   2013-5-25 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は専用ページでご覧ください。}}

{% tree %}

## 文のいろいろ

復習しますと、文というのはD言語の小さな単位です。
`<expr>;`のように、式の後に`;`をつけると、それは「式`<expr>`を評価する」という文になりますし、
`{`と`}`の間に複数の文を記述すれば、「複数の文を順番に実行する」という文になります。
その他、`void main()`というのも宣言文だったり、`import`も文でした。

この記事で説明する`if`も文です。
これは制御文と呼ばれたり、構造化文と呼ばれたりします。
この2つ以外で、D言語で使える制御文は、`for`, `foreach`, `while`, `do-while`, `goto`, `break`, `continue`, `return`などです。
それらのうち構造化文は、`for`, `foreach`, `while`, `do-while`です。


## 条件分岐とは？

条件分岐というのは、「Aという状態ならBをしたいけど、そうじゃないならCを実行して！」ということです。
つまり条件によって次に何を実行するかを選択できます。


## if文

「もし～だったら、～して！」を表すのが`if`文です。
例を示しましょう。以下の動作を行うプログラムを書いてみます。

あなたは喉がひどく渇いている。
目の前に自販機があるかもしれない。
自販機があれば、財布と相談して自販機で何かを買う。

~~~~d
import std.stdio, std.string;

void main()
{
    write("あなたは喉が渇いている？(Y/N)---");
    bool isThirsty = readln().chomp() == "Y";

    if(isThirsty){
        write("自販機がある？(Y/N)---");
        bool isPlaced = readln().chomp() == "Y";

        if(isPlaced){
            write("あなたの所持金は？[円]---");
            int pocketMoney;
            readf("%s\n", &pocketMoney);

            write("あなたが欲しい飲み物の値段は？[円]---");
            int price = void;
            readf("%s\n", &price);

            if(price <= pocketMoney){
                writeln("あなたは自販機で買ってしまった。");
                writefln("もう%s[円]しかない。", pocketMoney - price);
            }else{
                writeln("あなたは購入できなかった。");
                writeln("次第に渇きが我慢できないほどになってきた。");
                writeln("数時間後、そこには意識のないあなたの姿が…");
            }
        }else{
            writeln("次第に渇きが我慢できないほどになってきた。");
            writeln("数時間後、そこには意識のないあなたの姿が…");
        }
    }else
        writeln("のどが渇いている気がしたが、ちゃんと考えればそうでもなかった。");
}
~~~~

世の中カネなのです。

それはそうと、解説です。
まず、`isThirsty`の宣言はいいですね。1行読み込んで、それが`"Y"`なら`true`となります。
`readln().chomp()`となっているのは改行文字を消すためで、なぜこのように書けるかというと、[UFCS(Uniform Function Call Syntax)](function.md#ufcsuniform-function-call-syntax)という機能のおかげです。

さて、次の`if(isThirty){`が今回のメインなわけです。
「もし～だったら、～して！」を表すのがif文だと冒頭で述べましたが、この場合には`isThirsty == true`であれば次の文を実行しろということです。
「次の文」というのは、`{`から対応する`}`までのブロック文のことです。
対応する`}`は最後の方にある`}else`の先頭の`}`です。

`else`は`else`節といい、`if`文とくっつけて使用します。
`else`節を`if`文で表すと以下のようになります。

~~~~d
bool condition = isThirsty;
if(condition)
    文1

if(!condition)
    文2
~~~~

このように、`else`節中の文は、`if`で文が実行されなかった場合に実行されます。
`else`節がいらないならば、`else`節は書かなくても大丈夫です。

~~~~d
if(isThirsty)
    writeln("自販機など存在しない世界線だった！！！");
~~~~

また、上記例のように、実行したい文が1つだけであれば、わざわざブロック文`{}`で囲まずに書けます。
`if`文が欲しているのは文なので、`{}`で囲ってなくても文であればいいのです。
そういうこともあって、`if-else`は多段にできます。

~~~~d
if(isA)
    <ThenStatementA>
else if(isB)
    <ThenStatementB>
else if(isC)
    <ThenStatementC>
else
    <ElseStatementOther>
~~~~

これは以下に等価です。

~~~~d
if(isA)
    <ThenStatementA>
else
    if(isB)
        <ThenStatementB>
    else
        if(isC)
            <ThenStatementC>
        else
            <ElseStatementOther>
~~~~

考えてみれば簡単なことですよね。


## boolと評価される式

実は、`if(<condition>)`の`<condition>`式のように、特別な場所では`bool`型以外の型も`bool`型に暗黙に変換されます。
たとえば数値型であれば非ゼロな値は`true`となります。
まだ説明していない型ですが、ポインタやクラスであれば、非ヌル`a !is null`の場合に`true`と評価されます。
また`opCast!bool`を持っている構造体と共用体においては、`opCast!bool`の評価結果となります。

~~~~d
import std.stdio;


void main()
{
    // 数値型
    int a = -12;            //マイナスも非ゼロなのでtrue
    if(a)
        writeln("a != 0 == true");

    // ポインタ型
    int* p = &a;
    if(p)
        writeln("p !is null == true");

    // opCast!boolを持つ構造体
    S s;
    if(s)
        writeln("s.opCast!bool == true");

    // opCast!boolを持つ共用体
    U u;
    if(u)
        writeln("u.opCast!bool == true");

    // クラス
    C c = new C;
    if(c)
        writeln("c !is null == true");
}


/// opCast!boolを持っている構造体
struct S
{
    bool opCast(T : bool)()
    {
        return true;
    }
}


/// opCast!boolを持っている共用体
union U
{
    bool opCast(T : bool)()
    {
        return true;
    }
}


/// クラス
class C{}
~~~~


## if(宣言)な文

if文のカッコの中では変数を宣言できます。
この構文は、`opCall!bool`を定義している構造体や共用体、ポインタやクラスを返す関数の返り値を検査したい場合に大変有効です。

例として、正規表現モジュール`std.regex`を使用する場合の活用の仕方を見てみましょう。

~~~~d
import std.regex;
import std.stdio;

void main()
{
    foreach(line; stdin.byLine){
        // 入力の最初の行に与えられた、最初の数値にマッチ
        if(auto m = line.match(regex(`\d+`)))
            writeln(m.hit);     // 数値を表示
        else
            writeln();          // マッチしなければ改行だけ
    }
}
~~~~

入力:

~~~~
foobar123
foo222
foo
111222
~~~~

出力:

~~~~
123
222

111222
~~~~

なにが嬉しいかというと、`m`の使用出来る範囲(スコープ)が`if`文中だけになることです。
このうれしさはプログラムをバリバリ書けるようになってくると実感します。

ちなみに、`else`節では`m`は使えません。


## &&(且つ)と||(又は)

「`isA`かつ`isB`、もしくは`isC`であれば実行したい」とします。
次のように書けば実現可能ですけど、プログラムがかなり複雑になります。

~~~~d
if(isA){
    if(isB)
        writeln("OK");
    else if(isC)
        writeln("OK");
}else if(isC)
    writeln("OK");
~~~~

さて、復習です。
`&&`や`||`という演算子がありました。
`&&`は論理積, `||`は論理和を計算する演算子でした。
これを使うと、先ほどの例は簡単になります。

~~~~d
if((isA && isB) || isC)
    writeln("OK");
~~~~


## 問題 -> [解答]({{ site.baseurl }}/dmanual/answer#if)

* まずは次のコードの実行結果を予想してみてください。その後実行してみて、予想と違うなら理由を考えてください。

~~~~d
import std.stdio;

void main(){
    int a = 12;

    if(a == 12)
        writeln("aは12");
    else
        writeln("aは12じゃない");
        a = 5;

    if(a != 12)
        writeln("aは12じゃない");
    else
        writeln("aは12");
}
~~~~


* ブール代数という数学の分野があります。次の2式は完全に同じことを記述しているのですが、ブール代数によってそれが本当か判定してみましょう。

    + (a && c) || (b && c)  
      (a || b) && c  

    + (a && b) || a  
      a  

    + (a || b) && a  
      a  

    + !(a && b)  
      (!a || !b)  

    + !(a || b)  
      (!a && !b)  


## おわりに

おつかれさまです。
今回は今までより短い感じでしたが、よりプログラムっぽくなってきたかと思います。
`if`文とか、プログラム読んだり書いてたら、だいたい出現するので練習しまくって使えるようにしましょう。
`if`文とかはC言語やC++, Javaなどと同じなので、そのような言語の入門サイトに載ってる練習問題を解くといいと思います。
ただ、他言語では`if(宣言)`はできないので注意してください。

では、次は「反復処理」です。


## キーワード

* 条件分岐
* `if`文
* `else`節


## if文の仕様

[英語](http://dlang.org/statement.html#IfStatement)
[日本語](http://www.kmonos.net/alang/d/statement.html#IfStatement)
