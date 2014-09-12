---
layout: post
title:  "15 構造体"
date:   2014-04-08 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は専用ページでご覧ください。}}

{% tree %}

## ユーザー定義型

今までは`int`だったり`long`、または`string`などの型を使用してプログラムを組んできましたが、この章と後のいくつかの章ではユーザー定義型について紹介していきます。
ユーザー定義型というのは、その名の通りユーザー(プログラマ)が任意に定義できる型です。
構造体などのユーザー定義型は、今までの言語定義の型(プリミティブ型)と全く同様に使用できます。

今回はその一つ目ということで、D言語では最もベーシックで、最も利用頻度が多いユーザー定義型である構造体`struct`と、それを用いた隠蔽について解説します。


## 複数の型をまとめるということ

構造体とは、簡単にいえばデータの固まりを新たに型として定義できる機能です。

もしあなたがゲームを作りたいとしましょう。
さらに少しこじつけ気味ですが、そのゲームで画面に長方形の何かを描きたいとします。
長方形は長方形の位置`float x, y`と長方形の大きさ`float width, height`で表せます。
では、複数の長方形をプログラム上で表すにはどうしましょうか？

~~~~d
float[] xs, ys, ws, hs;
// もしくは
// float[4][] rects;
~~~~~

これで複数の長方形を表せそうです。

「長方形のリストを表すために4つの配列を操作することを強いられているんだ！」

そんなことはないので、こういう場合には構造体を使いましょう。


## 構造体の基本

構造体とは、複数のデータを一つにまとめたものを表すユーザー定義型です。
たとえば、長方形を表す`Rectangle`型は次のように定義します。

~~~~d
struct Rectangle
{
    float x, y;
    float width,
          height;
}
~~~~~

`Rectangle`の内部に定義してある`x, y, width, height`をメンバ変数もしくはフィールドといいます。
構造体のメンバ変数へは次のようにメンバ変数名を用いてアクセス可能です。

~~~~d
Rectangle rect; // Rectangle型の変数rectを宣言

rect.x = 5.5;   // xに5.5を代入

// x = 1, y = 3, width = 10.5, height = 2.3 な Rectangleを代入
rect = Rectangle(1, 3, 10.5, 2.3);

// メンバ変数を指定して初期化, 宣言時のみ有効
Rectangle rect2 = {x : 1, width : 3, y : 4, height : 2};
~~~~~

`Rectangle`型は、今までの`int`や`long`等のプリミティブ型と同様に使用できます。
もちろん、デフォルト初期化値`Rectangle.init`も有効です。
今回の`Rectangle`のデフォルト初期化値は、それぞれのメンバ変数のデフォルト初期化値になりますが、
次のように`Rectangle`を定義することでデフォルト初期化値を変更できます。

~~~~d
struct Rectangle
{
    float x;
    float y;
    float width = 0;
    float height = 0;
}
~~~~~

元の初期化値は`Rectangle(float.nan, float.nan, float.nan, float.nan)`ですが、2つ目の`Rectangle`の初期化値は`Rectangle(float.nan, float.nan, 0, 0)`となります。

最初に例として提示した`Rectangle`の配列は、当然ですが型は`Rectangle[]`となり、`int[]`などと同様に使用可能です。

~~~~d
Rectangle[] rects;

rects ~= Rectangle(1, 1, 2, 2);
rects ~= [Rectangle(1, 1, 3, 3),
          Rectangle(2, 2, 4, 4.4)];

foreach(e; rects)
    writefln("面積 S = %s", e.width * e.height);

foreach(i; 1 .. rects.length){
    rects[i-1].x += rects[i].x;
    rects[i-1].y += rects[i].y;
}

writeln(rects);
~~~~~


## 構造化プログラミングとその発展

昔(1970~80)は(というより今でも)データ構造と手続き(関数)を一緒に考える構造化プログラミングスタイルが主流でした。
さらにその昔は混沌としたプログラミングスタイルでしたから、
データ構造と、それを扱う専用の関数を考えるというこのスタイルは素晴らしいといえます。
混沌とした世の中に構造化プログラミングを提唱したダイクストラは、手続きとデータの両方が抽象化されるべきであると彼の論文"Structured Programming"(1969)にて主張しています。
手続きとデータ構造の両方を抽象化する利点は、データ構造に変更を加えるような修正を行う場合や、複雑なデータ構造を上手く隠しながらプログラムを作る時に最も効力を発揮します。
データ構造が変わったとしても、それを扱う手続きをまとめた関数さえ修正すれば、プログラム全体の動作に影響を与えなくて済みますし、複雑なデータ構造であっても関数によって覆い隠されてしまえば、簡単に扱えるようになるのです。
これをデータのカプセル化(隠蔽)といい、現代のプログラミング技術では必須となっています。

ダイクストラが構造化プログラミングを提唱する数年前に、Simulaという言語が登場し、後に登場するオブジェクト指向言語はこのSimulaに影響を受けたというお話はまた別の機会に。


## メンバ関数

データ構造とそれを扱う専用の手続きを一緒に扱うことによって、素晴らしいプログラムが書けることは構造化プログラミングから学べることでした。
データ構造は、構造体によって構築できそうですが、その構造体を扱う専用の関数はどのように記述するのが最も適切でしょうか？

たとえば、長方形`Rectangle`を`(dx, dy)`だけ平行移動する関数`translate`は次のように書けます。

~~~~d
void translate(ref Rectangle rect, float dx, float dy)
{
    rect.x += dx;
    rect.y += dy;
}


void foo()
{
    Rectangle rect = Rectangle(600, 400, 1920, 1080);

    translate(rect, -600 + 1920 / 2, -400 + 1080 / 2);
}
~~~~

しかし、この書き方だと`translate`関数が`Rectangle`型に所属していることが少し不透明です。

`Rectangle`型にのみ所属する関数をメンバ関数といいます。
メンバ関数内では、フィールドに対してそのままの名前でアクセス可能です。
また、`this`という暗黙の引数を持っていますので、`this`経由でフィールドに触ることも可能です。

`this`は`ref Rectangle`な引数だと考えることが出来ます。
`this`に対して`const`や`immutable`、さらには`inout`などを付加させたい場合はメンバ関数の属性にそれらを付加させます。

~~~~d
struct Rectangle
{
    float x;
    float y;
    float width = 0;
    float height = 0;


    // void translateInPlace(ref Rectangle, float dx, float dy)
    /**
    (dx, dy)だけ平行移動する。
    */
    void translateInPlace(float dx, float dy)
    {
        x += dx;        // メンバ関数内では、フィールドを触れる
        this.y += dy;   // 暗黙の引数this経由でも触れる

        assert(&width == &(this.width));
        assert(&height == &(this.height));

        pragma(msg, typeof(this));  // Rectangle
    }


    // Rectangle translate(const ref Rectangle, float dx, float dy)
    // もちろんpure, nothrow @safeなどの属性も付加できる。
    Rectangle translate(float dx, float dy) const pure nothrow @safe
    {
        return Rectangle(x + dx, y + dy, width, height);
    }


    /// 面積を返す
    float area() pure nothrow @safe
    {
        return width * height;
    }


    // 引数が0個か1個の場合にのみプロパティとなれる。
    // getterの例
    /**
    Rectangleの中心の座標を、配列float[2]で返します。
    float[0]にはx座標が、float[1]にはy座標が格納されています。
    */
    float[2] center() @property pure nothrow @safe const
    {
        return [x + width/2, y + height/2];
    }


    // setterの例
    /**
    Rectangleの中心座標を設定します。
    */
    void center(float[2] f) pure nothrow @safe @property
    {
        x = f[0] - width/2;
        y = f[1] - height/2;
    }
}


void main()
{
    import std.stdio;
    Rectangle rect = Rectangle(600, 400, 1920, 1080);

    // translateInPlaceメソッドの呼び出し
    rect.translateInPlace(-600 - 1920 / 2, -400 - 1080 / 2);

    const cRect = rect;
    // ↓NG
    // cRect.translateInPlace(-600 + 1920 / 2, -400 + 1080 / 2);
    // ↑のように、constやimmutable, inoutの付いていないメソッドは
    // mutableな型(Rectangle型)からのみしか呼び出せない。
    // なぜなら、const(Rectangle)を引数に取る関数をRectangle型で呼び出すことは出来ないから。

    // プロパティ(getter)の呼び出し方
    assert(rect.center == [0, 0]);

    // プロパティ(setter)の呼び出し方
    rect.center = [600, 400];
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### UFCSとメンバ関数の使い分けと型クラス(余談)

確かに、UFCSを使えばメンバ関数でなくても`rect.translate(dx, dy)`のように呼び出せます。
しかし、たとえばモジュールを跨いだコードでは上手く動きません。

~~~~d
module foo;

auto ref callTranslate(T)(auto ref T t, float dx, float dy)
{
    return t.translate(dx, dy);
}
~~~~~

~~~~d
module rectangle;

import foo;

struct Rectangle
{
    float x;
    float y;
    float width = 0;
    float height = 0;
}

void translate(ref Rectangle rect, float dx, float dy)
{
    rect.x += dx;
    rect.y += dy;
}

void main()
{
    auto rect = Rectangle(0.5, 0.5, 1, 1);

    rect.callTranslate(2.5, 2.5);
}
~~~~~

~~~~~
foo.d(5): Error: no property 'translate' for type 'Rectangle'
rectangle.d(23): Error: template instance foo.callTranslate!(Rectangle) error instantiating
~~~~~

関数型言語での型クラスのようなものや、C++のconceptをD言語で表したい場合にはUFCSが上手く働きます。
その最も身近な例は配列型`T[]`とRangeとの関係です。
動的配列`T[]`には`.front`や`.empty`、`.popFront()`は定義されていませんが、`std.array`をimportすることによってそれらが使えるようになります。
また、Rangeを受け取る関数テンプレートを書く場合には、`std.range`や`std.array`をimportすることが一般的ですから、例に示したモジュールの問題も発生しません。


## アクセス保護属性とフィールドの隠蔽

構造化プログラミングでは、データ構造が変わっても関数のシグネチャが変わっていなければ、プログラム全体は上手く動くとしました。
外部から構造体のデータ構造、つまりはメンバ変数にアクセスできてしまうとマズイわけです。

そこで登場するのが、前章で登場したアクセス保護属性です。
メンバのアクセス保護属性のデフォルト状態は`public`になっていますので、
外部からアクセスされたくないメンバには`private`を付加しておきましょう。

ちなみに、メンバ変数については特別な理由がない限り`private`にしておくとよいでしょう。

~~~~d
struct Rectangle
{
    /// いろいろな実装

  private:
    float _x;
    float _y;
    float _w = 0;
    float _h = 0;


    // 外部からは使えないメソッド
    void foo()
    {
        writeln("foo");
    }
}
~~~~


### データ構造へのアクセスとプロパティ

「メンバ変数については、特別な理由がない限り`private`にしておくとよい」と書きましたが、そうしてしまえば外部からメンバ変数へアクセスする手段がなくなってしまいます。
そこでプロパティ関数の登場です。
プロパティ関数を上手く使うことでデータ構造を隠蔽しつつ、外部に公開もできます。
一見矛盾したようなこの手法ですが、ちゃんとした理由があります。
まず、メンバ関数として外部に公開するので、データ構造に変更を加えても何とかできる可能性が高くなります。
また、メンバ変数へ代入される値を引数として取得できますから、不正な値が設定されないか監視できます。

~~~~d
struct Rectangle
{
  @property
  {
    float x() { return _x; }
    void x(float x){ _x = x; }

    float y() { return _y; }
    void y(float y){ _y = y; }

    float width() { return _w; }
    void width(float w)
    in{
        // 幅は、「大きさ」なので正の値
        assert(w >= 0);
    }
    body{
        _w = w;
    }

    float height() { return _h; }
    void height(float h)
    in{
        // 高さは、「大きさ」なので正の値
        assert(h >= 0);
    }
    body{
        _h = h;
    }
  }


  private:
    float _x;
    float _y;
    float _w = 0;
    float _h = 0;
}


void main()
{
    Rectangle rect;

    // プロパティ関数なので、
    // メンバ変数みたいにアクセス可能
    rect.x = 12;
    assert(rect.x == 12);

    rect.width = 3.14;  // OK
    rect.height = -2;   // Error
    // heightプロパティ関数によって、
    // 負の数を入れられないようにされている。
}
~~~~



## コンストラクタ

外部から触ってほしくないメンバに`private`をつけることで、それを隠蔽できましたね。
次にフィールドの初期化や、構造体の値の作成を考えてみましょう。
[これまでの構造体の使い方](#構造体の基本)だと、構造体内のデータ構造が変わってしまうとコンパイルエラーになってしまいます。
つまり、構造化プログラミングの理念に反してしまいます。

そのために、コンストラクタ(constructor, ctor)という専用の関数が存在します。
コンストラクタはその型の値を作成するための関数で、`this(...){...}`のように宣言します。

~~~~d
struct Rectangle
{
    // コンストラクタの例
    this(float x, float y, float width, float height)
    {
        // メンバ関数のように、メンバにアクセス可能
        _xywh = [x, y, width, height];

        // immutableなメンバ変数でも、コンストラクタでは初期化可能
        _imm = 3;
    }


    // コンストラクタは、複数定義可能
    this(float width, float height)
    {
        // コンストラクタ内では、別のctorを1回だけ呼ぶことが出来る
        this(0, 0, width, height);
    }


  private:
    float[] _xywh;

    immutable int _imm;
}


void main()
{
    auto rect1 = Rectangle(1, 2, 3, 4);
    writeln(rect1);      // Rectangle([1, 2, 3, 4]);

    auto rect2 = Rectangle(3, 4);
    writeln(rect2);      // Rectangle([0, 0, 4, 5]);
}
~~~~


## ビットごとのコピーとPostblit

ブリット(blit)とは、データをそのままコピーすることです。
Dの構造体はただのデータの集合体ですから、デフォルトでは代入などの操作はメモリのコピーとなります。

ある`S`型構造体の変数`v1`を使って、次のように`v2`を定義した場合にもデフォルトではメモリのコピーしか起こりません。

~~~~d
S v2 = v1;
~~~~~

しかし、`S`型構造体にPostblitが定義されていた場合、メモリのコピー後にv2のPostblitが呼ばれます。
Postblitは次のように定義します。

~~~~d
struct S
{
    // postblitコンストラクタの定義
    this(this)
    {
        // ...
    }

    /// fields
}
~~~~~

Postblitが呼ばれるタイミングは、`S`型の値がコピーされた後です。
「値がコピーされた後」という表現はかなり曖昧ですが、つまりは「複製された直後」ということです。
いつコピーされる(値が複製される)かどうかはコンパイラの最適化(NRVO)等に影響されます。

~~~~d
import std.stdio;

struct S
{
    // postblitコンストラクタ
    this(this)
    {
        writeln("call postblit, ", &this);
    }
}

void foo(S){}

void refFoo(ref S){}

void main()
{
    writeln("定義");
    S v1;   // 呼ばれない

    writeln("コピーコンストラクタ");
    S v2 = v1;  // call postblit

    writeln("代入");
    v2 = v1;    // call postblit

    writeln("関数引数として渡す");
    foo(v1);    // call postblit

    writeln("参照引数として渡す");
    refFoo(v1); // 呼ばれない

    writeln("配列化(ctor)");
    S[] ss = [v1];  // call postblit

    writeln("配列化(代入)");
    ss = [v1];      // call postblit
}
~~~~~

Postblitの役目は、コピー後の値を調整することです。
これによって、たとえば参照カウントをインクリメントしたり、参照オブジェクトを値型のように運用することができます。
実際に`std.typecons.RefCounted`ではPostblitによって参照カウントをインクリメントしています。

C++などの他の言語ではコピーコンストラクタというものが存在しますが、Dの場合は同様の処理が単純コピーとPostblitによって実行されます。


## デストラクタ

デストラクタ(destructor, dtor)とは、極端なことをいえばコンストラクタの逆です。
つまり、構造体の値が破棄されるときに呼ばれる特殊なメンバ関数みたいなもの、ということです。
デストラクタの主な役割は、コンストラクタとかPostblitで確保したリソース(メモリとか)の解放です。

~~~~d
void main()
{
    {
        S s1;
    }   // このスコープを抜けると、s1は破棄される
        // 破棄された値に対してdtorが実行される

    // コイツは関数の終了と共に破棄され、dtorが走る
    S s2;
}
~~~~~

Dにはガベージコレクタがありますが、たとえば先ほどの`UniqueArray`のGCを介さないバージョンとして`UniqueArrayNoGC`を考えてみましょう。
GCを使わないので、DのGCヒープからメモリを確保しません。
その代わりにC言語の`malloc`, `free`等を用いてCヒープにメモリを確保し、不要になれば適切に破棄します。
コンストラクタや、Postblitで確保されたメモリは、デストラクタによって破棄されるようにします。

このように、コンストラクタとデストラクタを上手く使ってリソースを管理する手法をRAIIといいます。

~~~~d
import core.stdc.stdlib : malloc, free;     // Cライブラリを使う
import core.exception : OutOfMemoryError;
import std.exception : enforceEx;


/**
要素にint型を持つ配列。
ただしDのガベージコレクタのヒープへは確保せず(@nogc)、
Cヒープ領域のメモリを確保し、管理します。
*/
struct UniqueArrayNoGC
{
    /*
    要素が未初期化であるような配列を返します。
    ただしガベージコレクタではなく、Cヒープへの確保となります。
    */
    private static
    int[] _uninitializedArray(size_t n) nothrow /* @nogc */
    {
        if(n){
            // Cヒープから確保
            auto p = cast(int*)malloc(int.sizeof * n);
            enforceEx!OutOfMemoryError(p !is null);       // エラーを投げる

            return p[0 .. n];
        }else
            return null
    }


    /**
    大きさnのint型を要素として持つ配列を作ります。
    */
    this(size_t n) nothrow @trusted /* @nogc */
    {
        _v = _uninitializedArray(n);

        // 初期化
        foreach(ref e; _v)
            e = 0;
    }


    // 内部に持つ配列を常にユニークに保つ
    this(this) nothrow @trusted /* @nogc */
    {
        auto dst = _uninitializedArray(_v.length);
        dst[] = _v[];   // 要素のcopy
        _v = dst;       // 入れ替え
    }


    // 管理しているCヒープの配列を解放する
    ~this() nothrow @trusted /* @nogc */
    {
        if(_v !is null)
            free(_v.ptr);   // メモリ解放

        _v = null;
    }


    /*
    その他のメンバ関数の実装などなど
    ……………
    ………
    …
    */


  private:
    int[] _v;
}


void main()
{
    auto v1 = UniqueArrayNoGC(16);
    auto v2 = UniqueArrayNoGC(16);
    assert(v1._v !is v2._v);    // ユニーク

    auto v3 = v1;
    assert(v1._v !is v3._v);    // 常にユニーク

    // 代入により、v2の値は破棄される
    v2 = v3;    // (v2 dtor) -> (blit v3 to v2) -> (v2 postblit)


    // v1, v2, v3はスコープの終了、つまりmain関数の終了とともに破棄されるので、
    // そのタイミングでそれぞれdtorが走る
}
~~~~


## 構造体の名前空間と静的メンバ

構造体の内部に定義可能なのは、コンストラクタ, Postblit, デストラクタだけではありません。
モジュールに書けるようなすべての宣言や定義を含めることが出来ます。
つまり、構造体の中に構造体を定義することも可能です。

構造体の内部に定義される関数や変数は、通常はその構造体の値に対して所属しています(つまりメンバ変数, メンバ関数となる)。
しかし、宣言に`static`をつけると、その関数や変数の所属先は「型」になります。
これを静的メンバ変数及び静的メンバ関数と呼びます。

静的メンバ関数内では、通常のメンバ関数で使用できていた`this`が使用できなくなります。
また、静的でないメンバを関数内で操作, 呼び出しできません。

~~~~d
struct S{
    struct SS{
    }

    int a;

    int foo(){
        // 静的メンバにも触れる
        sfoo();     // OK
        return sa;  // OK
    }

  static:
    struct SSS{
    }

    int sa;

    void sfoo(){
        // 静的でないメンバを触れない
        //foo();    // NG
    }
}


void main()
{
    S s;        // OK
    S.SS ss;    // OK
    S.SSS sss;  // OK

    s.a = 11;
    S.sa = 12;
    s.sa = 13;  // OK
    //S.a = 14; // NG
    assert(S.sa == 13); // staticフィールドはS型に対して一つだけ
    assert(&S.sa == &s.sa); // 同上

    s.foo();
    S.sfoo();
    s.sfoo();   // OK
    //S.foo();  // NG
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## alias this

`int`や`byte`などのの整数型には、暗黙の型変換という型変換がありました。
構造体などのユーザー定義型でこの暗黙変換のようなものを実現する機能が`alias this`です。

たとえば、`int`型のように振る舞うものの、非負の整数しか許さない整数型は次のように実装できます。

~~~~d
struct LimitedInt
{
    // getter
    int value() @property
    out(r){
        assert(r >= 0);
    }
    body{
        return _v;
    }


    // setter
    void value(int v) @property
    in{
        assert(v >= 0);
    }
    body{
        _v = v;
    }


    alias value this;

  private:
    int _v;
}


void main()
{
    LimitedInt a;
    a = 12;
    assert(a == 12);
    assert(a != -12);

    a = a + 3;
    a = a - 3;
    a = a - a;
    a = a * a;

    //a -= a; NG,
    //getterのvalueがlvalueじゃないので.

    a = -12;      // 実行時にError
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
core.exception.AssertError@foo(16): Assertion failure
----------------
0x004024DF
0x00402075
0x0040215F
0x004024A8
0x0040247B
0x00402394
0x00402187
0x74A6336A in BaseThreadInitThunk
0x77009F72 in RtlInitializeExceptionChain
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## 問題

* 問題募集中


## 参考文献

1. [意外と知られていない構造化プログラミング、あるいは構造化プログラミングはデータも手続きと一緒に抽象化する、あるいはストロヴストルップのオブジェクト指向プログラミング史観](http://www.tatapa.org/~takuo/structured_programming/structured_programming.html)

2. [猫型プログラミング言語史観(1) 〜あるいはオブジェクト指向における設計指針のひとつ〜](http://nekogata.hatenablog.com/entry/2014/01/17/125600)


## キーワード

* `struct`, 構造体
* ユーザー定義型
* 構造化プログラミング
* メンバ関数
* アクセス保護属性
* コンストラクタ
* Postblit
* デストラクタ
* 静的メンバ
* alias this
