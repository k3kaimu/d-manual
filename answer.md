---
layout: post
title:  "問題の解答"
date:   2014-9-2 17:45:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は上記の専用ページでご覧ください。}}

## <a name="hello_world">D言語入門-Hello, World</a>

* 問1

~~~~d
import std.stdio;

void main()
{
    writefln("%s, %s", "Hello", "World!");
}
~~~~


* 問2

~~~~d
import std.stdio;

void main(){
    writeln("Hello, World");
}
~~~~

* 問3 解答なし


## <a name="variable_type">変数と型</a>

* 問1 解答省略

* 問2 解答なし


## <a name="expr_operator">式と演算子</a>

* 問1

コンピュータでは、負の数は2の補数を用いて表されます。
2の補数の前に1の補数の説明をしましょう。

2進数における1の補数とは、各ビットの反転になります。
たとえば、8bitの`3`は`00000011`ですから、1の補数は`11111100`になります。
2の補数は、この1の補数に1を加算した値です。
すなわち、`11111101`が`3`の2の補数で、`-3`の2進数表現です。

このようにすることで、例えば`3 + -3`は

~~~~
  00000011
+ 11111101
----------
 100000000

->00000000   <- 先頭1bit(MSB)を無視した8bitは0を示す
~~~~

というように、オーバーフローしてちゃんと`0`になります。

`>>`はMSBを維持しながら、シフトするので、`-3 >> 1`は`11111110`になります。
`11111110`は、10進数表現に直すとどうなるかが問題ですが、逆に`1`を引いてからビット反転すれば、絶対値の10進数表現になります。
つまり、`11111110 - 1 => 11111101 =(flip)> 00000010`となり、`-2`であることがわかります。

* 問2

`>>>`は符号を維持しませんが、ビット表現の特性で`<<`はオーバーフローしない限り符号を維持し続けます。
というのは、正の数であれば、整数値はMSBから`0`がいくつか続いた後`1`がやっと出現します。
負の数であれば、MSBはからは`1`が幾つか続いた後`0`がやっと出現します。
よって、オーバーフローにならない限りは、値の符号は変わらないことがわかります。


## <a name="standardinput">標準入力と文字と文字列</a>

* 問1

~~~~d
import std.stdio;
import std.array;

void main()
{
    string line = readln();
    line.popFront();
    line.popFront();
    write(line);

    line = readln();
    line.popFront();
    line.popFront();
    write(line);

    line = readln();
    line.popFront();
    line.popFront();
    write(line);
}
~~~~


* 問2

~~~~
%2$s - %1$x1016
~~~~


* 問3

~~~~
3
3
~~~~

## <a name="if">条件分岐</a>

* 問1 ブロックに注意


## <a name="loop">ループ</a>

* 問1

インクリメントに注意


* 問2 解答例

~~~~d
{
    auto index = <exprUpper>;
    auto exprLower = <exprLower>;
    for(; index > exprLower; --index){
        auto <identifier> = index - 1;
        <statement>
    }
}
~~~~


* 問3

~~~~d
import std.stdio;

void main()
{
    int sum;

    foreach(i; 0 .. 1000)
        if((i % 3) == 0 || (i % 5) == 0)
            sum += i;

    writeln(sum);
}
~~~~


* 問4

~~~~d
import std.stdio;

void main()
{
    int fib = 1;
    int fib_1 = 1;
    int fib_2 = 0;

    int sum = 0;

    while(fib < 4_000_000)
    {
        if(fib % 2 == 0)
            sum += fib;

        fib_2 = fib_1;
        fib_1 = fib;
        fib = fib_2 + fib_1;
    }

    writeln(sum);
}
~~~~


* 問5

~~~~d
import std.stdio;

void main()
{
    int sumPow2;
    int pow2Sum;

    foreach(i; 1 .. 101){
        sumPow2 += i;
        pow2Sum += i ^^ 2;
    }

    sumPow2 ^^= 2;
    writeln(sumPow2 - pow2Sum);
}
~~~~

~~~~
25164150
~~~~


* 問6

~~~~d
import std.stdio;

void main()
{
    int cnt;
    int sum;

    while(1){
        int n;
        readf("%s\n", &n);

        if(n < 0){
            writeln(sum / cnt);
            break;
        }else if(n < 10)
            continue;

        sum += n;
        ++cnt;
    }
}
~~~~

## <a name="other_statements">その他の制御文</a>

* 問1

~~~~d
import std.stdio, std.string;

void main()
{
    int v1, v2;
    string op;

    readf("%s %s %s", &v1, &op, &v2);

    switch(op){
        case "+":
            writeln(v1 + v2);
            break;

        case "-":
            writeln(v1 - v2);
            break;

        case "*":
            writeln(v1 * v2);
            break;

        case "/":
            writeln(v1 / v2);
            break;

        default:
            writeln("数式がおかしいよ！");
            return;
    }
}
~~~~

## <a name="array">配列</a>

* 問1  

~~~~d
import std.stdio;

void main()
{
    int[] arr = [0, 2, 4, 1, 3, 5];

    foreach(e; arr)
        writeln(e);
}
~~~~


* 問2  

~~~~d
import std.stdio;

void main()
{
    int[] arr = [0, 2, 4, 1, 3, 5];

    foreach_reverse(e; arr)
        writeln(e);
}
~~~~

又は

~~~~d
import std.stdio;

void main()
{
    int[] arr = [0, 2, 4, 1, 3, 5];

    for(int i = arr.length -1; i >= 0; --i)
        writeln(arr[i]);
}
~~~~

* 問3  

~~~~d
import std.stdio;

void main()
{
    int[] arr = [0, 2, 4, 1, 3, 5];

    writefln("%([%03d]%|\n%)", arr);
}
~~~~


## <a name="string">文字列</a>

* 問1  

~~~~d
import std.ascii;
import std.stdio;

void main()
{
    foreach(i; 0 .. char.max+1)
        if(isPrintable(cast(char)i))
            writefln("0x%x : %s", i, cast(char)i);
}
~~~~


* 問2  

~~~~d
import std.conv;
import std.stdio;
import std.string;

void main()
{
    immutable num1 = readln.chomp.to!int,
              num2 = readln.chomp.to!int;

    writeln(num1 + num2);
}
~~~~


* 問3  

~~~~d
import std.array;
import std.conv;
import std.regex;
import std.stdio;
import std.string;

void main()
{
    auto r = regex(r"(?:-|\+)?[0-9](?:[0-9],[0-9]|,[0-9]|[0-9])*(?:\.[0-9]+)?", "g");
    auto doc = readln.chomp;

    real sum = 0;

    foreach(c; doc.match(r)){
        writeln(c);
        sum += c.hit.replace(",", "").to!real;
    }

    writefln("%.3f", sum);
}
~~~~


## <a name="associative_array">連想配列</a>

* 問1  

~~~~d
import std.conv;
import std.stdio;
import std.string;

void main()
{
    auto n = readln().chomp().to!size_t();
    int[string] dict;

    foreach(unused; 0 .. n){
        string[] splitted = readln().chomp().split();
        dict[splitted[0]] = splitted[1].to!int;
    }

    foreach(name; dict.keys.sort)
        writefln("%-12s\t\t%s", name, dict[name]);
}
~~~~


以下は別解

~~~~d
import std.algorithm;
import std.conv;
import std.stdio;
import std.string;
import std.typecons;

alias ListElem = Tuple!(string, "name",
                        int,     "value");

void main()
{
    auto n = readln().chomp().to!size_t();
    ListElem[] list;

    foreach(unused; 0 .. n){
        string[] splitted = readln().chomp().split();
        list ~= ListElem(splitted[0], splitted[1].to!int());
    }

    foreach(e; list.sort!"a[0] < b[0]"())
        writefln("%-12s\t\t%s", e[0], e[1]);
}
~~~~


* 問2  

~~~~d
import std.conv;
import std.stdio;
import std.string;

void main()
{
    auto n = readln().chomp().to!size_t();
    string[][int] dict;

    foreach(unused; 0 .. n){
        string[] splitted = readln().chomp().split();
        dict[splitted[1].to!int] ~= splitted[0];
    }

    foreach(value; dict.keys.sort){
        foreach(name; dict[value].sort)
            writefln("%-12s\t\t%s", name, value);
    }
}
~~~~


以下は別解

~~~~d
import std.algorithm;
import std.conv;
import std.stdio;
import std.string;
import std.typecons;

alias ListElem = Tuple!(string, "name",
                        int,     "value");

void main()
{
    auto n = readln().chomp().to!size_t();
    ListElem[] list;

    foreach(unused; 0 .. n){
        string[] splitted = readln().chomp().split();
        list ~= ListElem(splitted[0], splitted[1].to!int());
    }

    list.multiSort!("a[1] < b[1]", "a[0] < b[0]")();
    foreach(e; list)
        writefln("%-12s\t\t%s", e[0], e[1]);
}
~~~~


## [<a name="function">関数</a>](function.md)

* [問1](function.md#Q1)

~~~~d
import std.conv, std.stdio, std.string;

int readInt()
{
    return readln().chomp().to!int();
}
~~~~

* [問2](fuction.md#Q2)

~~~~d
int sum(int[] arr) pure nothrow @safe
{
    int s;

    foreach(e; arr)
        s += e;

    return s;
}
~~~~

もし、`std.algorithm.reduce`を使うなら、以下のようになります。

~~~~d
import std.algorithm;

int sum(int[] arr) pure nothrow @safe
{
    return reduce!"a + b"(0, arr);
}
~~~~


* [問3](function.md#Q3)

`return 0;`など、適当な値を返すよりも、`assert(0);`を入れておく方が良いプログラムになります。

~~~~d
import std.stdio;

int g1 = 1,
    g2 = 10,
    g3 = 20;


int getGlobalValue(size_t idx) nothrow @safe
{
    switch(idx){
        case 1:
            return g1;

        case 2:
            return g2;

        case 3:
            return g3;

        default:
    }

    assert(0);
}


void main()
{
    writeln(getGlobalValue(1));
    writeln(getGlobalValue(10));
    writeln(getGlobalValue(20));
}
~~~~


* [問4](function.md#Q4)

`return;`で`main`関数を終わらせれば良い。

~~~~d
import std.getopt;
import std.stdio;


immutable appInfo = `example:
$ add --a=12 --b=13
a + b = 25

$ add --b=1, --a=3
a + b = 4`;


void main(string[] args) @safe
{
    int a, b;
    bool h_sw;              // argsに-h, --helpが出現したかどうか

    getopt(args,
        "a", &a,
        "b", &b,
        "h|help", &h_sw);

    if(h_sw){
        writeln(appInfo);
        return;
    }

    writeln("a + b = ", a + b);
}
~~~~


* [問5](function.md#Q5)

~~~~d
int gt(int a, bool b = false) nothrow @safe
{
    static int sum;

    if(b)
        sum = 0;

    sum += a;
    return sum;
}
~~~~


* [問6](function.md#Q6)

~~~~d
int taggedGt(string tag, int a, bool clear = false, bool delete_ = false) nothrow @safe
{
    static int[string] sum;

    if(clear)
        sum[tag] = 0;

    if(delete_){
        sum.remove(tag);
        return a;
    }else{
        sum[tag] += a;
        return sum[tag];
    }
}
~~~~


* [問7](function.md#Q7)

~~~~d
auto createCounter() pure nothrow @safe
{
    size_t a;

    size_t counter(){
        return ++a;
    }

    return &counter;
}
~~~~

もし、ラムダを使うなら次のほうが短い。

~~~~d
auto createCounter() pure nothrow @safe
{
    size_t a;

    return () => ++a;
}
~~~~


* [問8](function.md#Q8)

1.

~~~~d
import std.algorithm;

int sumOfEven(int[] arr) pure nothrow @safe
{
    return reduce!"a + b"(0, arr.filter!"!(a&1)"());
}
~~~~

2.

~~~~d
import std.algorithm;
import std.math;

int getApprxEqElm(int[] arr, int needle) pure @safe
{
    int f(int a, int b) nothrow @safe
    {
        int diffA = abs(a - needle),
            diffB = abs(b - needle);

        return diffA > diffB ? b : a;
    }

    return reduce!f(arr);
}
~~~~


## <a name="main">メイン関数</a>

## <a name="io">ファイルと標準入出力</a>

* 問1

~~~~d
import std.range,
       std.stdio;

void main()
{
    foreach(i; 0 .. 3){
        auto line = readln();

        // もしくはline.popFrontN(2);
        foreach(j; 0 .. 2)
            line.popFront();

        write(line);
    }
}
~~~~

もしくは、`std.range.drop`を使って以下のように書けます。

~~~~d
import std.range,
       std.stdio;

void main()
{
    foreach(_; 0 .. 3)
        readln().drop(2).write();
}
~~~~



* 問2

1.

~~~~d
import std.file;

void copyTo(string from, string to)
{
    to.write(from.read());
}
~~~~

2.

~~~~d
void copyTo(string from, string to)
{
    auto fromFile = File(from);
    auto toFile = File(to, "w");

    foreach(buf; fromFile.byChunk(4096))
        toFile.rawWrite(buf);
}
~~~~


* 問3

~~~~d
import std.conv,
       std.stdio,
       std.string;

void main()
{
    immutable filename = readln().chomp(),
              N = readln().chomp().to!int();

    auto file = File(filename, "w");

    foreach(i; 0 .. N)
        file.write(readln());
}
~~~~
