---
layout: post
title:  "02 変数と型"
date:   2013-5-11 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は専用ページでご覧ください。}}

{% tree %}

## 式(Expression)と文(Statement)とは？

D言語のプログラムが関数とデータの集合であることは前の章で説明しましたね。
では、関数は何で構成されているのでしょうか。
その答えは文(statement)です。
`void main(){}`というのも実際には宣言文(Declaration Statement)ですし、`import std.stdio;`もインポート宣言(Import Declaration)という文です。
さらに、`writeln("Hello, World!");`も文です。
ということで、D言語のプログラムは文の集合だったりします
また、文は文で構成されたり、式(expression)で構成されます。
たとえば、`writeln("Hello, World!")`は式ですが、`;`を付けることで`writeln("Hello, World!");`となり文となります。
`"Hello, World!"`も式ですし、`123`も式です。


## 変数(Variable)

電卓にはメモリー機能というのがありますね。
使ったことがないなら、これからは使ってみることをオススメします、便利ですよ。
さて、プログラムでもメモリー機能が使えます。
それが変数です。
式の値は変数に格納しておくことができます。
また、変数は電卓のメモリ機能と違い、宣言しないと使えませんが、たくさん使用することが可能です。

````d
///src.d
import std.stdio;

void main()
{
    int a = 1 + 2;
    writeln(a);

    a = 3 + 1;
    writeln(a);

    a = a + 2;
    writeln(a);
}
````

````
$ rdmd src.d
3
4
6
````

変数は宣言した場所以降から有効になります。
例では、`int a = 1 + 2;`というのが変数の宣言の部分で、`int`型の変数`a`を宣言しています。
次の行の`writeln(a);`では`a`の値である`3`を表示します。
また、`a`は宣言したあとは自由に書き換えられます。
`=`は代入演算子で、右辺(rhs)の値を左辺(lhs)にセットします。
3つめの`a = a + 2;`は奇妙かもしれませんが、`a + 2`が6ですから`a = 6;`と同じです。


### 変数の宣言(Declaration)

変数の宣言は`Type identifier;`、もしくは初期化する場合は`Type identifier = initializer;`となります。
また、一度に複数宣言することもできて、`T a, b, c;`と書いたり、初期化したい場合には、

~~~~d
int a = 12,
    b = a + 1,
    c = a + b,
    d;
~~~~

という風にも書けます。

初期化の話が出ましたが、D言語では変数は宣言されたら自動的に初期化されます。
この初期化される値をデフォルト初期化値(デフォルト値, デフォルト初期化子; Default Initializer)といいます(後述)。


### 変数の寿命とスコープ

変数には寿命があり、そのスコープ内でのみ有効です。
ここでいうスコープとは、静的スコープ(Static Scope)や構文スコープ(Lexical Scope)と呼ばれるもののことです。
簡単にいうと、`{`から、それに対応する`}`までがスコープになります。
特に、最も外のスコープであるスコープはグローバルスコープ(Global Scope)と呼ばれます。

スコープは`{}`などによってネスト(nest; 入れ子状態のこと)されます。
宣言された変数などをシンボル(Symbol)と呼びますが、外側のスコープから内側のスコープのシンボルを覗くことはできません。
しかし、内側のスコープから外側のスコープのシンボルを覗くことは可能です。
ですので、外側のスコープで宣言されたシンボルと同じ名称のシンボルを内側のスコープで宣言できません。

例外は2つあり、1つ目は、グローバルなシンボルと同じ名称のシンボルを、より内側のスコープで宣言することは可能です。
この場合、`.<symbol>`というように書くことで、グローバルなシンボルを指すことができます。

2つ目はまだ説明していない内容も含まれるので今回は無視していただいても構いません。
未説明なことを承知で言うと、ユーザー定義型のスコープではグローバルでない外側のシンボルを上書きできます。
こちらのケースでは、上書きされた外側のシンボルにアクセスできなくなります。
(全てのパターンで完全に消えるわけではありません。あくまでも、`<symbol>`の形式でアクセスできなくなるということです。)

~~~~d
import std.stdio;

// ここはグローバルスコープ

int a = 0;

void main()
{
    // ここはmain関数のスコープ

    double a = 1;       // グローバルなシンボルを上書きすることは可能

    writeln(a);         // 1; このスコープのa
    writeln(.a);        // 0; グローバルなa

    {
        //ここはmainより1つ内側のスコープ

        //string a;     // グローバルでないシンボルを上書きすることはできない
        string b = "foo";

        writeln(a);     // 1
        writeln(.a);    // 0
        writeln(b);     // foo

        // string型のbの寿命はここまで
    }

    {
        //writeln(b);   // このスコープから、上のスコープのbを見ることはできない
    }

    //writeln(b);       // 外側のスコープから、内側のbは見れない
    uint b;             // 内側のbは見えないから、bをシンボルとして定義してもよい

    foo();              // グローバルスコープにあるシンボルは、ソースコードで下にあっても使える
    writeln(bar);       // 同上

    // double型のaやuint型のbの寿命はここまで
}


int bar = 12;


void foo()
{
    //writeln(b);       // 0; main関数のuint型のbも、string型のbも見えない
}
~~~~


### 左辺値(lvalue)と右辺値(rvalue)

次のプログラムがおかしいことはすぐにわかると思います。

````d
int a;

a = 12;         // OK

(a + 3) = 4;    // NG
````

変数である`a`には代入できるのに、`(a + 3)`には代入できません。
というのも、変数の評価結果は左辺値(lvalue; left value)となるからです。
左辺値というのは、「`=`の左側に置ける値」という意味で理解しても構いません。

逆に、`(a + 3)`は右辺値(rvalue)といい、`=`の左側には置くことができません。

(左辺値であったとしても代入できるとは限りません。`const`や`immutable`で型修飾されていれば代入は不可能です)


## いろいろな型(Type)

D言語のデータには型があることも前の記事で書きましたが、ここではどんな型があるかを紹介します。
また、リテラルやデフォルト初期化値についても言及します。
文字型や文字列型は難しい内容が含まれているので、わからなければ読み飛ばしてもらって構いません。


### リテラル(Literal)とシンボル(Symbol)

リテラルとは、ソースコードに直接、値を記したもののことです。
プログラムが動いている間、変数は書き換えられるのに対して、リテラルはソースコードを編集しないと変更できません。
たとえば`int a = 1;`での`1`はリテラルです。

逆に、`int a = 1;`での`a`はシンボルと呼ばれます。


### デフォルト初期化値(Default Initializer; Type.init)

D言語の変数は宣言した際に初期化されます。
その際の値をデフォルト初期化値といいます。
この初期化をしてほしくない場合には、`Type iden = void;`というように`= void`とします。

~~~~d
int a;
writeln(a);         // 0; intのデフォルト初期化値は 0

writeln(int.init);  // Type.init でデフォルト初期化値を取得できる

int b = void;       // 初期化を阻止
writeln(b);         // 何が表示されるかわからない
~~~~


### void

~~~~
* void      : 値(または型)なし。
~~~~

値がない、もしくは型がないときに`void`と書きます。
前の記事でのmain関数では、`void main()`と書いていましたが、そこではmain関数の返り値が無いことを意味しています。

(厳密には、`void main()`は、プログラムが成功し正常に終了すれば`0`を返しますが、これについてはmain関数の項で説明します。)


### 論理型(Boolean)

~~~~
* bool      : 真偽値(`true`, `false`)
~~~~

真か偽かを判別するための型です。
デフォルト初期化値は`false`です。

~~~~d
bool b;

writeln(b); // false
b = !b;
writeln(b); // true

b = true;
writeln(b); // true

b = false;
writeln(b); // false
~~~~


### 整数型(Decimal Number)

~~~~
* byte      :  8bitの符号あり(signed)な整数
* ubyte     :  8bitの符号なし(unsigned)な整数
* short     : 16bitの符号あり整数
* ushort    : 16bitの符号なし整数
* int       : 32bitの符号あり整数
* uint      : 32bitの符号なし整数
* long      : 64bitの符号あり整数
* ulong     : 64bitの符号なし整数
* cent      : 128bitの符号あり整数(将来のために名前だけ付けられてる)
* ucent     : 128bitの符号なし整数(将来のために名前だけ付けられてる)

* size_t    : ポインタ値が十分に入る大きさの符号なし整数型
              32bit環境だと32bit(uint), 64bit環境だと64bit(ulong)

* ptrdiff_t : size_tと同じ大きさの符号あり整数型
~~~~

整数型には、8bitから倍々に64bitまであります(128bit型は今は使えない)。
符号あり整数型の前に`'u'`をつけると符号なし整数型になります。

また、`size_t`や`ptrdiff_t`という変わり種の整数型もあります。
整数型は、どれも`0`で初期化され、算術演算やビット演算が可能です。

````d
int a;

writeln(a);             // 0

ulong b = -1;

writeln(b);             // 18446744073709551615
                        // -1 は int型 だが、int -> long -> ulongと暗黙に変換される。
                        // longからulongへの変換によってこのようになる。

writeln(1uL - 2uL);     // 18446744073709551615
                        // 1uL は ulong型の1なので、
                        // 上のbと同様に負の数を表せず、このようになる。

writeln(1u);            // 数値の後ろに u とつけると uint型
writeln(1U);            // 大文字で U とつけても同じ

writeln(1L);            // 大文字の L をつければ long型

writeln(1uL);           // uL や、UL は ulong型
````


### 浮動小数点型(Floating-Point Number)

~~~~
()の中の3つの数字は、(符号部bit数, 指数部bit数, 仮数部bit数)
* float     : 32bitの浮動小数点の実数(1, 8, 23)
* double    : 64bitの浮動小数点の実数(1, 11, 52)
* real      : 64bit以上(システムによって違う)の浮動小数点の実数
~~~~

浮動小数点とは、コンピュータで実数値を表す方式のことです。
演算によって小数点が動くのでこのような名前になっています。
D言語の浮動小数点数はIEEE 754という規格に沿っています。
この型は、`float`なら`float.nan`, `double`なら`double.nan`, `real`なら`real.nan`で初期化されます。

なお、real型については64bit以上という言語仕様ですが、これは最低限保証するビット数であり、例えばIntelのCPUでは79bitの精度となっています。
(x87の拡張浮動小数点数では80bit(1, 15, 64)であるものの、IEEE 754では表されない整数部の1bitを無駄に使用しているため、精度で言えば79bit(1, 15, 63)相当となります)

````d
float  f = 1.0f;        // 数値の後に f をつければ float型
double d = 1.0;         // 少数点のある数値は double型
real   r = 1.0L;        // 少数点があり、最後に L が付いていると real型

writeln(f / 0);         // inf
writeln(0.0 / 0.0);     // -nan
````


### 虚数浮動小数点型(Imaginary Floating-Point Number)

````
* ifloat    : 32bitの浮動小数点の虚数
* idouble   : 64bitの浮動小数点の虚数
* ireal     : 64bit以上(システムによって違う)の浮動小数点の虚数
````

プログラミング言語では珍しい、虚数を表す型です。
それぞれ、`ifloat`なら`float.nan * 1.0i`というように初期化されます。

~~~~d
ifloat f = 1.0fi;       //  i を末尾につければ虚数型
~~~~


### 複素浮動小数点型(Complex Floating-Point Number)

````
* cfloat    : 32bitの浮動小数点の複素数, 64bit
* cdouble   : 64bitの浮動小数点の複素数, 128bit
* creal     : 64bit以上(システムによって違う)の浮動小数点の複素数(64bit以上 * 2の大きさ)
````

実部と虚部を持つ型です。これもプログラミング言語では珍しいです。
それぞれ、`cfloat`なら`float.nan + float.nan * 1.0i`という値で初期化されます。


### 文字型(Charactor)

~~~~
* char      : UTF-8でエンコードされた文字(8bit)
* wchar     : UTF-16でエンコードされた文字(16bit)
* dchar     : UTF-32でエンコードされた文字(32bit)
~~~~

D言語で文字型を使用すると、その文字はUTF-8かUTF-16, UTF-32でエンコードされていると認識されます。
もし、Unicode以外でエンコーディングされた文字を格納する場合には、`ubyte`や`ushort`, `uint`を使用するべきです(邦訳TDPL 118ページ参照)。
また、デフォルト初期化値はそれぞれ、`0xFF`, `0xFFFF`, `0x0000FFFF`です。


### 文字列型(String)

~~~~
* string    : 文字列型(immutable(char)[])
* wstring   : 文字列型(immutable(wchar)[])
* dstring   : 文字列型(immutable(dchar)[])
~~~~

こちらも文字型を同じようにUTF-8, UTF-16, UTF-32でエンコードされていると仮定されます。
ですから、Unicode以外でエンコーディングされた文字列を格納するなら、`ubyte[]`や`immutable(ubyte)[]`, `ushort[]`, `immutable(ushort)[]`, `uint[]`, `immutable(uint)[]`を使用するべきなのです。
(例えば `std.encoding` モジュールでは、ASCIIコードの文字列を表現するのに `immutable(ubyte)[]` が使用されています)

~~~~d
//import std.utf;       追加でこの2つをimportする
//import std.range;

string  utf8  = "ほげほげ";
wstring utf16 = "ほげほげ"w;
dstring utf32 = "ほげほげ"d;

writeln(utf8);                                  // ほげほげ
writeln(utf16);                                 // ほげほげ
writeln(utf32);                                 // ほげほげ

writeln( utf8[std.utf.stride( utf8, 0) .. $]);  // げほげ
writeln(utf16[std.utf.stride(utf16, 0) .. $]);  // げほげ
writeln(utf32[1 .. $]);                         // げほげ

writeln(std.range.drop( utf8, 2));              // ほげ
writeln(std.range.drop(utf16, 2));              // ほげ
writeln(std.range.drop(utf32, 2));              // ほげ
~~~~


### 派生型(Derived Data Type)

~~~~
* T*        : T型に対するポインタ型(Pointer)
* T[]       : T型を要素とするスライス(Slice)(動的配列; Dynamic Array)
* T[N]      : T型を連続してN要素集めた型。静的配列(Static Array)
* V[K]      : K型の値に対してV型の値が1:1で対応する型。連想配列(Associative Array)
* R function(T...)
            : T...型を受け取ってR型の値を返す関数ポインタ型
* R delegate(T...)
            : T...型を受け取ってR型の値を返すデリゲート(委譲)型
~~~~

これらの型については後ほど個々に詳しく書きます。


### ユーザー定義型(User Defined Type)

~~~~
* enum      : 列挙型
* struct    : 構造体
* union     : 共用体
* class     : クラス
* interface : インターフェース
~~~~

ユーザー(プログラマ)が、いろいろな型を組み合わせて新しい型を作るための型です。
これらについては各々独立した記事を書きます。


## 型修飾子(Type Qualifiers)

型に修飾子を付けることによって、様々な情報を型に付加させることができます。


### const

`const`で修飾された型の値は、その参照経由では変更不可能です。
`const`は推移的であり、修飾された型を構成する型も`const`型になります。
あくまでも「`const`な参照経由では変更不可能」なだけなので、ある程度の型であれば`const`型以外へも暗黙変換可能です。

ここでいう「ある程度の型」とは、値型である`int`や`ulong`, 参照を持つがその参照経由で変更ができない`const(T)*`, `immutable(T)*`などです。

~~~~d
void main()
{
    int a;
    const(int*) p = &a;     // すべての型はconstに暗黙変換可能

    //*p += 3;              // Error: cannot modify const expression *p
                            // constは推移的なので、*pはconst(int)型
                            // constなデータは書き換え不可なのでエラーがでる

    int* q = &a;            // constでないポインタ
    *q = 13;                // 書き換え可能

    const(int*) cq = q;     // 非const型からconst型へは暗黙変換可能
    //q = p;                // 逆は不可能
}
~~~~


### immutable

`immutable`型は、生まれたら死ぬまで絶対に書き換わらない型で、`const`同様に推移的です。
`const`へ暗黙変換可能ですが、非`immutable`かつ非`const`型以外へは暗黙変換不可能です。
また`const`型と同様に、値型である`int`や`ulong`, 参照を持つが`immutable`への参照である`immutable(T)*`などは`immutable`型へ暗黙変換可能です。

~~~~d
int a;
//immutable(int)* p = &a;   //Error: cannot implicitly convert expression (& a) of type int* to immutable(int)*
                            // &aはint*なのでimmutable型へは暗黙変換不可

immutable(int) b;

immutable(int*) p = &b;     // OK
                            // immutable(int)*からimmutable(int*)への暗黙変換は可能

immutable(int)* r = &b;
//*r += 3;                  // Error: cannot modify immutable expression *r
                            // immutable型は変更不可能
~~~~

`immutable`も`const`も推移的なので、`immutable(const(int)*)`は`immutable(int*)`に等価です。例を示しておきましょう。

~~~~
immutable(immutable(T))     ->      immutable(T)
immutable(const(T))         ->      immutable(T)
const(immutable(T))         ->      immutable(T)
const(const(T))             ->      const(T)

immutable(immutable(T)*)    ->      immutable(T*)
immutable(const(T)*)        ->      immutable(T*)
const(immutable(T)*)        ->      変化しない
const(const(T)*)            ->      const(T*)
~~~~


### shared

shared型は、複数のスレッドからアクセスされるために、知らぬ間に書き換わっているかもしれない型であることを表します。

~~~~d
int a;

//shared(int)* p = &a;      // Error: cannot implicitly convert expression (& a) of type int* to shared(int)*
shared(int)* q = cast(shared)&a;
~~~~


## 記憶域クラス(Storage Class)

記憶域クラスとは、変数の特性を指定する修飾子のことです。


### const

`const(Type)`型と等しくなります。

~~~~d
const int a = 12;       // const(int) a = 12;と書くのと等しい
~~~~


### immutable

`immutable(Type)`型と等しくなります。

~~~~d
immutable int a = 12;   // immutable(int) a = 12;と等しい
~~~~


### shared

`shared(Type)`型と等しくなります。

~~~~d
shared int a = 12;
~~~~


### scope

`scope`の意味は、その参照がスコープの外に置かれることがないということです。
つまり、グローバル変数への代入や`return`を使って関数外へ送ることは不正です。

またその仕様から、`scope`変数を`new`を用いてクラスのインスタンスで初期化していれば、そのインスタンスはスコープを抜ける際に破棄されるという仕様もありますが、この機能は後ほど非推奨な機能となりますので、クラスの場合には`std.typecons.scoped`を使いましょう。

~~~~d
class Foo{ this(){}; }

scope foo = new Foo();  // スタックへ割り当てられる
                        // スコープを抜けると同時に破棄される

// クラスに対するscopeは、そのうち「非推奨な機能」となるためstd.typecons.Scopedを使うとよい
import std.typecons;
auto bar = scoped!Foo();
~~~~


### 関数でのみ有効となる記憶域クラス

その他にも記憶域クラスはありますが、関数引数や関数そのものに対してのみ有効であるので、随時説明していきます。
以下に、そのような記憶域クラスのリストを挙げておきます。

* `in`
* `out`
* `ref`
* `lazy`
* `inout`


## 型推論(Type Inference)

たとえば、`int a = 12;`という記述は冗長的だと思いませんか？
`12`は`int`型のリテラルなのに、`int a`とちゃんと型を宣言する必要があるでしょうか？

そのようなことから、D言語ではいろいろな部分で型推論なされます。
型推論とは、明示的に型宣言しなくても、その値が生成される式の型から自動的に型を決定する機能です。

もし、初期化子があるのであれば、`int`の代わりに`auto`を使うことで、変数の型が(コンパイル時に)自動的に決定されます。

~~~~d
auto a = 12;
pragma(msg, typeof(a)); // int

auto b = "ほげほげ";
pragma(msg, typeof(b)); // string

auto c = a + 13.5;
pragma(msg, typeof(c)); // double

const d = 3;
pragma(msg, typeof(d)); // const(int)

immutable e = 4;        // 記憶域クラスのみでも型推論される
pragma(msg, typeof(e)); // immutable(int)
~~~~


## 問題 -> [解答]({{ site.baseurl }}/dmanual/answer#variable_type)

* ビッグエンディアンとリトルエンディアンについて調べてみましょう。

* 次のソースコードをコンパイルして、エラーメッセージを読んでみましょう。

~~~~d
void main()
{
    intt a;         // intでないのに注意
}
~~~~

* 問題募集中


## おわりに

お疲れ様です。
東進の先生の「基礎の基礎が怖いってことを、今日何度も言っておきます」という言葉がありますが、プログラミングは本当にその言葉に当てはまります。
今回と次回は「基礎の基礎」なので、退屈かもしれませんが確実に習得してもらいたい内容です。
しかし、たぶん無理なので、今回と次回の内容はいつでも見れるようにしておきましょう。
ちなみに、次回は「式と演算子」について書くと思います。


## キーワード

* 式(Expression)
* 文(Statement)
* 宣言(Declaration)
* 変数(Variable)
* スコープ(Scope)
* シンボル(Symbol)
* グローバルスコープ(Global Scope)
* 値(Value)
* 型(Type)
* リテラル(Literal)
* シンボル(Symbol)
* デフォルト初期化値(デフォルト値, デフォルト初期化子; Default Initializer)
* void
* 論理型(Boolean); `bool, true, false`
* 整数型(Decimal Number); `byte, ubyte, short, ushort, int, uint, long, ulong, cent, ucent, size_t, ptrdiff_t`
* 浮動小数点型(Floating-Point Number); `float, double, real`
* 虚数浮動小数点型(Imaginary Floating Point); `ifloat, idouble, ireal`
* 複素数浮動小数点型(Complex Floating-Point Number); `cfloat, cdouble, creal`
* 文字型(Charactor); `char, wchar, dchar`
* 文字列型(String); `string, wstring, dstring`
* 派生型(Derived Data Type); 
* ユーザー定義型(User Defined Type); `enum, struct, union, class, interface`
* 型修飾子(Type Qualifiers)
* 記憶域クラス(Storage Class)
* 型推論(Type Inference)
