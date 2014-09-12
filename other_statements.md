---
layout: post
title:  "06 その他の制御構文"
date:   2013-6-16 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は専用ページでご覧ください。}}

{% tree %}

## goto文とラベル

アセンブリ言語や機械語を書いたことのある人なら「ジャンプ命令」は知っていると思います。
「ジャンプ命令」とは、プログラムの実行位置(制御位置)を指定アドレスに移動する命令です。
アセンブリ言語では、`for`文とか`foreach`, `while`, `if`などの構造化文ありませんから、それらはジャンプ命令を使って実現します。

たとえば、次のD言語のコードを、Z80アセンブラで記述し、さらにD言語のコードに変換してみましょう。

~~~~d
size_t sum;
for(size_t i = 10; i != 0; --i)
    sum += i;
~~~~

~~~~asm
        LD A,0
        LD B,10
LOOP:   ADD A,B
        DJNZ LOOP
~~~~

~~~~d
    size_t sum = 0;         // Z80アセンブラでのAレジスタ
    size_t cnt = 10;        // Z80アセンブラでのBレジスタ

  Lloop:                    // ラベル
    sum += cnt;             // ADD A,B
    if(--cnt)               // この2行は
        goto Lloop;         // DJNZ LOOPに相当
~~~~

最後のD言語のコードで出現した`Lloop:`や`goto Lloop;`というのがラベルや`goto`文というものです。
アセンブリ言語ではジャンプ命令でループを組みますが、つまり、`if`と`goto`があれば、ループ文はなくてもプログラムは書けるということです。

しかし、どう考えても`while`文や`for`、`foreach`の方が見やすく、使い勝手が良いのは明らかです。
ですので、普通は`goto`文は使いませんし、むしろ嫌われています。

嫌われている理由というのは、`goto`文は、同一関数内では、ほとんどどこにでも、たとえネストされたブロック内へもジャンプできるからです。
たとえば、次のコードの実行結果を予想してみましょう。

~~~~d
import std.stdio;

void main()
{
    size_t cnt = 4;
    size_t index;

  LloopA:
    if(--cnt)
        writeln("A: ", cnt);
    else
        goto Lend;  // ラベルがネストされたブロックにあったとしてもジャンプできる

    index = 0;

  LloopB:
    if(index == cnt)
        goto LloopA;
    else{
        writeln("\tB: ", index++);
        goto LloopB;
    }

    {
      // ネストされたブロック内にあるラベル
      Lend: {}
    }
}
~~~~

このコードは次の等価なコードに変換できます。

~~~~d
import std.stdio;

void main(){
    foreach_reverse(cnt; 1 .. 4){
        writeln("A: ", cnt);

        foreach(i; 0 .. cnt)
            writeln("\tB: ", i);
    }
}
~~~~

どうでしょうか？`foreach`を使ったほうがソースコードが見やすいですし、予想もしやすいかと思います。
このように、`goto`はたしかに強力なのですが、プログラムの流れが破綻しやすく、期待した動作が得られなかったり、
後からソースコードを読むときに理解が困難になったりします。

* goto文の制約

そんな嫌われ者の`goto`文ですが、正しく扱ってあげることによって上手いソースコードを作ることが出来ます。
正しく扱うために、D言語の`goto`文は、変数宣言を飛び越えることや`try`, `catch`, `finally`へのジャンプはできません。

~~~~d
void main()
{
    //goto Label; // Error: goto skips declaration of variable test.main.x
    int x;
  Label: {}
}
~~~~

~~~~d
void main(){
    //goto LtoTry;        // Error
    //goto LtoCatch;      // Error
    //goto LtoFinally;    // Error

    try{
      LtoTry: {}
        goto Lend;
    }
    catch(Exception){
      LtoCatch: {}
        goto Lend;
    }
    finally{
      LtoFinally: {}
        //goto Lend;      // Error
    }

  Lend: {}
}
~~~~


## switch文とcase文

たとえば、16進数の数値を表す文字列を受け取って、int型変数に数値として格納する処理を非現実的に書いてみましょう。

~~~~d
import std.stdio, std.string, std.array;

void main()
{
    auto str = readln().chomp();
    byte sign = 1;
    int value;

    if(!str.empty && str.front == '-'){
        sign = -1;
        str.popFront();
    }

    foreach(c; str){
        if(c == '0')
            value = value * 16;
        else if(c == '1')
            value = value * 16 + 1;
        else if(c == '2')
            value = value * 16 + 2;
        else if(c == '3')
            value = value * 16 + 3;
        else if(c == '4')
            value = value * 16 + 4;
        else if(c == '5')
            value = value * 16 + 5;
        else if(c == '6')
            value = value * 16 + 6;
        else if(c == '7')
            value = value * 16 + 7;
        else if(c == '8')
            value = value * 16 + 8;
        else if(c == '9')
            value = value * 16 + 9;
        else if(c == 'a' || c == 'A')
            value = value * 16 + 10;
        else if(c == 'b' || c == 'B')
            value = value * 16 + 11;
        else if(c == 'c' || c == 'C')
            value = value * 16 + 12;
        else if(c == 'd' || c == 'D')
            value = value * 16 + 13;
        else if(c == 'e' || c == 'E')
            value = value * 16 + 14;
        else if(c == 'f' || c == 'F')
            value = value * 16 + 15;
        else{
            writeln("Error !!!");
            break;
        }
    }

    value *= sign;

    writeln(value);
}
~~~~

どう考えても、非効率的ですが、こういう時に`switch`文は役に立ちます。

~~~~d
import std.stdio, std.string, std.array;

void main()
{
    auto str = readln().chomp();
    byte sign = 1;
    int value;

    if(!str.empty && str.front == '-'){
        sign = -1;
        str.popFront();
    }

    foreach(c; str){
        switch(c){
          case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
            value = value * 16 + (c - '0');
            break;

          case 'a', 'b', 'c', 'd', 'e', 'f':
            value = value * 16 + (c - 'a' + 10);
            break;

          case 'A', 'B', 'C', 'D', 'E', 'F':
            value = value * 16 + (c - 'A' + 10);
            break;

          default:
            writeln("Error !!!");
        }
    }

    value *= sign;

    writeln(value);
}
~~~~

このように、`switch`文は、内部に`case`文もしくは`default`文を持ちます。
`switch`文は、評価した式(整数型かenum型か文字列型)が`case <List>`の`<List>`に含まれていれば、その`case`までジャンプします。
もし、一致する`case`が無ければ`default`までジャンプします。
`switch`文は`break`文で脱出可能です。

また、以下の様な書き方も可能です。

~~~~d
import std.stdio, std.string, std.array;

void main()
{
    auto str = readln().chomp();
    byte sign = 1;
    int value;

    if(!str.empty && str.front == '-'){
        sign = -1;
        str.popFront();
    }

    foreach(c; str){
        switch(c){
          case '0': .. case '9':
            value = value * 16 + (c - '0');
            break;

          case 'a': .. case 'f':
            value = value * 16 + (c - 'a' + 10);
            break;

          case 'A': .. case 'F':
            value = value * 16 + (c - 'A' + 10);
            break;

          default:
            writeln("Error !!!");
        }
    }

    value *= sign;

    writeln(value);
}
~~~~

* `switch`文中の`case`への`goto`

`switch`文中では、その`switch`文の中にある`case`へ`goto`でジャンプすることができます。

~~~~d
int x;
switch(x){
  case 0:
    goto case;

  case 1:
    goto case;

  case 2:
    goto case 4;

  case 3:
    goto case 8;

  case 4:
    goto case 3;

  case 5: .. case 10:
    goto default;

  default:
    writeln("Sw End");
}
~~~~

`goto case;`は、その次の`case`文までジャンプします。
`goto case 4;`は`case 4:`までジャンプします。
`goto default;`とすると、`default:`ラベルまでジャンプします。


## 問題 -> [解答]({{ site.baseurl }}/dmanual/answer#other_statements)

* 問1  
入力として`<整数> <四則演算子> <整数>`のような文字列を受け取り、出力としてその式の結果を返すプログラムを作ってください。たとえば、`123 + 456`という文字列が入力されれば、`579`を出力するようにしてください。  
ヒント: `readf("%s %s %s", &v1, &op, &v2);`

* 問題募集中


## おわりに

お疲れ様です。
`goto`文は使うことも、見ることもあまりないと思いますが、D言語の産みの親であるWalter Brightは好きだそうで、またD言語の標準ライブラリPhobosの中でも結構使われてます。
`switch`文は、条件分岐によく使いますが、今回説明していない`final switch`という文もあるので、結構便利になっていると思います。
では、次は配列です。


## キーワード

* `goto`文
* ラベル(Label)
* `switch`文
* `case`文
* `default`文
* `goto case;`
* `goto default;`

## 仕様

* goto [英語](http://dlang.org/statement.html#GotoStatement) [日本語](http://www.kmonos.net/alang/d/statement.html#GotoStatement)

* switch [英語](http://dlang.org/statement.html#SwitchStatement) [日本語](http://www.kmonos.net/alang/d/statement.html#SwitchStatement)
