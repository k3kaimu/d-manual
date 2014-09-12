---
layout: post
title:  "09 連想配列"
date:   2013-7-7 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は上記の専用ページでご覧ください。}}

{% tree %}

## 配列(Array)とは？

配列というのは「メモリ上に連続した値のリスト(list)」です。
たとえば`int`型の配列は、`int`型の値がメモリ上に連続しているリストのことを言います。
配列を構成する個々の値のことを要素(element)とよび、各要素にアクセスするにはメモリ上での順番と同じインデックス(添字, Index)という整数値を使い、`arr[idx]`とします。
`arr`は配列型の値で、`idx`はインデックスを表す整数型の値です。
インデックスはメモリ上での順番に沿って`0, 1, 2, 3, ...`と割り振れるため、インデックスが0の要素`arr[0]`を「先頭要素」、インデックスが`idx`な要素`arr[idx]`を「`idx`番目の要素」などと言ったりします。
注意しなければいけないのは、「先頭要素」と「0番目の要素」は同じ意味です。

また、配列は有限の長さ(大きさ)分だけ要素を持ちます。
配列`arr`の長さは、`arr.length`で取得可能です。
`arr.length`が`2`であれば、配列`arr`が持つ要素の数は2個で、インデックスは`0, 1`の2つが有効です。
一般に、有効なインデックスは`0`から`arr.length - 1`であり、それ以外のインデックス、たとえば`-1`とか`arr.length`でアクセスしようとするとエラーが出ます。

`arr[idx]`は左辺値なので、`arr[idx] = value;`のように代入も可能です。
最終要素の左辺値を取得するには`arr[arr.length - 1]`とします。
`[]`の中では`arr.length => $`と書き換えれるので、`arr[$-1]`も最終要素の左辺値となります。

今までよく出てきた`string`も実際には「『書き換え不可能な文字』の配列」でした。
先頭文字は`str[0]`で取得できますし、`str[$-1]`とすれば最後の文字が得られます。

配列を使う理由は、"大量"の変数を"まとめて"扱いたいからです。
たとえば、文字列`"abcd"`の各文字にそれぞれ`char`型の変数を`char str0 = 'a', str1 = 'b', str2 = 'c', str3 = 'd';`のように割り当てていては使い勝手が悪すぎます。


## スタックとヒープ

スタック(Stack)領域は、静的にその大きさが決められ、関数の開始時に有効となり、関数の終了とともに消滅するメモリ領域のことです。
関数内で宣言した変数はすべてスタックに置かれます。
(もちろん、ポインタやスライス、クラスといった参照型は、参照先がスタック上にないかもしれないだけで、変数自体はスタック上にあります。)

これに対となるのがヒープ(Heap)領域で、動的に確保可能、つまり実行時に欲しいだけの領域を確保可能です。
また、関数が終了しても存在し続けるメモリ領域で、`new`演算子や`core.memory.GC.malloc`などを用いて確保します。
動的に確保するため、実行時に多少の時間的コストもかかります。

通常、スタック領域は1MB程度と小さいので、大量のメモリが必要であればヒープ領域を確保します。


## 静的配列(Static Array)

静的配列は、スタック上に確保される配列で、C言語の配列(mallocで確保する領域ではない)に似ています。
`T`型の要素を`N`個もつ静的配列は`T[N]`という型になります。
静的配列は、それ全体が値的な性質を持っています。
たとえば次のコードでは、静的配列全体をコピーする操作になります。

~~~~d
int[16] a, b;

// a, bに対するいくつかの操作

a = b;              // 要素すべてのコピー
~~~~

静的配列の長さはコンパイル時に固定され、実行時に変更することはできません。
また、長さの違う静的配列のコピーはコンパイル時にエラーになります。

~~~~d
int[16] a;
int[17] b;

a.length = 1024;    // Error: constant a.length is not an lvalue
a = b;              // Error: mismatched array lengths, 16 and 17

a = b[0 .. 16];     // 後ほど説明するスライスに変換してしまえばコピー可能
~~~~

スタック領域は容量に制限がある(例. 1MB)ので、大きな静的配列を確保するのはオススメしません。
また、静的配列への代入は全要素のコピーなので、大きな配列であればコピーに時間がかかってしまいます。

~~~~d
int[1024 * 1024 * 4] a;     // Error: index 4194304 overflow for static array
~~~~

このような場合には、静的配列は諦めて後述する`new int[1024 * 1024 * 4]`によってヒープ上に領域を確保するしかありません。


## 配列とポインタのお話

配列というのは、メモリ上に連続する値のリストのことでした。
配列を最もシンプルに表すためには、「メモリ上での位置」と「配列の大きさ」が必要です。
つまり、「配列の先頭要素`arr[0]`を指すメモリアドレス値」と「配列の大きさ」があれば十分にその配列を表現可能です。
メモリアドレス値はポインタ値(Pointer)と呼ばれ、今までに数回出て来ましたね。

~~~~d
T* ptr;         // 先頭要素を指すポインタ
size_t length;  // 配列の長さ
~~~~

D言語の親であるC言語では、スタック上に確保される静的配列や可変長配列(VLA, Variable Length Array)は、ポインタ的な振る舞いもしますし、`sizeof`演算子で配列の要素数も取得可能です。
また、大きな配列を確保したければ、`malloc`や`calloc`を使ってヒープ上に確保し、以降はポインタ値と長さを表す変数をペアで運用するのが普通です。

D言語は、C言語のこのような流れを継承しているので、ポインタでも配列のようなことができますが、より良く配列を表現するためスライス(Slice)というものを導入しました。
D言語のスライスは、ポインタ値と大きさのペアでしかなく、よく勘違いされるのですが、他の言語の動的配列(たとえばC++の`vector`やJavaの`ArrayList`)とは全く異なったコンセプトです。


## スライス

普通、D言語で「動的配列」と呼ばれたらスライスのことを指します。
実際に、仕様上はスライスは「動的配列型(Dynamic Array)」となっていますが、スライスと呼ばれることが多いので本稿ではスライスとします。

スライスは、スライスの先頭要素へのポインタ値とスライスの長さしか持ちません。
ですから、スライスはポインタからも生成可能ですし、静的配列からも作れます。
スライスの型は`T[]`となります。
スライスの大きさは、`slice.length`で取得可能で、`slice[idx]`でスライスの要素の左辺値を取得可能です。

~~~~d
int* p;
size_t size;

// 適当なpとsizeに関する操作, pは配列の先頭要素へのポインタ, sizeは配列の長さ

int[] slice1 = p[0 .. size];    // ポインタとサイズからスライスの生成

int[25] arr;
int[] slice2 = arr[];           // 静的配列からスライスの生成

int[] slice3;                   // デフォルト初期化
slice3 ~= slice1;               // デフォルト初期化値でも追加や連結、拡大可能
~~~~


### ヒープ上のメモリの確保

では、ヒープ上に新しい領域を確保するにはどのようにするのでしょうか？
C言語のように`malloc`や`calloc`を使うのは安全ではありません。
D言語にはD言語なりの確保方法があります。
`new T[n]`とすれば、ヒープ上に新しく最低`n`個の`T`型の領域が割り当てられ、その領域を示すスライス`T[]`がその値となります。

~~~~d
int[] arr = new int[10000];   // ヒープ上に1万要素を確保し、スライスとして取得
~~~~


### 要素の追加とスライス同士の結合、大きさの拡大縮小

スライスは動的配列ではありませんが、動的配列のように要素の追加、結合、大きさの拡大縮小も可能です。
D言語のランタイムが賢く動くので、プログラマは少しだけ注意すればほとんど考える必要はありません。

~~~~d
int[] arr = foo();  // なにか適当なスライス

arr ~= 1;           // 要素の追加
arr ~= foo();       // スライスの結合

arr = arr ~ arr;    // 2項演算子としての結合

arr.length = 100;   // 大きさの変更
~~~~

スライスの大きさが大きくなった場合、その前後でスライスの持つポインタ値が一致しない場合があります。
このとき、「スライスを大きくする」操作は実際には「新しいヒープ領域を確保し、メモリの内容をコピーし、その領域を示すスライスにする」という操作になります。
スライスの領域に連続して未使用の予約された領域が存在するならば、ポインタの値は変えずにスライスの大きさを大きくして、その予約された領域へ追加の値をコピーします。
逆を言えば、静的配列やポインタなどから作成されたスライスへの追加や拡大は、絶対に予約領域がありませんから、必ず新しい領域の確保とその領域への全体のコピーが行われます。
スライスで一番難しいのはこの仕様で、新しい領域の確保のタイミングは把握しにくくなります。


### ガベージコレクタ

スライスはスタックやヒープにかかわらず、動的配列のようなインターフェースを提供することがわかりました。
では、`new`でヒープ領域を確保したり、追加や連結、拡大によって確保されたヒープ領域のメモリはどのように開放されるのでしょうか？
D言語はガベージコレクタを言語仕様として持つので、これらの開放はガベージコレクタによってなされます。
ですから、プログラマはほとんど何も考えずに、様々なメモリ領域をスライスにでき、さも動的配列のように動作させることができるのです。


### スライス演算子

ポインタ, 静的配列, スライスから、その領域のスライスを得る方法としてスライス演算子があります。
スライス演算子は`p[idxBegin .. idxEnd]`と書きます。
`idxBegin`は新しいスライスの開始インデックス、`idxEnd`は、最終要素のインデックス+1です。
もし、`p`がスライスもしくは静的配列であれば、`idxBegin`, `idxEnd`の両方は`p`の長さを表す`$`を含んだ式にできます。
もし、スライスや静的配列に対して、その領域への新たなスライスが欲しいなら`p[0 .. $]`と書く代わりに`p[]`とも書けます。

~~~~d
int* p = foo();

int[] slice1 = p[0 .. 100];             // ポインタから100個の領域のスライス

int[] slice2 = slice1[10 .. $];         // slice1の10番目から最終要素までのスライス

int[40] staticArray;

int[] slice3 = staticArray[0 .. $-10];  // 静的配列staticArrayの前から30個のスライス

int[] emptySlice1 = slice3[$ .. $],     // 長さ0のスライス
      emptySlice2 = slice3[0 .. 0];     // 長さ0のスライス

slice3 = staticArray[];                 // staticArray[0 .. $]と同じ
~~~~


### スライスを使ったベクトル演算

スライスの各要素をコピーしたり、各要素間でベクトル加算などをするときに便利です。
また、SIMD化も狙えるかもしれませんし、foreachやforでループを回すよりも高速になるでしょう。

~~~~d
int[] arr1 = new int[1024],
      arr2 = new int[1024];

arr1[] = 10;                    // 全要素に10を代入
arr2[] -= 100;                  // 全要素から100を引く
arr1[] *= arr2[];               // 2つのスライスの全要素それぞれを掛け合わせ、arr1に格納。

arr2[0 .. 8] *= arr1[8 .. 16];  // 8要素だけの掛け算

arr2[8 .. $] = arr1[8 .. $];    // メモリのコピー
~~~~


### スライスの独立性

たとえば次のコードを考えてみましょう。

~~~~d
int[] arr = [0, 1, 2, 3, 4, 5];
int[] slice1 = arr;

assert(arr == slice1);

arr[0] = -1;                            // arrの先頭を-1に書き換え
assert(slice1[0] == -1);                // slice1はarrの領域を参照しているだけにすぎない

arr = arr[0 .. 2];
assert(arr.lengt == 2);                 // arrの大きさは2となる
assert(slice1.length == 6);             // たとえarrの大きさが変わってもslice1の大きさに変わりはない

arr[0] = -2;                            // arrの先頭要素を書き換えれば
assert(slice1[0] == -2);                // slice1も同一領域を参照しているので書き換わる

arr.length = 10;                        // arrの大きさを大きくしてみる
assert(slice1.length == 6);             // もちろん、slice1の大きさは変わらない

arr[0] = -3;                            // しかし、arrの先頭要素を書き換えても
assert(slice1[0] == -2);                // slice1の先頭要素に影響はない。
                                        // arr.length = 10;で新しい領域にarrの内容がコピーされ、arrはそれを指している。
~~~~

スライス`T[]`は、ポインタ`T*`とサイズ`size_t`のペアであると考えられます。
また、スライスの縮小だけでは新しい領域が確保されることはありません。
結合や拡大を行なってしまえば、新たに確保される可能性があり、新しい領域が確保された場合には、もちろん他のスライスへの影響は無くなります。


## スライスや配列の等価テスト(同値テスト)

静的配列やスライスを`==`演算子や`!=`演算子で比較すると、全要素が等しいかそうでないかを判定します。
つまり、スライスであれば参照先のポインタには関係ありません。
もし、スライスが同じ領域を指しているかどうかを確認したい場合には`is`演算子を使います。

~~~~d
int[3] stArr1 = [0, 1, 2],
       stArr2 = [1, 1, 1],
       stArr3 = [0, 1, 2];

writeln(stArr1 != stArr2);      // true     要素が違う
writeln(stArr1 == stArr3);      // true     要素は全部同じ

int[] slice1 = [0, 1, 2],
      slice2 = [1, 1, 1],
      slice3 = [0, 1, 2];

writeln(slice1 != slice2);      // true     要素が違う
writeln(slice1 == slice3);      // true     要素は全部同じ

writeln(slice1 !is slice3);     // true     参照している領域が違う

int[] slice4 = slice1;
writeln(slice4 is slice1);      // true     slice4はslice1と同じ領域を指している

slice4 = slice4[1 .. $];
writeln(slice4 !is slice1);     // true     指している先(ptr)は同じだが、長さが違う

writeln(stArr1 == slice1);      // true     もちろん、静的配列とスライスの比較も可能
~~~~


## スライスや配列の大小比較

Dでは、配列の大小関係も比較できます。
配列の大小は、「辞書」に並ぶように決められています。

たとえば、「あああ」と「ああい」では、「あああ」のほうが(もし辞書に並ぶなら)前にあるでしょう。
よって、「あああ」のほうが「ああい」より小さいとされます。
「ああい」と「ああ」では、両方の先頭2文字は「ああ」ですが「ああ」の方が文字数が少ないので、「ああ」のほうが辞書の前にきます。
ですから、「ああ」のほうが「ああい」より小さいとされるのです。

このようにD言語の配列は、辞書で前に載るものほど小さく、後ろに載るものほど大きくなります。

~~~~d
int[3] stArr1 = [0, 1, 2],
       stArr2 = [0, 2, 1];
int[2] stArr3 = [0, 1];

writeln(stArr1 < stArr2);       // true
writeln(stArr1 > stArr3);       // true

int[] slice1 = [0, 1, 2],
      slice2 = [0, 2, 1],
      slice3 = [0, 1];

writeln(slice1 < slice2);       // true
writeln(slice1 > slice3);       // true

writeln(stArr1 < slice2);       // もちろん、静的配列とスライスの比較も可能
~~~~

文字列の比較を行う際にも`int[]`と同じように、辞書的に大小を比較します。

~~~~d
string str1 = "Google",
       str2 = "Goggles";

writeln(str1 > str2);           // true
~~~~


## foreachと配列

`foreach range`文というのは、すでに説明したとおり、ある範囲をループするのに使います。
今回説明するのは`foreach`文で、D言語の仕様的には`foreach range`文とは異なった文です。

`foreach`文では、`foreach(<elemement>; <array>)`や`foreach(<index>, <element>; <array>)`と書くことができます。
`foreach`文は、インデックスが`0`の要素(先頭要素)から順番に処理されますが、`foreach_reverse`とした場合にはインデックスが最大の要素(最終要素)から順番に処理されていきます。
例を示しますと、以下のように使えます。

~~~~d
/// test00801.d
import std.stdio, std.string, std.array, std.typecons;

void main()
{
    // `e`はスライスの要素の値で、`foreach_reverse`なので最終要素からイテレートする
    foreach_reverse(e; [0, 1, 2, 3])
        writeln(e);


    int[5] arr = 10;

    // `i`はインデックス、`e`は要素の値。もちろん、`i`は`0`から`arr.length-1`まで。
    // `ref e`となっているので、`e`を通して`arr`の内容を書き換え可能。
    // 逆を言えば、`ref`がついていなければ、foreach文内で`e`を通して`arr`の書き換えは不可能。
    // また、`arr`自体をforeach文の中で書き換えるのは不正
    foreach(i, ref e; arr){
        writefln("arr[%s] : %s", i, e);
        e = i;
    }

    writeln(arr);       // [0, 1, 2, 3, 4]


    int[] arr2 = new int[32];
    arr2[] = 10;

    // `i`にも`ref`が付いているので、イテレートするインデックスを操作可能。
    // この例の場合は、`i`は`0, 4, 8, 12, 16, 20, 24, 28`となる。
    foreach(ref i, ref e; arr2){
        writeln(i);

        e = i;
        i += 3;
    }

    writeln(arr2);      // [0, 10, 10, 10, 4, 10, 10, 10,
                        //  8, 10, 10, 10, 12, 10, 10, 10,
                        // 16, 10, 10, 10, 20, 10, 10, 10,
                        // 24, 10, 10, 10, 28, 10, 10, 10]
}
~~~~

~~~~
$ rdmd test00801.d
3
2
1
0
arr[0] : 10
arr[1] : 10
arr[2] : 10
arr[3] : 10
arr[4] : 10
[0, 1, 2, 3, 4]
0
4
8
12
16
20
24
28
[0, 10, 10, 10, 4, 10, 10, 10, 8, 10, 10, 10, 12, 10, 10, 10, 16, 10, 10, 10, 20, 10, 10, 10, 24, 10, 10, 10, 28, 10, 10, 10]
~~~~


注意しなければならないのは、`foreach`文中で、イテレート対象のスライスなどに対して要素の追加や削除を行なってはいけません。
つまり、次のコードはコンパイルは通りますが、書いてはいけないコードです。

~~~~d
int[] arr = new int[10];

foreach(e; arr)
    arr ~= 1;
~~~~


また、D言語の本家サイト`dlang.org`や邦訳版TDPLを読む限りでは、indexに`ref`をつけることは出来ないとなっています。
すなわち、これらに従うのであれば以下のコードはコンパイルできませんが、dmd 2.063から入った変更によって、`ref`指定できるようになっています。

~~~~d
int[] arr = new int[10];

foreach(ref i, e; arr)
    writef("%d ", ++i);       // 1 3 5 7 9

writeln();
~~~~


## Rangeとスライス

D言語には、レンジ(Range)という概念があります。
これは、`std.range`で定義されています。
Rangeは、リストや配列などのようなデータの構造を一般化したものと言えます。

たとえば、スライスは`std.array`を`import`すれば、`arr.front`, `arr.back`, `arr.popFront()`, `arr.popBack()`, `arr.empty`, `arr.save`が使用でき、
インデックスで各要素へアクセス可能で、長さ(`.length`)を持っているので、`Random access range`という分類になります。

~~~~d
import std.array, std.stdio;

void main()
{
    int[] arr = [0, 1, 2, 3];

    writeln(arr.empty);     // false    arrは空でない
    writeln(arr.front);     // 0        arrの先頭要素は0
    writeln(arr.back);      // 3        arrの最終要素は3

    int[] arr2 = arr.save;  // arrをpopFront(), popBack()しても、arr2に影響はない
                            // スライスでは、ただ単なる代入(arr2 = arr)と等価

    arr.popFront();         // arrを一つ進める -> arr = arr[1 .. $];と等価
    writeln(arr);           // [1, 2, 3]
    writeln(arr.empty);     // false
    writeln(arr.front);     // 1
    writeln(arr.back);      // 3

    arr.popBack();          // arrの後ろを一つ縮める -> arr = arr[0 .. $-1]に等価
    writeln(arr);           // [1, 2]
    writeln(arr.empty);     // false
    writeln(arr.front);     // 1
    writeln(arr.back);      // 2

    arr.popFront();
    arr.popFront();
    writeln(arr);           // []
    writeln(arr.empty);     // true     arrは空
}
~~~~


今回はレンジについては詳しく説明しませんが、スライスはRangeという概念に沿っているので、`std.range`や`std.algorithm`などの便利な関数が使えます。
以下は`std.algorithm.filter`を使ってスライス中の偶数要素のみを抽出し、それらを`n`倍したレンジを返す関数です。

~~~~d
import std.algorithm, std.range;


auto evenPassFilter(T, U)(T[] array, U n)
{
    return array.filter!"a%2 == 0"()
          .zip(repeat(n))
          .map!"a[0] * a[1]"();
}


void main()
{
    writeln([0, 1, 2, 3].evenPassFilter(2.5));     // [0, 5]
}
~~~~


## 静的配列やスライスのプロパティとメソッド

プロパティとは何か、メソッドとは何かというお話はここでは気にせず、Dの配列を高効率とするための機能を紹介します。
ちなみに、`array.`と付いているものは静的配列とスライスの両方で使え、`slice.`で始まっているものはスライスでしか使えません。


* `T* array.ptr`

配列の先頭要素へのポインタ値を返します。

~~~~d
import core.memory;

int* p = cast(int*)GC.malloc(int.sizeof * 10);  // ヒープからint型10要素分のメモリを確保
int[] slice = p[0 .. 10];                       // ポインタpからスライスを作成

writeln(slice.ptr == p);                        // true
                                                // スライスのポインタは、pと同じなので

slice = slice[1 .. $];
writeln(slice.ptr == p + 1);                    // true

int[10] stArray;
slice = stArray[];                              // 静的配列 -> スライスへの変換
writeln(stArray.ptr == slice.ptr);              // true
                                                // 静的配列をスライスへ変換することは、
                                                // そのスタック領域へのスライスであるということの証明
~~~~


* `size_t array.length`

配列が格納している要素数を返します。

~~~~d
int[] slice = new int[10];
writeln(slice.length);                  // 10

slice = slice[0 .. 0];
writeln(slice.length);                  // 0

int[10] stArray;
writeln(stArray.length);                // 10

pragma(msg, stArray.length);            // 10u (コンパイル時間に出力)
                                        // 静的配列であればコンパイル時定数
~~~~


* `T[] array.dup`

新しいヒープ領域を確保し、配列のコピーを作ります。結果はスライスです。

~~~~d
int[] slice = new int[10],
      slice2 = slice.dup;

writeln(slice == slice2);
writeln(slice.ptr != slice2.ptr);

int[10] stArray;
pragma(msg, typeof(stArray.dup));   // int[]  (コンパイル時に出力)
~~~~


* `immutable(T)[] array.idup`

新しいヒープ領域を確保し、配列のコピーを作ります。結果の型は要素が`immutable`なスライスです。
`immutable`とは、「生まれたら最後、一生書き換えられない」という意味です。

~~~~d
int[] slice = new int[10];
immutable(int)[] slice2 = slice.idup;

writeln(slice == slice2);
writeln(slice.ptr != slice2.ptr);

int[10] stArray;
pragma(msg, typeof(stArray.idup));   // immutable(int)[]  (コンパイル時に出力)
~~~~

ちなみに、dmd 2.063から入った変更によって、`dup`でも`idup`の機能は満たせます。

~~~~d
int[] slice = new int[10];
immutable(int)[] slice2 = slice.dup;    // OK
~~~~


* `T[] array.sort`

配列の要素をインプレース(その場)で昇順(小さい順)に並び替えます。
静的配列であっても、結果の型はスライスです。

~~~~d
int[] arr = [3, 1, 2];

writeln(arr.sort);       // [1, 2, 3]
~~~~

`sort`プロパティは[廃止予定](#仕様)なので、`std.algorithm.sort`を使うのがよいでしょう。

~~~~d
import std.algorithm;

int[] arr = [3, 1, 2];

writeln(sort(arr));     // [1, 2, 3]
writeln(arr);           // [1, 2, 3]

arr.sort!"a > b"();     // [3, 2, 1]
                        // 降順並び替え
writeln(arr);
~~~~


* `T[] array.reverse`

配列の要素をインプレースで反転させます。
静的配列であっても、結果の型はスライスです。

~~~~d
int[] arr = [1, 2, 3];

writeln(arr.reverse);       // [3, 2, 1]
writeln(arr.reverse);       // [1, 2, 3]
~~~~

`sort`プロパティと同様に`reverse`プロパティも[廃止予定](#仕様)なので、`std.algorithm.reverse`を使うのがよいでしょう。

~~~~d
import std.algorithm;

int[] arr = [1, 2, 3];

reverse(arr);               // こうするか
writeln(arr);

arr.reverse();              // こうする
writeln(arr);
~~~~


* `slice.capacity`

スライスへの追加を行う際に、再割当てされるかどうかを予測したい場合に活用します。
`slice.capacity`は、そのスライスが、メモリを再確保しないで、最大で何要素まで要素を持つことができるか返します。

~~~~d
int[] arr;
writeln(arr.capacity);      // 0

arr = new int[10];
int* before = arr.ptr;

foreach(i; 0 .. arr.capacity - arr.length)
    arr ~= i;               // メモリの再確保は起こらない

assert(before == arr.ptr);  // 追加前と追加後ではポインタは変わっていない
                            // つまり、最確保されていない
~~~~


* `size_t slice.reserve(size_t n)`

そのスライスが、メモリを再確保しないで、最低`n`の長さまで拡大、追加できるように、必要であれば再確保します。
返り値は、変更後の`slice.capacity`です。

~~~~d
int[] arr = new int[5];
size_t cap = arr.reserve(arr.length + 5);   // あと最低でも5要素は追加可能にしておく
assert(cap - arr.length >= 5);              //追加可能な要素は5以上
~~~~


* `void slice.assumeSafeAppend()`

そのスライスが参照しているメモリの末端までそのスライスが拡張可能であるとランタイムに強制します。
気をつけて行わないと、想定外の動作を起こす可能性があります。

~~~~d
int[] arr = new int[10],
      arr2 = arr;
arr[] = 1;
writeln(arr2);                  // [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

size_t cap = arr.capacity;

arr = arr[0 .. 5];
assert(arr.capacity == 0);      // arrを拡大することは、arr2を破壊することにつながる
                                // よって、capacityは0

arr.assumeSafeAppend();
assert(arr.capacity == cap);    // 縮小前のcapacityと同じ

arr.length = 6;
writeln(arr);                   // [1, 1, 1, 1, 1, 0]
                                // 新しい領域はT.initで初期化
writeln(arr2);                  // [1, 1, 1, 1, 1, 0, 1, 1, 1, 1]
                                // arrやarr2に代入していないのに、arr2[5]が0に書き換わっている
                                // プログラマが意図していないメモリの書き換えになっている
                                // つまり、assumeSafeAppendはちゃんと管理しなければ安全でない
~~~~


## 多次元配列(配列の配列)

配列の配列を作成することも可能です。たとえば、`int[3][]`は、`int[3]`という静的配列のスライスです。`int[][][]`であれば、intのスライスのスライスのスライスです。

~~~~d
int[3][] arr2d = new int[3][](10);
writeln(arr2d.length);          // 10
writeln(arr2d[0].length);       // 3

arr2d[0][0] = 1;
writeln(arr2d[0]);              // [1, 0, 0]

int[][][] arr3d = new int[][][](1, 2, 3);

writeln(arr3d.length);          // 1
writeln(arr3d[0].length);       // 2
writeln(arr3d[0][0].length);    // 3
~~~~


## 配列操作のまとめ

よく使用する配列操作を纏めておきます。
実際には、配列とレンジの両方を活用することで効率的なプログラムが書けます。

~~~~d
import std.algorithm;
import std.array;

void main()
{
    {
        int[] arr = new int[1024];      // 宣言と初期化と確保
    }
    {
        int[] arr;                      // 宣言とデフォルト初期化
        arr.length = 1024;              // 拡張
    }
    
    int[] arr;
    arr = new int[1024];

    size_t n = arr.length;              // 配列の大きさの取得

    n = 5;

    auto e = arr[n];                    // インデックスによるアクセス
    arr[n] = e + 5;

    int* p = &arr[n];                   // n番目の要素へのポインタ
    p = arr.ptr;                        // 先頭要素へのポインタ

    auto arr2 = arr[n .. n + 8];        // 配列のn要素目から8個だけの配列を取得

    arr ~= e;                           // 末尾に単一要素を追加
    arr ~= arr2;                        // 末尾に他の配列を追加

    arr.popBack();                      // 末尾の単一要素削除
    arr = arr[0 .. $ - n];              // 末尾のn個の要素削除

    arr.insertInPlace(0, e);            // 先頭に単一要素の追加
    arr = [e] ~ arr;                    // 同上
    arr.insertInPlace(0, arr2);         // 先頭に他の配列を追加
    arr = arr2 ~ arr;                   // 同上

    arr.popFront();                     // 先頭の単一要素削除
    arr = arr[n .. $];                  // 先頭のn個の要素削除

    arr.insertInPlace(n, e);            // n番目に単一要素を追加
    arr.insertInPlace(n, arr2);         // n番目に配列を追加

    arr = arr.remove(n);                // n番目の単一要素を削除

    import std.typecons;
    arr = arr.remove(tuple(n, n + 5));  // n～n+4番目までの要素を削除

    arr.sort();                         // 昇順ソート(std.algorithm.sort)
    arr.sort!"a > b"();                 // 降順ソート(std.algorithm.sort)

    arr.sort;                           // 昇順ソート(プロパティ)

    arr.reverse();                      // 配列の反転(std.algorithm.reverse)
    arr.reverse;                        // 配列の反転(プロパティ)
}
~~~~~


## 問題 -> [解答](answer.md#array)

* 問1  
`int`型の配列`arr`を適当に6要素初期化し、その内容を1要素ずつ改行して表示するプログラムを作ってください。  
たとえば、`[0, 2, 4, 1, 3, 5]`と初期化されているなら以下のように表示すること。

~~~~
0
2
4
1
3
5
~~~~

* 問2  
問2のプログラムとは逆順で表示させるようにしてください。`foreach`文を使ったなら`for`文でやってみましょう。

* 問3  
`writefln`や`writef`のフォーマット指定は、詳細に指定可能です。たとえば、問2のプログラムであれば以下のように書けます。

~~~~d
import std.stdio;

void main()
{
    int[] arr = [0, 2, 4, 1, 3, 5];

    writefln("%(%s\n%)", arr);
}
~~~~

`%(`から`%)`までをサブフォーマット(Sub-format)といい、配列の1要素のフォーマット指定になります。
ただし、最終要素のみは`%s`などの書式指定子もしくは`%|`のデリミタ(区切り文字, Delimiter)の出現位置までしか表示しません。
デリミタの方が優先度が高く、たとえ前方に`%s`などの書式指定子あっても`%|`までを区切りとします。
また、`%|`以降に`%s`などの書式指定子やデリミタ`%|`を置くことはできません。
(`%(%|%d%)`や`%(%s%|%|%)`は不正なフォーマット)

では、各要素を`[001]`のように`[]`でくくって3桁ずつ表示するにはどうすればいいでしょうか？
ヒントとして、`%(-%s-%|\n%)`というようにデリミタ`%|`を使うことで、以下の様な出力が得られます。

~~~~
-0-
-2-
-4-
-1-
-3-
-5-
~~~~


* 問4  
`new int[10];`とすることで、10要素の配列を確保し、各要素にインデックス値`idx`の10倍の値`idx * 10`を格納し、表示するプログラムを書いてください。
出力のフォーマットはどのような形式でも構いません。


* 問題募集中


## 終わりに

配列の中でもスライスは、D言語の特徴的な機能の一つです。
スライスを使えば、本当に思った通りにプログラムが動くので、バグを起こしにくくなります。
C++での`vector`と比較すれば、使い勝手ではDのスライスが圧勝するでしょうね。
(というより、機能や概念が違うから比較すべきではないかも)
私はC言語にも、ガベージコレクタはなくても、スライスだけでも導入して欲しいと思ってます。
もちろん、ガベージコレクタがなくなっているので結合や追加はできませんが、Cでも十分綺麗なコードが書けるはずです。

次は文字の配列である「文字列」について解説します。
D言語の文字列は、他言語とくらべて圧倒的に操作しやすくなっています。


## キーワード

* 配列(Array)
* リスト(List)
* 要素(Element)
* 長さ(`arr.length`, `&`)
* 添字(Index)
* スタック(Stack)
* ヒープ(Heap)
* 静的配列(`T[N]`)
* スライス(`T[]`, 動的配列, Slice, Dynamic Array)
* ポインタ(`T*`, Pointer)
* `new`
* 結合(`~=`, `~`)
* ガベージコレクタ(Garbage Collector, GC)
* スライス演算子(`arr[]`, `arr[]`)
* `foreach`文
* Range
* 多重配列


## 仕様

* 静的配列              [日本語](http://www.kmonos.net/alang/d/arrays.html#static-arrays) [英語](http://dlang.org/arrays.html#static-arrays)
* 動的配列(スライスのこと)     [日本語](http://www.kmonos.net/alang/d/arrays.html#dynamic-arrays) [英語](http://dlang.org/arrays.html#dynamic-arrays)
* `foreach`文            [日本語](http://www.kmonos.net/alang/d/statement.html#ForeachStatement) [英語](http://dlang.org/statement.html#ForeachStatement)
* `sort` と `reverse` の廃止について [英語](http://dlang.org/deprecate.html#.sort and .reverse properties for arrays)
