---
layout: post
title:  "13 ファイルと標準入出力"
date:   2013-11-16 00:00:00
categories: dmanual
tags: dmanual
---

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は専用ページでご覧ください。}}

{% tree %}

## ファイル出力

ファイルに出力するには大きく分けて二通りの方法がよく使われます。

1. `std.stdio.File`を使う
2. `std.file.write`や`std.file.append`を使う

<!---->

1.の方法は、C言語での`stdio.h`の`FILE*`を使うような方法です。
2.はデータを一度に書き出すのに便利です。

<!---->

### `std.stdio.File`を使う

C言語の入門書ではファイル操作に`FILE*`を使用しますが、D言語でも普通は`std.stdio.File`構造体を使用します。
使用方法は簡単で、今まで使用してきた`std.stdio.write`などと同様のものをメンバとして持ちます。

~~~~d
import std.stdio;

void main()
{
    auto f1 = File("foo.txt", "w");     // 書き込みモードで開く
    f1.writeln("くぁｗせｄｒｆｔｇｙふじこｌｐ；");

    {
        auto f2 = f1;                   // sameFileはf1と同じファイルを指す
        f2.write("ふぉおばｒほげ");
    }

    f1 = File("hoge.txt", "w");         // 違うファイルを開く
                                        // foo.txtは自動的にで閉じられる。

    // Fileは、同じファイルを参照しているすべてのFile構造体がなくなれば、自動的に閉じられる。
    // 明示的にファイルを閉じたいのであれば、File.detach()を使う
    f1.detach();                        // file.close()が呼ばれる
}
~~~~

配列のデータをバイナリでそのままファイルに書き出したい場合には、`std.stdio.File.rawWrite`を使用します。

~~~~d
import std.stdio;

void main()
{
    auto f = File("foo.txt", "w");
    int[] data = [1, 2, 3, 4, 5];

    f.rawWrite(data);
}
~~~~

リトルエンディアンの環境では、ファイルには次のようなデータが出力されます。
もちろん、16進数表示しているだけで、実際にはビットの列でしかありません。

~~~~
01 00 00 00 02 00 00 00 03 00 00 00 04 00 00 00 05 00 00 00 
~~~~



### `std.file.write`や`std.file.append`を使う

`std.file.write`や`std.file.append`は、配列をバイナリとしてそのまま出力するのに使用します。
つまり、`std.file.File.rawWrite`のように使用します。
この2つを使えば、いちいち`std.stdio.File`を作らなくてもファイルに出力できます。

~~~~d
import std.file;

void main()
{
    int[] data = [0, 1, 2, 3, 4];

    std.file.write("foo.dat", data);        // foo.datが無ければ新しくファイルが作られる
    std.file.append("bar.dat", data);       // bar.datがない場合は、write同様に新しく作られる

    std.file.write("foo.dat", "ふー");        // foo.datを文字列で上書きする
    std.file.append("bar.dat", "ばー");       // bar.datに文字列を追加
}
~~~~


## 標準出力`stdout`

標準出力とは、通常はコンソールなどの画面への出力のことです。
しかし、リダイレクトという機能によって、ファイルなどに出力することも可能になります。

標準出力に出力するためには、`std.stdio.write`などの関数を使いましょう。
また、`std.stdio`には`stdout`という`File`型のグローバル変数が定義されているので、`stdout`に対して操作しても標準出力に表示されます。

~~~~d
import std.stdio;

void main()
{
    writeln("Hello, World!");   // 標準出力(コンソール)に出力される

    stdout.rawWrite("foo bar\n"); // 同上
}
~~~~


## ファイル入力

出力と違って、入力は様々なバリエーションがあります。
たとえば、「1行だけほしい」とか「`foreach`で回したい」とかです。
ファイル入力の手段としては、次の2つが適切でしょう。

1. `std.stdio.File`を使う
2. `std.file.read`や`std.file.readText`を使う

<!---->

### `std.stdio.File`を使う

* 1行取得

`File`から1行取得するには、`File.readln`を使用します。

~~~~d
import std.stdio;

void main()
{
    auto file = File("foo.txt");

    string str = file.readln();
    writeln(str);
}
~~~~


* `File.readf`

ファイル中に書いてある数値などを読み込みたい場合には、`readf`が便利です。
次のように使います。

~~~~d
import std.ascii,
       std.stdio;

void main()
{
    {
        auto file = File("foo.txt", "w");
        file.writeln("123x345");           // foo.txtに"123x345\n"を書き込む
        file.writeln("foo-bar");
    }

    auto file = File("foo.txt");
    int a = void, b = void;
    
    // foo.txtから、"%sx%s"というフォーマットで2つの整数を読み込む
    // `&a`というように、ポインタを渡す
    file.readf("%sx%s", &a, &b);

    writefln("%s : %s", a, b);          // 123 : 345

    // 改行文字分だけ進める
    file.seek(std.ascii.newline.length, SEEK_CUR);

    string str1 = void, str2 = void;

    // "%s-%s"というフォーマットとなっているテキストを読む
    file.readf("%s-%s" ~ newline, &str1, &str2);
    writefln("%s : %s", str1, str2);
}
~~~~


* `foreach`で行ごとに取得する

ファイルの各行ごとに様々な処理を行いたいことはよく有ります。

たとえば、CSV(カンマで値が区切られた形式)として次のようなファイルがあったとしましょう。

~~~~
出席番号,点数
1,68
2,72
3,45
4,83
5,53
6,75
7,99
8,77
9,101
10,22
~~~~

このクラスの平均点や標準偏差, 各生徒に対する偏差値を求めたい場合には、`File.byLine`を使った次のようなプログラムを書くと良いでしょう。

~~~~d
import std.conv,
       std.range,
       std.stdio;

void main()
{
    immutable filename = "input.csv";

    auto file = File(filename);
    file.byLine.popFront();         // 1行捨てる

    int[] points;

    // ファイルを各行取得する。
    // KeepTerminator.noを指定すると、改行文字がlineの末尾に現れなくなる
    // lineはstring型
    foreach(line; file.byLine(KeepTerminator.no)){
        // 行をカンマ","で区切り、2つ目の要素を数値(int)に変換する
        points ~= line.split(",")[1].to!int();
    }

    // 平均
    immutable mean = {
        real sum = 0;
        foreach(e; points)
            sum += e;

        return sum / points.length;
    }();

    // 標準偏差
    immutable devi = {
        real sum = 0;
        foreach(e; points)
            sum += (e - mean) ^^ 2;

        return (sum / points.length) ^^ 0.5;
    }();

    // 全員の偏差値
    real[] scor;
    foreach(e; points)
        scor ~= 10 * (e - mean) / devi + 50;

    writefln("Mean: %s", mean);
    writefln("Standard Deviation: %s", devi);
    writefln("Standard Score: \n%(%s\n%)", scor);
}
~~~~

~~~~
Mean: 69.5
Standard Deviation: 22.9532
Standard Score:
49.3465
51.0892
39.3261
55.8815
42.8115
52.3962
62.8522
53.2675
63.7236
29.3057
~~~~


`File.byLine`はレンジを返します、と言ってもまだレンジについては説明してませんので、今の時点では「配列みたいなもの」が返ってくると解釈してください。


* nバイトごとに取得する

筆者は、この記事を書いている時点では高専5年生で、今までに電気工学を5年間学び、さらにあと4年はオプトエレクトロニクス(光と半導体)について勉強するつもりです。
高専では4年生や5年生になれば卒業研究があるのですが、私は電離層ついて研究しています。
電離層は地上50kmから500km程度の大気の層のことをいいます。
なぜ電気工学科なのに大気の研究をしているか不思議ではありませんか？

電離層では多くの気体分子が太陽からの光によって電離した状態にあります。
つまり、電荷密度が存在するのですが、その電荷密度によって電波は屈折されてしまいます。
この現象によって電波を使った長距離通信が行えるのですが、時々電離層は非常に乱れた状態になってしまいます。
電離層が乱れた状態では、電波は上手く反射されず長距離通信に影響を及ぼしてしまいます。
実は、電離層の研究は進んでおらず、このような電離層の乱れがなぜ起こるのかもはっきりとはわかっていません。
また、大規模な地震の前触れとして電離層が乱れる現象を利用して、電離層を観測することによって地震を予測することも注目されています(私の個人的意見では無理だろうと思っていますが)。
私の卒業研究のテーマは、GPS(広義ではGNSS)から来る電波を用いて電離層の状態を把握することです。

つまり私の卒業研究は、GPS衛星が出す電波を地上のアンテナで取得し、そのデータを解析することです。
アンテナで取得した信号はフロントエンドに入り、約1.5GHzという高い周波数からヘテロダインによってたった6.5MHzまで落とされます。
6.5MHzの信号は、26Msps(1秒間に26×2^20個のデータを取得)というもの凄いサンプリング速度でAD変換され、コンピュータにUSBを通して保存されます。

コンピュータに保存されたデータは、1バイトが1回のサンプリングされたデータに相当し、プログラムでは1msごとに処理しているので、1度のファイル読み込みで26Msps×1byte×1ms=26kBのデータを取得することになります。

`File.byChunk`を使えば、このような「一定量を連続して読み込む」動作が簡単に実現可能です。

~~~~d
import std.stdio;


void main(){
    immutable filename = "data.dat";
    auto file = File(filename);

    foreach(buf_; file.byChunk(26 << 20)){
        // buf_はbyChunkによって使いまわされるので、
        // もしbuf_を書き換えるか、
        // ループを抜けてもbuf_を保存しておきたいのであれば、
        // .dupでコピーをとっておく
        auto buf = buf_.dup;

        // bufに対する処理
    }
}
~~~~


### `std.file.read`や`std.file.readText`を使う

`std.stdio.File`を使用するのに比べると、`std.file`のこの2つの関数は、ファイルの内容全部を取得するのに便利です。

`std.file.read`はファイルの内容をバイナリとして、`std.file.readText`はファイルの内容を文字列として読み込む場合に適しています。


~~~~d
import std.stdio;

void main(){
    auto bs = cast(ubyte[])read("data.dat");        // data.datをまるごと読み込む

    auto str = readText("foo.txt");                 // テキストとして読み込む
}
~~~~


## 標準入力`stdin`

標準入力とは、コンソールへのキーボードを使った入力です。
次のソースコードをコンパイルし実行してみるとその意味がわかるでしょう。

~~~~d
import std.conv,
       std.string,
       std.stdio;

void main()
{
    write("Please put a number and press the Enter Key. ---- ");
    
    immutable n = readln()      // 1行読み込んで
                  .chomp()      // 末尾の改行を消して
                  .to!int();    // intに変換

    write("Please put a number and press the Enter Key. ---- ");

    immutable m = readln()      // 1行読み込んで
                  .chomp()      // 末尾の改行を消して
                  .to!int();    // intに変換

    writeln("Sum of the numbers you entered is %s.", n + m);
}
~~~~


## 問題

[解答]({{ site.baseurl }}/dmanual/answer#main_io)

* 問題1

    `readln`を使って3行取得して、各行の先頭2文字を削って表示するプログラムを作りなさい。  


* 問題2

    ファイル`from`の内容をそのままファイル`to`として書き出す関数`void copyTo(string from, string to)`を、次の2通りの方法で作りなさい。
    一つ目は`std.file`の関数を使い、もう一つは`std.stdio.File`を活用しなさい。


* 問題3

    コンソール(標準入力)に入力された文字をそのままファイルに出力するプログラムを作りたい。
    コンソールへの入力の形式は以下のようになる。

    ~~~~
    [書き出したいファイル名]
    [書き出したい行数nの指定]
    [ファイルに書き出す内容：1行目]
    [ファイルに書き出す内容：2行目]
                ・
                ・
                ・
    [ファイルに書き出す内容：n行目]
    ~~~~

    つまり、以下の様な入力であれば、ファイル`"foo.txt"`に`foo bar`と`hogehoge`の2行だけ書きだされる。

    ~~~~
    foo.txt
    2
    foo bar
    hogehoge
    ~~~~


## おわりに

今回の問題は簡単にしたつもりですがどうでしょうか？
入出力については、dioというものが提案されていたりするので、将来大きな変更が入る可能性があります。

さて、次からはユーザー定義型シリーズとなります。
第一回目である次回は構造体について解説します。


## キーワード

+ `std.stdio`
    - `File`
+ `std.file`
    - `write`
    - `append`
    - `read`
    - `readText`
