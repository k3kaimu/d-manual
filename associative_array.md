

{{ **注意** このページを含むd-manualの全記事は[専用ページ](https://k3kaimu.github.io/dmanual/)へ移行しました。今後は上記の専用ページでご覧ください。}}

## 連想配列(Associative Array)とは？

連想配列は、その名前の通り、「キー(key)から、値(value)を連想する」配列です。
ちゃんと言うと、「インデックスが整数じゃなかったり、飛び飛びの値になっている配列」になります。
つまり、「文字列をインデックスとして`double`型の値を格納した連想配列」というのもできます。
連想配列では、配列でインデックスと呼ばれたものは「キー(key)」といわれます。

## 基本操作

キーの型を`K`、値の型を`V`とすれば、連想配列の型は`V[K]`です。

百聞は一見に如かず、以下のサンプルソースコードを確認してみましょう。

~~~~d
// test00901.d
import std.stdio;

void main()
{
    int[string] aa = ["homu" : 1, "mami" : 2];

    writeln(aa["homu"]);        // 1
    writeln(aa["mami"]);        // 2
    //writeln(aa["saya"]);      // core.exception.RangeError@test00901(9): Range violation
                                // 存在しないキーにアクセスしたから、エラーが出た.

    aa["foo"] = 12;             // キー"foo"に値`12`を格納
    aa["bar"] = 13;
    writeln(aa["foo"]);         // 12
    writeln(aa["bar"]);         // 13

    aa["foo"] = 15;             // 再度代入
    writeln(aa["foo"]);         // 15

    size_t len = aa.length;     // 現在格納している要素数
    writeln(len);               // 4

    bool b = aa.remove("foo");  // "foo"を削除, removeはaaが"foo"を持っていたかどうかを返す
    writeln(b);                 // true
    len = aa.length;
    writeln(len);               // 3

    aa = null;                  // nullを代入すると、初期化される
    len = aa.length;
    writeln(len);               // 0

    auto aa2 = aa;              // 連想配列は「凄いポインタ」なので、代入はポインタ値の代入に等しい
    aa2["home"] = 2;            // aa2の"home"の書き換え
    writeln(aa["home"]);        // 2
                                // aaも書き換わる

    aa2["mado"] = 100;          // aa2に"mado"を追加
    writeln(aa["mado"]);        // 100
                                // aaにも"mado"が追加されている
}
~~~~

文章で説明する必要はないと思いますが、連想配列リテラルは`[<key0>: <value0>, <key1>:<value1>, ...]`というように書きます。
また、キーを指定して値の左辺値を得る方法は、`<aa>[<key>]`です。

ある一組のキーと値を、連想配列から取り除きたい場合には、`<aa>.remove(<key>)`とします。
また、全要素削除したいなら、`null`を代入します。

連想配列について注意しなければいけないのは、実際には「凄いポインタ」であるということです。
つまり、代入したとしても、凄いポインタなので、ポインタ値が代入されるだけで全く同じ連想配列を指しています。


### in演算子

たとえば、連想配列`aa`が、キー`key`の要素を持っているかどうかわからない状況があります。
そのような場合に、連想配列が実際にそのキーを持っているか確認する方法が、`in`演算子です。

`in`演算子は、2項演算子で、`<key> in <aa>`という形式になります。
間違いやすいのは、キーと連想配列の位置ですが、英文的に考えれば自然的でしょう
。

`in`演算子の結果は、値へのポインタ`V*`です。
もし、連想配列にそのキーがなければ`null`を返しますが、ある場合にはそのキーに対応する値へのポインタになります。

`<key> !in <aa>`とすれば、連想配列にそのキーがない場合に`true`となり、ある場合には`false`となります。

~~~~d
// test00902.d
import std.stdio;
import std.exception : enforce;

void main()
{
    auto madoMagi = ["mado": 1, "homu": 2,
                     "saya": 3, "anko": 4];

    // if文と組み合わせて使うと便利
    if(auto p = "mami" in madoMagi)             // false
        writefln("マミさん(%s)は生きています。", *p);
    else
        writeln("マミさんは、マミられたようです");

    madoMagi.remove("saya");


    if("saya" !in madoMagi)                     // true
        writeln("さやかちゃんは魔女化したようです");
}
~~~~


### 同値テスト(`==`, `is`)

2つの連想配列が等しい`==`とは、2つの連想配列のキーがすべて等しく、その対応する値がお互いに等しい場合にいいます。
また、2つの連想配列が全く同じ連想配列を指しているなら、`a is b`は`true`となります。

~~~~d
auto aa1 = ["mado": 1, "homu": 2, "saya": 3, "anko": 4];
auto aa2 = ["mado": 1, "homu": 2, "saya": 3, "anko": 4];

writeln(aa1 == aa2);            // true
writeln(aa1 is aa2);            // false

aa1["mami"] = 5;
writeln(aa1 != aa2);            // true

aa1 = aa2;
writeln(aa1 is aa2);            // true
~~~~


## プロパティ

### `size_t aa.length`

その連想配列が持つ要素の数を返します。

~~~~d
int[int] aa = [0:0, 1:1, 2:2];

writeln(aa.length);         // 3
~~~~


### `V[K] aa.dup`

配列に対する`dup`同様に、新しい連想配列にすべてコピーし、返します。

~~~~d
int[int] aa = [0:0, 1:1, 2:2];
auto aa2 = aa;

aa2[0] = 12;
writeln(aa);                // 12
                            // aa2を書き換えると、aa3も書き換わってしまう

aa2 = aa.dup;

aa2[0] = 13;
writeln(aa[0]);             // 12
                            // aa2を書き換えても、aaには影響はない
~~~~


### `V aa.get(K key, lazy V defValue)`

`aa`の`key`の要素を返します。
`aa[key]`とは違い、もし`key`が`aa`に無ければ`defValue`を返します。
また、返されるのは右辺値なので、その値を通しての書き換えは不可能です。
`defValue`は、`key`が`aa`にない場合にのみ評価されます。
(`lazy`は遅延評価を表し、式の評価を遅らせることを意味します。)

~~~~d
int[int] aa = [0:0, 1:1, 2:2];

writeln(aa.get(0, -1));         // 0

writeln(aa.get(10, -1));        // -1
~~~~


### `K[] aa.keys`

連想配列が持つ、キーすべてをスライスにして返します。
キーの並び順は予測不能です。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4];

writeln(madoMagi.keys);
    // ["homu", "saya", "mado", "anko"]
    // 実際に必ずこのような順番になるかはわからない
~~~~


### `V[] aa.values`

連想配列が持つ値すべてをスライスにして返します。
`.keys`同様に、並び順は予測不能です。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4];

writeln(madoMagi.values);
    // [2, 3, 1, 4]
    // 実際に必ずこのような順番になるかはわからない
~~~~


### `auto aa.byKey`

連想配列が持つキーをすべて、レンジ(`Input Range`)にして返します。
もちろん、並び順は予測不能です。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4];

auto keyRng = madoMagi.byKey;
//keyRng.front = "majo";        // .frontは左辺値を返すので経由で書き換え可能だが、
                                // 危険なので書き換えてはいけない。

writeln(keyRng);                // ["homu", "saya", "mado", "anko"]
~~~~


### `auto aa.byValue`

連想配列が持つキーをすべて、レンジ(`Input Range`)にして返します。
何度もいいますが、並び順は予測不能です。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4];

writeln(madoMagi.byValue);      // [2, 3, 1, 4]
    // ["homu", "saya", "mado", "anko"]
    // 実際に必ずこのような順番になるかはわからない

auto valueRng = madoMagi.byValue;
valueRng.front = 100;

valueRng.popFront();
valueRng.front = 100;           // これは、.byKeysとは違いOK

writeln(madoMagi);              // ["homu":100, "saya":100, "mado":1, "anko":4]
~~~~


### `V[K] aa.rehash()`

詳しくは「ハッシュ」の節で説明しますが、連想配列の各要素に高速にアクセス可能なようにします。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4];

writeln(madoMagi);  // ["homu":2, "saya":3, "mado":1, "anko":4]

madoMagi.rehash();

writeln(madoMagi);  // ["homu":2, "saya":3, "anko":4, "mado":1]
                    // 最適化されたので、並び順が上と異なっている！
~~~~


## foreach

連想配列は、さまざまな方法を使って`foreach`で回すことができます。


### ベーシックな方法

もっとも基本的な方法は、`foreach(key, value; aa)`とすることです。
`value`の方は`ref`をつけて参照(書き換え可能)にできますが、`key`を`ref`にすると危険なので、できません。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4, "mami": 5];

foreach(k, v; madoMagi)
    writefln("%s : %s", k, v);

writeln();

foreach(k, ref v; madoMagi)
    v = 100;

writefln("%-(%s : %s%|\n%)", madoMagi);

/* 実行結果
homu : 2
saya : 3
mado : 1
anko : 4
mami : 5

homu : 100
saya : 100
mado : 100
anko : 100
mami : 100
*/
~~~~


### `aa.keys`を使った方法

`aa.keys`はキーのスライスを返すので、そのスライスを`foreach`でたどれば良いのです。
ただし、新たに領域が確保されてしまいます。
先ほどの例と同じ動作をするものを`.keys`で書くと、以下のようになります。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4, "mami": 5];

foreach(k; madoMagi.keys)
    writefln("%s : %s", k, madoMagi[k]);

writeln();

foreach(k; madoMagi.keys)
    madoMagi[k] = 100;

writefln("%-(%s : %s%|\n%)", madoMagi);
~~~~


### `aa.byKey`を使った場合

`aa.byKey`は、キーを要素とするレンジなので、`.keys`同様に使えますが、新たな領域が確保されません。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4, "mami": 5];

foreach(k; madoMagi.byKey)
    writefln("%s : %s", k, madoMagi[k]);

writeln();

foreach(k; madoMagi.byKey)
    madoMagi[k] = 100;

writefln("%-(%s : %s%|\n%)", madoMagi);
~~~~


### `aa.values`を使った場合

もしキーの値が要らないのであれば、`.values`を使うことで値だけイテレートできます。
`.keys`同様に、新しく領域が確保されます。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4, "mami": 5];

foreach(v; madoMagi.values)
    writeln(v);
~~~~


### `aa.byValue()`を使った場合

`.values`同様に値のみでイテレートできますが、`.byValue`経由だと値の変更ができ、レンジなので新しく領域が確保されません。

~~~~d
auto madoMagi = ["mado": 1, "homu": 2,
                 "saya": 3, "anko": 4, "mami": 5];

foreach(v; madoMagi.byValue)
    writeln(v);

writeln();

foreach(ref v; madoMagi.byValue)
    v = 100;

writefln("%-(%s : %s%|\n%)", madoMagi);
~~~~


## クラスをキーとして使うには(高度)

連想配列のキーとしてクラスを使うには、クラスに`toHash`や`opEquals`を定義する必要があります。
`hash_t`は`size_t`の`alias`です。

~~~~d
/// test.d
import std.stdio;

class MyKey
{
    this(int a){ _a = a; }

    override hash_t toHash(){ return _a; }
    override bool opEquals(Object o){
        auto rhs = cast(MyKey)o;
        return rhs && rhs._a == this._a;
    }

  private:
    int _a;
}

void main()
{
    int[MyKey] aa;

    aa[new MyKey(1)] = 12;
    aa[new MyKey(2)] = 3;
    aa[new MyKey(3)] = 4;

    aa[new MyKey(1)] = 8;   // rewrite

    writeln(aa);
}
~~~~

~~~~
$ rdmd test
[foo.MyKey:8, foo.MyKey:3, foo.MyKey:4]
~~~~

構造体や共用体については、これらの二つはデフォルトではバイナリから算出されます。
もちろん、プログラマが定義するとその方式でハッシュ, 比較されます。

~~~~d
/// test.d
import std.stdio;

struct MyKey
{
    int a;
    int b;  // これを無視したい

    hash_t toHash() const nothrow @safe { return a; }
    bool opEquals(ref const MyKey rhs) const
    { return this.a == rhs.a; }
}

void main()
{
    int[MyKey] aa;

    aa[MyKey(1, 2)] = 12;
    aa[MyKey(2, 3)] = 3;
    aa[MyKey(3, 4)] = 4;

    aa[MyKey(1, 4)] = 8;   // rewrite

    writeln(aa);
}
~~~~

~~~~
$ rdmd test
[MyKey(1, 2):8, MyKey(2, 3):3, MyKey(3, 4):4]
~~~~


## 問題 -> [解答](answer.md#associative_array)

* 問題1  

入力として、人の名前とある数字がN行与えられる。先頭行はNがいくらかを示している。人名が重なることはなく、数字は重なっている可能性がある。たとえば、以下のように。

~~~~
11
kotoge      92
usagi       81
keika       25
uchizono    59
ayakura     18
shihori     33
sakagami    13
kasiwagi    13
takahashi   25
nakamura    11
fuzimiya    89
~~~~

このようなリストが与えられた場合に、名前をアルファベットでソートした順番(五十音順ではない)で数字も一緒に出力するようなプログラムを作成してください。  
参考として、例のリストが入力された場合の正しい出力を以下に示しておきます。
この出力例でのフォーマットは`writefln("%-12s\t\t%s", name, value);`となっていますが、異なったフォーマットでも構いません。

~~~~
ayakura                 18
fuzimiya                89
kasiwagi                13
keika                   25
kotoge                  92
nakamura                11
sakagami                13
shihori                 33
takahashi               25
uchizono                59
usagi                   81
~~~~


* 問題2  

問題1では、アルファベット順でしたが、今度は数字の順番で並べてみましょう。もし、同じ数字に複数人いる場合には、その中でもアルファベット順で出力してください。
つまり、例に対する出力は以下のようになります。  
(ヒント: 数字ごとに人名リストを作る`string[][int]`という連想配列に格納してみると…)

~~~~
nakamura                11
kasiwagi                13
sakagami                13
ayakura                 18
keika                   25
takahashi               25
shihori                 33
uchizono                59
usagi                   81
fuzimiya                89
kotoge                  92
~~~~


## おわりに

連想配列は、配列よりもコストが大きいですが、その分様々な局面で活躍してくれるすごい機能です。
特にDの連想配列は、言語組込みという利点があり、`in`演算子や`dup`などのすごい機能が簡単に書けてしまいます。

さて、次回は今までよく出てきたポインタについて再学習します。


## キーワード

* 連想配列(Associative Array)
* キー(Key)
* 値(Value)
* `in`
* `.length`
* `.dup`
* `.get(K key, lazy V defValue)`
* `.keys`
* `.values`
* `.byKey`
* `.byValue`
* ハッシュ(Hash)

## 仕様

[英語](http://dlang.org/hash-map.html)
[日本語](http://www.kmonos.net/alang/d/hash-map.html)
