# 関数

## 関数とは？

<b>関数</b>(function)は、

1. データを受け取って、
2. データの加工や、何か処理を行い、
3. 結果を返す

ものです。

関数が受け取るデータのことを、<b>引数</b>(argument)といい、
関数が返す結果を<b>返り値</b>または<b>戻り値</b>(return value)といいます。

数学での関数`f(x, y, z, ...)`は、引数が同じであれば、常に同じ結果を返します。
しかし、プログラムの関数はそうではありません。

プログラムの関数では、同じ引数が与えられたとしても、外界の状態によっては計算結果が変わるからです。
たとえば、「コンソールで入力された数を`int`型で返す」関数`readInt`があったとします。
その関数は「何も受け取らず、ただ`int`型を返すような関数」だと定義できます。
この関数の返す値は人間がコンソールに入れる値に左右されます。


### 関数による処理のまとめ

頻繁に使う処理をまとめて関数にしておくことによってソースコードの可読性やメンテナンス性が向上します。
たとえば、もし、配列の総和を返す関数`sum`が定義されているなら、総和を計算する箇所では`foreach`文の代わりに`sum`関数を使って書くことができます。

~~~~d
// before: sumを使わない
{
    int s;              // 合計

    foreach(e; arr1)
        s += e;


    int av;             // 平均

    foreach(e; arr2)
        av += e;

    av /= arr2.length;
}


// after: sumを使う
{
    int s = sum(arr1),
        av = sum(arr2) / arr2.length;
}
~~~~~~~~~~~~~~~~~~

もし、プログラミング言語に関数という機能がないとしたら、プログラミングという作業は非常につらい作業になったことでしょう。
もしくは、ユーザーは関数を定義できない言語だとしたら、あなたはプログラムを書くことを辞めたくなるはずです。
それほど、関数が行う処理の「隠蔽」と「まとめ」は重要なのです。


## 関数の基礎

### 宣言の書き方と関数本体

D言語では、引数リスト`ParameterList`を受け取り、`ReturnType`を返す関数を以下のように書きます。
この基本の構文は、C言語やC++などの言語と同じ構文です。

~~~~d
ReturnType functionName(ParameterList)
{
    FunctionBody
}
~~~~~~~~~~~~~~~~~~

<b>関数本体</b>(`FunctionBody`)は省略して、<b>関数プロトタイプ</b>のみにすることができます。
その場合には、`{FunctionBody}`の代わりに`;`を付けておきます。

~~~~d
ReturnType functionName(ParameterList);
~~~~~~~~~~~~~~~~~~

たとえば、`int`型の値を2つ受け取って、それらの和を返す関数`addInt`は、次のように書きます。

~~~~d
int addInt(int a, int b)
{
    return a + b;
}
~~~~~~~~~~~~~~~~~~

`return`文は`return <expr>;`という形式をとり、機能は「`<expr>`を返し、処理を呼び出し元に復帰する文」です。
簡単にいえば、呼び出し元に結果を返してから、その関数を即座に終了させる効果があります。
返り値がある関数では、必ず`return`で値を返して関数を終了させます。

もちろん`return`文は、次のように関数の任意の場所に書くことができます。

~~~~d
int foo(int a)
{
    if(a)
        while(a)
            do
                return a;
            while(a);

    return a;
}
~~~~~~~~~~~~~~~~~~

[Goto: 問題1 「readIntを実装しよう」](#Q1)  
[Goto: 問題2 「sumを実装しよう」](#Q2)  

関数のすべての条件分岐や最後に`return`が無ければ、コンパイルエラーとなります。
ということは、関数内の絶対に到達し得ない場所にも`return`が必要である、ということになります。
なぜなら、コンパイラでは「絶対に到達し得ない場所」という判断が行えず、また絶対に`return`しなければ、その関数が値を返さずに終了してしまうという事態に陥るからです。

次の状況を想像してみましょう。
関数人であるB君は、同じく関数人であるAさんに愛情(引数)をもらって一生懸命働きます。
しかし、B君はAさんに給料(返り値)を渡しませんでした。
そんな状況は有ってはならないのです。
もちろん、最初から見返りがない(返り値型が`void`)場合はいいのですが。

~~~~d
// 意味のない関数
int foo(int a)
{
    if(a || !a){
        while(a){
            if(a)
                return a;
        }
    }
    
    // ここには絶対到達しない
    // しかし、returnしておかないとコンパイラに怒られる
    return 0;
}
~~~~~~~~~~~~~~~~~~

絶対に到達し得ないのに`return 0;`と書いていると、他人が読んだ時に「こいつ何書いてるんだ？」というふうに思われてしまします。
また、`return 0;`というコードを入れることによって、その関数が失敗したから`0`を返したのか、成功した結果の`0`なのかわからなくなります。
よって、このような場合には`return`の代わりに`assert(0);`を入れてあげます。

~~~~d
// 意味のない関数
int foo(int a)
{
    if(a || !a){
        while(a){
            if(a)
                return a;
        }
    }
    
    // ここには絶対到達しない
    assert(0);
}
~~~~~~~~~~~~~~~~~~

`assert(0);`があれば、`return`がなくてもコンパイルは通ります。
もしその`assert(0);`が実行されてしまったとしても次のようなメッセージと共にプログラムはただちに終了します。

~~~~~~~~~~~~~~~~~~
core.exception.AssertError@foo(10): Assertion failure
----------------
0x0040323B
0x0040201E
0x0040202A
0x00402633
0x00402231
0x00402054
0x75B933AA in BaseThreadInitThunk
0x772F9EF2 in RtlInitializeExceptionChain
0x772F9EC5 in RtlInitializeExceptionChain
----------------
~~~~~~~~~~~~~~~~~~


次の状況を想像してみましょう。
関数人であるB君は、同じく関数人であるAさんに愛情(引数)をもらって一生懸命働きます。
しかし、B君はAさんに給料(返り値)を渡しませんでした。
実は、関数人には爆弾(`assert(0);`)が仕かけられています。
その爆弾が爆発するのは、恩など(返り値)を返さなかったときです。
つまり、B君は爆発しました。
悲しいことに、B君が爆発してしまったがために給料がもらえなかったAさんは、Aさん自身の仕事を遂行できなくなりました。
その結果、AさんはAさんの親(関数Aの呼び出し元)に給料を送ることができなくなりました。
すると、Aさんの爆弾も爆発し、つまり最終的にはmain関数ちゃんまでもが爆発して、プログラム界は破滅します。


[Goto: 問題3 「コンパイルできない！」](#Q3)  

何も返さない関数を書きたいのであれば、`ReturnType`を`void`とします。
そのような関数では、`return`を関数中に書く必要はなく、関数を途中で終わらせたい場合にだけ`return;`と書きます。
返り値がない関数で、`return`文が実行されることなく関数の最後まで到達した場合には、`return`文と同様の効果により関数が終了します。

~~~~d
void foo(int a, int b)
{
    if(a > 0)
        return; // a > 0 の場合には、関数は終わり、即座に処理が呼び出し元に戻る
    else
        writeln(b - a);

    // a <= 0 の場合にはここまで来て、処理が呼び出し元に戻る
}
~~~~~~~~~~~~~~~~~~

この説明が分かりにくければ、`main`関数を思い出してみましょう。
`main`関数は、`ReturnType`が`void`な関数でしたが、`return`文をいちいち入れませんでしたね。
しかし、`main`関数はちゃんと終了していました。

`return`文を入れて、`main`関数を途中で強制的に終わらせることもできます。

~~~~d
import std.conv, std.stdio, std.string;


/// 例：コンソールで入力された数字をint型で返す関数
int readInt()
{
    return readln().strip().to!int();
}


void main()
{
    writeln("main");
    writeln("10以上整数を入力すると終了----");

    if(readInt() >= 10)     // ある条件を満たせば、
        return;             // 終了

    writeln("end");
}
~~~~~~~~~~~~~~~~~~

[Goto: 問題4 「helpメッセージを表示せよ」](#Q4)  


### 関数の引数

関数は引数を受け取りますが、関数宣言で書かれている`int a`や`int b`を<b>仮引数</b>(parameter)といいます。
逆に、`addInt(4, 5)`とした場合の`4`や`5`は<b>実引数</b>(argument)といわれます。

関数本体が無い場合、もしくは仮引数を関数本体で使わない場合には、仮引数を省略して型だけにすることもできます。

~~~~d
// intを3つ受け取るが、関数本体がないので仮引数は型だけしか書かない
int add(int, int, int);
~~~~~~~~~~~~~~~~~~

通常、実引数は仮引数にコピーされて関数に渡されます。
つまり、値型であれば仮引数を変更しても実引数には影響しませんが、参照型であればその参照(住所)をコピーしますから、コピーされた参照を通して参照元に影響を与える可能性があります。

~~~~d
// aは値型
void addToValue(int a, int b)
{
    a += b;
}


// aはポインタ(参照型)
void addToRef(int* a, int b)
{
    *a += b;        // ポインタの参照先のインクリメント
                    // 呼び出し元に影響を与える操作

    a = null;       // ポインタの書き換え
                    // この操作では呼び出し元に影響はない
}


void main()
{
    int m = 2,
        n = 13;

    addToValue(m, n);
    writefln("m: %s, n:%s", m, n);      // 2, 13

    addToRef(&m, n);                    // ポインタ(参照型)を渡す
    writefln("m: %s, n:%s", m, n);      // 15, 13
                                        // m が書き換えられてる！
}
~~~~~~~~~~~~~~~~~~

宣言された仮引数の型のリストと実引数の型のリストが一致しなければコンパイル時にエラーがでます。

~~~~d
// test00901.d
int add(int a, int b) { return a + b; }

void main()
{
    int a = add(3, 5),
        b = add(3),             // Error: function test00901.add (int a, int b) is not callable using argument types (int)
        c = add(3, 4, 5),       // Error: function test00901.add (int a, int b) is not callable using argument types (int, int, int)
        d = add(3.0, 4);        // Error: function test00901.add (int a, int b) is not callable using argument types (double, int)
}
~~~~~~~~~~~~~~~~~~


## デフォルト引数

仮引数にはデフォルト値を設定することができます。
デフォルト値が設定された仮引数に渡す実引数は省略することができます。
省略された場合には、仮引数に設定されたデフォルト値が仮引数の値となります。

しかし、デフォルト値を設定したとしても、その仮引数の後ろにデフォルト値が設定されていない仮引数がある場合にはコンパイルエラーとなります。

~~~~d
int getValue(int* p, size_t idx = 0)
{
    return p[idx];
}


// idxはデフォルト値が設定されているが、後ろにデフォルト値が設定されていない v があるのでエラー
// Error: default argument expected for v
/*
bool getAndTest(int* p, size_t idx = 0, int v)
{
    return p[idx] == v;
}
*/

// デフォルト値は2つ以上の引数にも設定可能
int getValue2d(int** p, size_t i = 0, size_t j = 0)
{
    return p[i][j];
}


void main()
{
    int* p = (new int[10]).ptr;
    foreach(i, ref e; p[0 .. 10])
        e = i;

    p[0 .. 10].reverse;

    writeln(p[0 .. 10]);            // [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

    // idxを指定して呼び出し
    writeln(getValue(p, 4));        // 5

    // idxを省略して呼び出すと、idxは0であると解釈される
    writeln(getValue(p));           // 9

    int** pp = &p;
    writeln(getValue2d(pp));          // 9
}
~~~~~~~~~~~~~~~~~~


## 引数の記憶域クラス

関数の引数にも、普通の変数と同様に[記憶域クラス(storage class)](variable_type.md#%E8%A8%98%E6%86%B6%E5%9F%9F%E3%82%AF%E3%83%A9%E3%82%B9storage-class)を付けることができます。

一切記憶域クラスがついていない引数は、値が(参照型ならその参照が)コピーされます。
これに対して、`ref`や`out`, `lazy`は特殊な渡され方をされます。


+ `const`

    `const`が付けられた仮引数の型は`const(Type)`となり、その仮引数は書き換え不可能になります。
    `const T arg`と`const(T) arg`は同じ意味です。

    `const`な引数は、mutableな値(`const`, `immutable`ではない)でも非mutableな値(`const`か`immutable`)でも、受け取ることができます。

    (「mutableな」とは、「変更可能な」という意味です。)

    [`const`型の解説](variable_type.md#const)

    ~~~~d
    int getValue(const int* p)
    {
        //*p += 3;                  // pはconst(int*)型、*pはconst(int)型なので書き換え不可

        return *p;                  // *pはconst(int)型なので、int型として返せる
    }
    ~~~~~~~~~~~~~~~~~~


+ `immutable`

    `immutable`記憶域クラスとなっている引数はその引数の型が`immutable(Type)`となります。

    `immutable`記憶域クラスな引数は`immutable`な値しか受け付けません。
    もちろん、引数はコピーされるため`immutable`でない値型も受け付けます。
    値型であれば`immutable`なコピーを作ることができるからです。

    [`immutable`型の解説](variable_type.md#immutable)

    ~~~~d
    immutable(int)* getValue(immutable int* p)
    {
        //*p += 3;                  // pはimmutable(int*)型、*pはimmutable(int*)型なので書き換え不可

        return *p;                  // *pはimmutable(int*)型なので、immutable(int)*型として返せる
    }
    ~~~~~~~~~~~~~~~~~~


+ `inout`

    このストレージクラスとなった引数は`inout`型になります。
    仮引数に`inout`型を一つでも含む関数はinout関数と呼ばれます。
    inout関数は、その関数を呼び出す実引数によって関数の返り値の型が変わります。

    まずは仮引数に`inout`型を1つだけ含む関数`inout(int[]) getFront(inout(int[]) x);`について考えてみましょう。
    この関数には`int[]`や`const(int[])`、さらには`immutable(int[])`型の値を渡すことが出来ます。
    `getFront`関数の返り値は、実引数が`int[]`の場合には`int[]`が、`const(int[])`の場合には`const(int[])`が、そして`immutable(int[])`の場合には`immutable(int[])`になります。

    コンパイラが3つのパターンについて`getFront`関数を生成しているわけではないことに注意しましょう。
    コンパイラは、呼び出し毎に、実引数の型を調査して、それに見合った返り値の型を設定しているのです。

    次に、仮引数に`inout`型が1つよりも多く存在した場合ですが、コンパイラは呼び出し毎にすべての`inout`仮引数に対する実引数を調査します。
    コンパイラによる実引数の調査の結果、コンパイラは次のように返り値の型を変更します。
    1. `inout`に対応する型がすべて`immutable`であれば返り値の`inout`も`immutable`に置き換わった型になります。
    2. `inout`に対応するすべての実引数の型がmutable(`const`でも`immutable`でもない)であれば、返り値の`inout`は取り除かれます。
    3. 1や2にマッチしなかった場合は返り値の`inout`は`const`に置き換わります。

    ~~~~d
    inout(int)[] foo(inout(int[]) x, inout(int[]) y)
    {
        return x ~ y;
    }


    void main()
    {
        int[] marr = [1, 2, 3];
        const carr = marr;
        immutable iarr = marr.dup;

        // (mutable, mutable) => mutable
        auto a = foo(marr, marr);
        static assert(is(typeof(a) == int[]));

        // (mutable, const) => const
        auto b = foo(marr, carr);
        static assert(is(typeof(b)== const(int)[]));

        // (mutable, immutable) => const
        auto c = foo(marr, iarr);
        static assert(is(typeof(c) == const(int)[]));

        // (const, immutable) => const
        auto d = foo(carr, iarr);
        static assert(is(typeof(d) == const(int)[]));

        // (immutable, immutable) => immutable
        auto e = foo(iarr, iarr);
        static assert(is(typeof(e) == immutable(int)[]));
    }
    ~~~~

    また、inout関数内でのみ`inout`型の変数を宣言できます。
    `inout(T)`という型は`const(T)`へは暗黙変換可能ですが、`T`や`immutable(T)`へは暗黙変換できません。

    ~~~~d
    import std.traits;

    void foo(inout(int)[] x)
    {
        inout(int)[] y = x;
        auto z = x ~ y;
        static assert(is(typeof(z) == inout(int)[]));

        //int[] mz = z;     Error
        const cz = z;
        //immutable iz = z; Error

        // inout と mutable の CommonType => const
        static assert(is(CommonType!(inout(int)[], int[])
            == const(int)[]));

        // inout と const の CommonType => const
        static assert(is(CommonType!(inout(int)[], const(int)[])
            == const(int)[]));

        // inout と immutable の CommonType => inout(const(int))
        static assert(is(CommonType!(inout(int)[], immutable(int)[])
            == inout(const(int))[]));
    }
    ~~~~


+ `shared`

    この記憶域クラスとなっている引数の型は、`shared`型になります。

    [`shared`型の解説](variable_type.md#shared)


+ `scope`

    `scope`が付いた引数は、その引数が持つ参照をその関数の外部に移動することができなくなります。
    つまり、値型な引数に`scope`をつけても意味はありませんが、スライスやデリゲート、クラスなどのような参照を持つ型はグローバル変数に代入したり、関数から返すことはできなくなります。

    ~~~~d
    int[] gSlice;               // global変数

    int[] foo(scope int[] x)
    {
        gSlice = x;             // コンパイルエラー
        return x;               // コンパイルエラー
    }
    ~~~~~~~~~~~~~~~~~~

    ただし、現在のdmd(dmd 2.063.2)では、この`scope`は機能していないようで、上記のようなコードもコンパイルが通ってしまいます。

    bugzilla
    - [Issue 6931](http://d.puremagic.com/issues/show_bug.cgi?id=6931)


+ `in`

    `const scope`と等しくなります。
    よって、`const`同様に変更ができなくなります。
    参照型に対しては、参照を関数外部に持っていくことも出来ないようになります。

    <small>ただし、現在のdmd(dmd 2.063.2)では`scope`記憶域クラスは機能してないようなので、`const`に等価な記憶域クラス？[要出典]</small>


+ `ref`

    実引数として左辺値を受け取り、仮引数への操作はすべて受け取った実引数への操作になります。
    つまり、左辺値を関数内で操作し、関数を超えてその左辺値に影響を与えたい場合に利用します。

    ~~~~d
    int moveFront(ref int[] arr)
    {
        auto dst = arr[0];
        
        arr = arr[1 .. $];
        return dst;
    }


    void main()
    {
        int[] arr = [0, 1, 2, 3];
        writeln(moveFront(arr));        // 0
        writeln(arr.length);            // 3
                                        // arrが変更されている

        writeln(moveFront(arr));        // 1
        writeln(arr.length);            // 2
                                        // arrが変更されている
    }
    ~~~~~~~~~~~~~~~~~~


+ `auto ref`

    この記憶域クラスは、テンプレート関数でのみ使用可能になります。
    なので今は気にする必要はありませんが、機能としては「`ref`で引数が取れるなら`ref`でとる」という記憶域クラスです。
    つまり、呼び出した際の実引数が左辺値であれば参照`ref`で受け取って、右辺値なら`non-ref`で受け取ります。


+ `out`

    左辺値を受け取るという特性は`ref`と同じですが、関数に入る時点でその参照の値がデフォルト初期化値`.init`で初期化され、以降は`ref`と同様の動作になります。

    返り値以外に出力をしたい場合に使用します。

    ~~~~d
    int findMax(in int[] arr, out size_t idx)
    {
        foreach(i, e; arr)
            if(e > arr[idx])
                idx = i;
        return arr[idx];
    }


    void main()
    {
        // どうせ、findMax呼び出し時に初期化されるからvoidでもよい
        size_t idx = void;

        writeln(findMax([0, 1, 5, 1, 0], idx));     // 5
        writeln(idx);                               // 2
    }
    ~~~~~~~~~~~~~~~~~~


+ `lazy`

    この記憶域クラスでは、実引数の評価は遅延評価され、関数内で必要になった時に初めて評価されます。

    仕組みとしては、引数を返すデリゲートを作り、そのデリゲートを呼び出しています。
    つまり、`foo(expr)`が`foo((){return expr;})`になります。
    デリゲートについては、後ほど説明するので、「遅延評価され、仮引数を複数回評価すると、実引数も複数回評価される」とだけ覚えておいてください。

    ~~~~d
    int get(int* p, lazy int defValue)
    {
        return p ? *p : defValue;
    }


    void main()
    {
        int a = 3;

        writeln(get(&a, ++a));      // 3
                                    // get(&a, (){ return ++a; })に等価

        writeln(get(null, ++a));    // 4
                                    // get(null, (){ return ++a; })に等価
    }
    ~~~~~~~~~~~~~~~~~~

    次のように複数回評価することもできます。

    ~~~~d
    import std.array;
    import std.stdio;


    int[] callN(lazy int v, size_t n)
    {
        // 配列に要素を追加していく場合には、std.array.appenderを使う
        auto app = appender!(int[])();

        // n回評価して、追加していく
        foreach(unused; 0 .. n)
            app.put(v);

        return app.data;            // appenderが管理している配列を返す
    }


    void main()
    {
        int a = 3;

        writeln(callN(++a, 3));               // [4, 5, 6]
    }
    ~~~~~~~~~~~~~~~~~~


    `lazy`がどれほど素晴らしい機能なのかを体験するために、次のソースコードをコンパイルして実行してみましょう。

    ~~~~d
    import std.stdio;
    import std.datetime;

    int tarai_lazy(int x, int y, lazy int z)
    {
        if (x <= y) return y;
        return tarai_lazy(tarai_lazy(x-1, y, z), tarai_lazy(y-1, z, x), tarai_lazy(z-1, x, y));
    }


    int tarai(int x, int y, int z)
    {
        if (x <= y) return y;
        return tarai(tarai(x-1, y, z), tarai(y-1, z, x), tarai(z-1, x, y));
    }


    void main()
    {
        {
            auto mt = measureTime!(a => writefln("non-lazy: %s[usecs]", a.usecs))();
            tarai(10, 8, 0);
        }

        {
            auto mt = measureTime!(a => writefln("lazy: %s[usecs]", a.usecs))();
            tarai_lazy(10, 8, 0);
        }
    }
    ~~~~~~~~~~~~~~~~~~

    実行結果はどのように出ましたか？
    私の環境では、以下のように出力されました。

    ~~~~
    non-lazy: 3344[usecs]
    lazy: 1[usecs]
    ~~~~

    先ほどのプログラムは、「[たらい回し関数(竹内関数)](http://ja.wikipedia.org/wiki/%E7%AB%B9%E5%86%85%E9%96%A2%E6%95%B0)」のD言語での実装でした。
    たらい回し関数は、関数自体が短く、引数`x, y, z`が小さな数であったとしても、計算量が膨大な数になってしまう関数です。
    私の環境だと`tarai(10, 8, 0)`に3ミリ秒程度かかったということになります。

    しかし、遅延評価バージョン(`tarai_lazy(10, 8, 0)`)では、たった1マイクロ秒で計算が終わってます。
    `tarai`と`tarai_lazy`の違いは、引数が`lazy int z`になってるだけです。
    たらい回し関数は、`z`が遅延評価されると途端に計算量が低下する関数なので、このように`tarai_lazy`は高速なのです。


## 可変個引数関数

引数に取りたい実引数の数が、実行条件によって変わることがあります。
たとえば、`writeln`や`writefln`などの`write`系の関数は、引数をいくらでも取ることができます。

このような関数を作るのには、様々な方法があります。


+ 同じ型の引数を可変個取りたい場合

    たとえば、次のように文字列をいくつか受け取って、それらを連結した文字列を返す関数は、次のように書けます。

    ~~~~d
    string chainString(string[] str...)
    {
        string chained;

        foreach(e; str)
            chained ~= e;

        return chained;
    }


    void main()
    {
        writeln(chainString());
        writeln(chainString("foo"));
        writeln(chainString("foo", "bar"));
        writeln(chainString("foo", "bar", "hoge"));
    }
    ~~~~~~~~~~~~~~~~~~

    可変長パラメータである`str`に、引数のリストが入ります。
    `str`を関数外に移動することは不正です
    (つまり、`scope`が暗黙的に付いていると考えれる？[要出典])。


    実際には、静的配列にすることもできます。
    たとえば、いくつかの数を受け取って、その中で最も大きな整数を返す関数は次のように書けます。

    ~~~~d
    T max(T, size_t N)(T[N] nums...)
    if(N > 0)
    {
        T v = nums[0];

        foreach(e; nums[1 .. $])
            v = v > e ? v : e;

        return v;
    }


    void main()
    {
        writeln(max(0, 1, 2, 3));       // 3
    }
    ~~~~~~~~~~~~~~~~~~

    この関数は、テンプレート関数(Template Function)といい、任意の型Tと0より大きい任意のNに対してマッチするテンプレート関数です。


+ 異なる型の引数を可変個取りたい場合

    `writeln`や`writefln`などは異なる型の引数を任意個取ることができます。
    このような関数は可変個引数関数と呼ばれ、普通はテンプレートを使って作ります。

    ~~~~d
    void main()
    {
        println(" : ", "foo", "bar", 2, 4);     // foo : bar : 2 : 4
    }


    void println(T...)(string sep, T values)
    {
        // valuesはforeachで回せる
        foreach(i, e; values){
            if(i != 0)
                write(sep);

            write(e);
        }

        writeln();

        /* Tもforeachで回せる
        foreach(i, Unused; values){
            write(values[i]);

            if(i != T.length - 1)
                write(sep);
        }

        writeln();
        */
    }
    ~~~~~~~~~~~~~~~~~~

    これについてはテンプレートの章で説明するとして、今回は全く使われない方法で可変個引数関数を作ります。
    この方法にはCスタイルとDスタイルがありますが、全く使う機会がないのでさらっと流してしまいます。
    詳しい仕様を知りたい場合には、[可変個引数 - プログラミング言語D](http://www.kmonos.net/alang/d/function.html#variadic)を読みましょう。

    - Cスタイルな可変個引数関数

        関数の宣言は以下のようになります。

        ~~~~d
        extern(C) void foo(int a, ...);
        // extern(C) void bar(...);             // エラー
        ~~~~~~~~~~~~~~~~~~

        `...`の部分が可変個の引数を受け取れる部分です。
        関数引数が`...`だけではいけません。
        最低1つは可変個でない引数が必要です。
        ちなみに、`extern(C)`は、「この関数はC言語みたいな関数だよ」ということです。


    - Dスタイルな可変個引数関数

        ~~~~d
        void foo(int a, ...);
        void bar(...);                          // OK
        ~~~~~~~~~~~~~~~~~~

        Dスタイルの可変個引数関数では、`_argptr`と`_arguments`という変数にアクセスできます。
        `import core.vararg;`とし、`va_arg!T(_argptr)`で型`T`の引数を取ることが出来ます。
        また、`va_arg`で引数を取ったあと次に`va_arg`を呼び出す場合は、その次の変数が読み出せます。

        `_arguments`という引数には、可変個引数部分の引数の型の情報が格納されています。
        型は`TypeInfo[]`で、`if(_arguments[i] == typeid(int)){}`のように、`i`番目の引数の型が`int`型かどうか比較ができます。

        これから例として先ほどの`println`関数を作りたいのですが、あらためて引数とその動作を以下に示します。

        ~~~~d
        println(" : ", "foo", "bar", 2, 4);     // foo : bar : 2 : 4
        println(", ", 1, 2, 'c', "foo");        // 1, 2, c, foo
        ~~~~~~~~~~~~~~~~~~

        対応する型は簡単化のために`int, char, string`でいいでしょう。
        さて、`print`関数の動作と仕様がわかったので、実装していきたいと思います。

        `_arguments`は`TypeInfo[]`ですから、`foreach`で回すのが適切でしょう。
        各要素で型を判別して、`va_arg!T`で引数を取得します。
        よって、実装は次のようになります。

        ~~~~d
        import core.vararg;
        import std.stdio;       // write, writelnを使うから

        void println(string sep, ...)
        {
            foreach(i, type; _arguments){
                if(type == typeid(int))
                    write(va_arg!int(_argptr));
                else if(type == typeid(char))
                    write(va_arg!char(_argptr));
                else if(type == typeid(string))
                    write(va_arg!string(_argptr));
                else
                    assert(0);

                if(i != _arguments.length - 1)
                    write(sep);
            }

            writeln();
        }
        ~~~~~~~~~~~~~~~~~~


## オブジェクトを形成する引数

関数に渡されたの引数で、クラスのコンストラクタを走らせ、インスタンスを組み立てることができます。

~~~~d
class Foo{ this(int x, int y){} }

// Fooのコンストラクタが呼ばれる
void foo(Foo foo...)    // fooには暗黙的にscopeが付いているようなもの
{
    writeln(foo);
}


void main()
{
    foo(1, 2);  // Fooのコンストラクタは(int, int)
}
~~~~~~~~~~~~~~~~~~


## 返値型推論

関数の返り値の型が複雑で長くなる場合があります。
その場合は、返り値の型を`auto`と書いておけば、`return`文から返り値の型が推論されるようになり便利です。

また、`auto ref`とすることで、参照で返すかどうかも推論されます。

~~~~d
import std.algorithm;

// この関数の返り値の型は MapResult!(unaryFun, FilterResult!(unaryFun, int[]))
auto func(int[] arr)
{
    return arr.filter!"a > 2"().map!"a >> 1"();
}


// 引数が左辺値(lvalue)なら、返り値もlvalue
auto ref add1()(auto ref int x)         // 仮引数記憶域クラスのauto refは、テンプレート関数専用なので`()`が必要
{
    x += 1;
    return x;
}


void main()
{
    int a;
    ++add1(a);      // 返り値がlvalueなので、インクリメントできる
    writeln(a);     // 2

    //++add1(10);   // Error: add1(10) is not an lvalue
                    // 10は右辺値(rvalue)なので、lvalueで返せない
}
~~~~~~~~~~~~~~~~~~


## 関数の属性

関数に属性をつけることで、コンパイラにその関数の情報を与えることができます。
たとえば、`@property`という属性を、引数が0個の関数に付けると、`()`を省略して呼び出すことができます。
また、外部に影響を与えないということが静的に保証されている関数には`pure`が付きます。

### プロパティ関数`@property`

引数の数が0, 1, 2個の場合にのみ有効な属性です。
この属性が付いた関数は、次のような構文で関数を呼び出すことができるようになります。

~~~~d
import std.stdio;


// 引数の数が0個のプロパティ関数
int foo() @property
{
    return 1;
}


// 引数の数が1つのプロパティ関数
int bar(int a) @property
{
    return a;
}


// 引数の数が2つのプロパティ関数
int add(int a, int b) @property
{
    return a + b;
}


//Error: properties can only have zero, one, or two parameter
/*
int tri(int a, int b, int c) @property pure nothrow @safe
{
    return a + b + c;
}
*/


void main()
{
    writeln(foo);               // 1
                                // 引数の数が0の@property関数はカッコ()無しで変数みたいに呼べる
    writeln(foo());             // もちろん、カッコ付きで読んでもOK

    writeln(bar = 12);          // 12
                                // 引数の数が1つだと、プロパティ関数がさも代入されるかのような構文で呼べる
                                // この場合は、bar(12)に等価
    writeln(12.bar);            // UFCSとプロパティ関数の組み合わせ

    writeln(1.add = 15);        // 16
                                // 引数の数が2つだと、first.func = secondのような構文でも呼べるようになる。
                                // この場合はadd(1, 15)に等しい
}
~~~~~~~~~~~~~~~~~~


プロパティ関数でない関数であっても、プロパティ関数のように呼び出すことは可能です。
しかし、dmdでは`-property`を指定することで、プロパティ関数でない関数がプロパティ関数のような構文で呼ばれている箇所がエラーになります。

構造体やクラスについては後の章で説明しますが、それらのメンバ関数がプロパティ関数の場合にも同様に呼び出すことができます。

~~~~d
import std.stdio;


struct S
{
    // 引数の数は0個
    int foo() @property
    {
        return 1;
    }


    // 引数の数は1個
    int bar(int a) @property
    {
        return a;
    }
}


void main()
{
    S s;

    writeln(s.foo);             // 1
                                // メンバ関数の場合でも、引数の数が0個なら、関数呼び出しのカッコが省略できる
    writeln(s.foo());           // もちろん、カッコ付きで読んでもOK

    writeln(s.bar = 12);        // 12
                                // メンバ関数の場合でも、引数の数が1つだと、さも代入されるかのような構文で呼べる
                                // この場合は、s.bar(12)に等価
}
~~~~~~~~~~~~~~~~~~


### 関数のメモリ安全性

D言語には、
- 未定義動作を引き起こさないこと(<b>メモリ安全性</b>といいます)を保証する
- メモリ安全性を保証できない場合でも、そのようなコードを検証しやすくする

ための仕組みが用意されています。

関数に後述する属性を付けることでこの仕組みを利用することができ、未定義動作が原因の不可解で再現性のないバグを防ぐことができます。  
メモリ安全性についての属性は3つあり、付けられた属性によって、関数を以下のように分類することができます。

+ <b>セーフ関数</b>`@safe`

    <b>セーフ関数</b>(safe function)は、その関数内でのすべての操作がメモリ安全な関数で、未定義動作を引き起こさないことがコンパイラによって保証されます。
    そのため、次のような制約があります。

    - インラインアセンブラは書けない
    - `cast`によって、`const`や`immutable`, `shared`を取り除くことができない
    - `cast`によって、`immutable`や`shared`を付加することができない
    - `cast`によって、ポインタ型`T*`を、`void*`以外の他のポインタ型`U*`へ変換できない
    - `cast`による、ポインタでない型から、ポインタ型へ変換できない
    - ポインタ値の変更(加算, 減算, ...etc)不可
    - ポインタが指している要素以外は触れない(ptr[idx]は不可)
    - ポインタ型を含む`union`は触れない
    - `class Exception`派生でない例外の`catch`ができない
    - システム関数(後述)の呼び出しができない
    - ローカル変数や関数引数へのアドレスの取得ができない
    - `__gshared`な変数を触ることができない

    <small>正確には、以下を参照:  
    [関数#safe-functions - プログラミング言語 D (日本語訳)](http://www.kmonos.net/alang/d/function.html#safe-functions)  
    [Functions#safe-functions - D Programming Language](http://dlang.org/function.html#safe-functions)  
    [SafeD - プログラミング言語 D (日本語訳)](http://www.kmonos.net/alang/d/safed.html)  
    [SafeD - D Programming Language](http://dlang.org/safed.html)</small>  


    セーフ関数はコンパイル時に解析され、セーフ関数であるのにメモリ安全でない操作をしている場合には、コンパイルエラーとなります。

    ~~~~d
    int foo(int* p) /*@safe*/
    {
        return p[1];            // *(p + 1)なので、fooはセーフ関数になれない
    }


    int foo_safe(int* p) @safe
    {
        return p[0];            // *pと等価なのでOK
    }


    int bar(int[] arr) @safe
    {
        size_t idx = 1;
        return arr[idx];        // 配列(スライス)に対するidxアクセスはOK
    }
    ~~~~~~~~~~~~~~~~~~


+ <b>信頼済み関数</b>`@trusted`

    <b>信頼済み関数</b>(trusted function)は、関数内ではメモリ安全ではない操作を行なっているけれども関数全体としてみれば安全であるような関数です。
    信頼済み関数では、操作の静的な制約はありませんが、メモリ安全であることをプログラマが保証しなければいけません。
    このため、関数を定義するプログラマは未定義動作を引き起こさないように注意する必要があります。

    ~~~~d
    int foo(int[] arr) @trusted
    {
        return arr.ptr[arr.length - 1];   // ポインタが指している要素以外に触っているので、fooはセーフ関数になれない
                                // しかし、プログラマが保証するならば、信頼済み関数になれる
    }


    int foo_safe(int* p) @safe
    {
        return p[0];
    }
    ~~~~~~~~~~~~~~~~~~


+ <b>システム関数</b>`@system`

    <b>システム関数</b>(system function)は、`@safe`でも`@trusted`でもない関数です。属性に`@system`を付けることで、システム関数であることを明示することもできます。
    システム関数は、操作の静的な制約がなく、メモリ安全であることを誰も保証してくれないので、これらの関数を定義するときや使用するときには未定義動作を引き起こさないように注意する必要があります。

    ~~~~d
    int foo(){}             // デフォルトではsystem関数
    int hoge() @system {}   // 明示的にsystem関数であることを表す

    int bar() @safe {}      // system関数じゃなくて、safe関数
    int baz() @trusted {}   // system関数じゃなくて、trusted関数
    ~~~~~~~~~~~~~~~~~~


### 純粋関数`pure`

純粋関数とは、その関数が外部に一切の影響を与えないことが静的に保証されている関数です。
つまり、I/O(入出力)は禁止、グローバル変数やネスト関数の場合には外のスコープも触ってはいけません。
もちろん、impureな関数(`pure`でない関数)を呼び出すことはできません。

~~~~d
int globalValue;

immutable int imm;
const int* cptr;

void foo(int x, int y) pure
{
    //globalValue = x;          // NG
                                // グローバル変数の書き換えは不可

    x = imm;                    // OK
                                // immutableなグローバル変数の読み込みは可能

    //x = *cptr;                // NG
                                // constなポインタは、ポインタ値はconstだが、値は変化するので、読み込み不可

    static int z;
    //z = x;                    // NG
                                // static変数の書き換えは不可

    throw new Exception("例外はOK");

    int[] arr = new int[x];     // newはOK
}
~~~~~~~~~~~~~~~~~~


* 純粋性の強弱  
    引数に配列`int[] arr`を持つような純粋関数は外部に一切の影響を与えないと保証できるでしょうか？
    この関数は引数の配列の要素を書き換えることができるので、質問の答えはNOですね。
    このように、純粋関数のうちでも引数の値を書き換えてしまう可能性のある純粋性を、弱い純粋性(weak purity)といいます。
    対して、一切外部に影響を与えないような純粋性を強い純粋性(strong purity)といいます。
    配列やポインタを引数に取っているような関数でも、`const`や`in`によって書き換え不可能なことを明示しておけば、その関数は強い純粋性を示すようになります。

    ~~~~d
    // 弱い純粋性
    void foo(int[] arr) pure
    {
        arr[] = 0;  // arrの中身を書き換え可能
    }

    // 強い純粋性, `const`や`in`などによって、
    // 書き換えできないことを明示しておく。
    void bar(const(int)[] arr) pure
    {
        // arr[] = 0;   // NG
    }
    ~~~~

    強い純粋関数の返り値は常にユニークであるという特徴があります。
    つまり、返り値は外部との関わりを一切持っていないということです。
    この特徴によって、強い純粋関数が返す返り値はすべての修飾子付き型へ暗黙変換可能となります。

    ~~~~d
    // 強い純粋関数
    T[] newArrN(T)(size_t n) pure
    {
        return new T[n];
    }

    void main()
    {
        // sharedやinoutを含むすべての修飾子を付加することが可能
        auto marr = newArrN!int(12);
        const carr = newArrN!int(12);
        immutable iarr = newArrN!int(12);
        shared sarr = newArrN!int(12);
    }
    ~~~~


### 例外を投げない関数`nothrow`

例外についてはまだ説明していませんが、例外とは、プログラムがある処理をしている最中に起こった異常や、その異常を知らせるメッセージのことです。
「例外を投げる」とは、「異常が発生したというメッセージを発行する」ということになります。
例外は`throw ex;`で投げることができ、`catch`されるまで関数を遡っていきます。
`main`関数までさかのぼり、最終的に`catch`されなければプログラムは終了します。

ToDo: [例外の章へ](exception.md)

`nothrow`関数は、そんな例外を絶対に投げないことが静的に保証されている関数です。
また、例外は関数を貫いて伝搬するため、`nothrow`関数内では`nothrow`関数しか呼ぶことが出来ません。

~~~~d
void bar(){}                                // nothrow関数でない

void foo() nothrow
{
    //throw new Exception("exception");     // nothrow関数内では例外を投げれない
    //bar();                                // barはnothrow関数でないので、呼べない
}
~~~~

例外を投げる可能性のある操作を関数内部に持っていても、その操作が`try`文中にあり、例外が関数外部にもれないのであれば構いません。

~~~~d
void bar(){}                                // nothrow関数でない

void foo() nothrow
{
    try{
        throw new Exception("exception:");  // tryの中にあるのでOK
        bar();                              // 同上
    }
    catch(Exception ex){}
}
~~~~

ちなみに、整数の0除算や配列の範囲外参照, `assert`の失敗では、すべてエラーが投げられますが、これは例外ではないので、`nothrow`関数内でこれらの操作を行うことは可能です。

~~~~d
void foo() nothrow
{
    throw new Error("error");               // OK
                                            // 例外じゃなくてエラー

    int[] arr;
    auto b = arr[1];                        // エラーが投げられるが、例外でないのでOK

    b /= 0;                                 // エラーが投げられるが、例外でないのでOK
}
~~~~


### UDA(User Defined Attribute)
    
ToDo: [UDAの章へ](uda.md)


### `const`, `immutable`, `inout`, `abstract`, `final`

これらの属性は構造体`struct`やクラス`class`のメンバー関数でのみ使用することができます。

ToDo: [共用体の章へ](union.md)
ToDo: [構造体の章へ](struct.md)
ToDo: [クラスの章へ](class.md)


## 関数オーバーロード(多重定義, overload)

D言語の関数は、引数が違えば、同じ関数名の関数を宣言することができます。

たとえば、C言語には「データをフォーマット指定して文字列に書き込みを行う」関数が`stdio.h`に以下のように複数あります。
それぞれは引数の型だけがことなるだけで、それらの関数の意味はすべて同じです。
しかし、C言語には関数のオーバーロードという機能がないので、各関数の名前が被ってはいけないという言語仕様上の制約があります。
ですから、`sprintf`系の関数では、その引数に応じて、先頭に`v`や`n`を付けて呼び出す関数を区別してやる必要があります。

~~~~c
// Cでのsprintf系
int sprintf(char *str, const char *format, ...);
int snprintf(char *str, size_t n, const char *format, ...);
int vsprintf(char *str, const char *format, va_list arg);
int vsnprintf(char *str, size_t n, const char *format, va_list arg);
~~~~~~~~~~~~~~~~~~

逆に、関数オーバーロードの機能があるD言語では、これらの関数は次のように、すべて`sprintf`という関数名で宣言することが可能です。

~~~~d
// もし、Dでsprintf系をつくるならば
int sprintf(char* str, const char* format, ...);
int sprintf(char* str, size_t n, const char* format, ...);
int sprintf(char* str, const char* format, void* argptr, TypeInfo[] arguments);
int sprintf(char* str, size_t n, const char* format, void* argptr, TypeInfo[] arguments);
~~~~~~~~~~~~~~~~~~

呼び出すときは引数にもっともマッチした関数が呼ばれます。
「もっともマッチした関数」とは、以下の優先順位でもっとも高い関数です。

1. 完全にマッチしている
2. `const`付きでマッチしている
3. 暗黙の型変換によるマッチ
4. マッチしていない

~~~~d
import std.stdio;

void foo(int){ writeln("int"); }
void foo(in int){ writeln("in int"); }      // in は const scope のこと

void bar(in int){ writeln("in int"); }
void bar(long){ writeln("long"); }

void hoge(float){ writeln("float"); }
void hoge(double){ writeln("double"); }

void main()
{
    foo(1);                 // int
    foo(cast(const)1);      // in int

    bar(1);                 // in int
                            // 暗黙変換よりもconstは優先される
    bar(cast(long)1);       // long

    hoge(1.0L);           // コンパイルエラー:realはfloat, doubleの両方に等しく暗黙変換可能
    /*
    example.d(21): Error: function foo.hoge called with argument types:
        ((real))
    matches both:
        example.d(9): foo.hoge(float _param_0)
    and:
        example.d(10): foo.hoge(double _param_0)
    */
}
~~~~~~~~~~~~~~~~~~


同一名称の関数が異なるモジュールに属している際には、コンパイラによる最適な関数の選択方法は複雑になります。
関数の呼び出しがあると、コンパイラはまずはモジュール毎にその関数の<b>オーバーロード集合</b>(overload set)を形成します。
次のステージでは、それぞれのモジュールでもっともマッチする関数を選択します。
前ステージでのマッチする関数の合計がただ一つの場合、つまりは、ただひとつのモジュールだけしかマッチしなければ、そのマッチした関数が呼ばれます。
そうでなければ(複数のモジュールでマッチしたのなら)、コンパイルエラーとなります。

~~~~d
// foo1.d
import std.stdio;

void foo(int){ writeln("foo1.foo(int)"); }
void foo(in int){ writeln("foo1.foo(in int)"); }
~~~~~~~~~~~~~~~~~~

~~~~d
// foo2.d
import std.stdio;

void foo(long){ writeln("foo2.foo(long)"); }
void foo(real){ writeln("foo2.foo(real)"); }
~~~~~~~~~~~~~~~~~~

~~~~d
// main.d

import foo1, foo2;

void main()
{
    //foo(1);       // Error: foo2.foo at foo2.d(4) conflicts with foo1.foo at foo1.d(4)
                    // モジュールfoo1ではfoo(int)が、foo2ではfoo(long)がマッチし、
                    // 結果的に2つ以上のモジュールでマッチしたのでエラー

    foo(long.max);  // foo2.foo(long)
    foo(1.0);       // foo2.foo(real)
                    // 上記2つともに、モジュールfoo2でのみマッチする
}
~~~~~~~~~~~~~~~~~~


もし、`foo1`と`foo2`に分けられたオーバーロード集合を一つに結合したい場合には、次のように`alias`を使います。

~~~~d
import foo1, foo2;

// モジュールfoo1とfoo2の、fooに関するオーバーロード集合を一つに結合する
alias foo = foo1.foo;
alias foo = foo2.foo;

void main()
{
    foo(1);         // foo1.foo(int)
    foo(long.max);  // foo2.foo(long)
    foo(1.0);       // foo2.foo(real)
}
~~~~~~~~~~~~~~~~~~


オーバーロード集合を結合せずとも、明示的に所属するモジュールを指定してやることで解決します。

~~~~d
import foo1, foo2;

void main()
{
    foo1.foo(1);         // foo1.foo(int)
    foo2.foo(long.max);  // foo2.foo(long)
    foo2.foo(1.0);       // foo2.foo(real)
}
~~~~~~~~~~~~~~~~~~


## ローカル`static`変数

関数内には`static`と付いた変数を宣言することができます。
静的変数は「その関数だけが触れるグローバル変数」となります。

~~~~d
void foo()
{
    static int cnt;

    writefln("%s回目の呼び出し", ++cnt);
}


void main()
{
    foo();          // 1回目の呼び出し
    foo();          // 2回目の呼び出し
    foo();          // 3回目の呼び出し
    foo();          // 4回目の呼び出し
}
~~~~~~~~~~~~~~~~~~

ローカル`static`変数を初期化するには、初期化値がコンパイル時定数である必要があります。
つまり、実行時に決まるような値で初期化できません。
このような場合は`static bool firstCall`というような変数を用いて、初期化しましょう。

~~~~d
string foo(string line)
{
    static bool firstCall = true;       // リテラルはコンパイル時定数
    static int hold/* = line*/;         // ローカル変数や仮引数はコンパイル時定数ではない

    // 第一回目の関数呼び出しのときにのみ中の文が実行される
    if(firstCall){
        hold = line;
        firstCall = !firstCall;
    }

    return hold;
}
~~~~~~~~~~~~~~~~~~

[Goto: 問題5 「Grand Total」](#Q5)  
[Goto: 問題6 「Tagged Grand Total」](#Q6)  


## ネスト関数

なんと関数内には関数を記述できます！
また、その関数は外側の関数のシンボルを参照することができます。
もし、ネスト関数が`static`であれば、その外部の関数の`static`なものしか参照できません。

~~~~d
void main()
{
    int a;
    static int s;

    void inc(){ ++a; }

    static void inc_static(){ ++s; }    // staticなものだけ触れる

    writeln(a);         // 0
    inc();
    inc();
    writeln(a);         // 2
}
~~~~~~~~~~~~~~~~~~


## 関数ポインタ

関数を変数に代入して持ち運べたり、違う関数に渡せると嬉しくないですか？
実は、関数ポインタ型というデータ型が存在し、この型へ関数へのポインタを格納しておけば、関数への参照を持ち運ぶことができます。
関数ポインタの型は、`ReturnType function(ParameterList)`となります。

~~~~d
void foo(int a){ writeln("foo !!!"); }
void bar(int b){ writeln("bar !!!"); }

void main()
{
    // intを受け取る関数を参照する型
    void function(int) fptr = &foo;

    fptr(0);                    // foo !!!

    fptr = &bar;
    fptr(0);                    // bar !!!
}
~~~~~~~~~~~~~~~~~~

関数ポインタを使用すれば、関数を値として扱えます。
そのため、条件によって実行する関数を変えたり、関数に関数を渡せたり、関数から関数を返すことも作成可能です。

~~~~d
import std.stdio;

int sum(int a, int b){ return a + b; }
int prd(int a, int b){ return a * b; }


/// std.algorithm.reduceと同じような関数
int reduce(int ini, int[] arr, int function(int, int) f)
{
    while(arr.length){
        ini = f(ini, arr[0]);
        arr = arr[1 .. $];
    }

    return ini;
}


// 状態stateによって、返す関数を変える関数
int function(int, int) getFunc(bool state)
{
    if(!state)      // falseのとき
        return &sum;
    else
        return &prd;
}


void main()
{
    writeln(reduce(0, [1, 2, 3, 4], &sum));     // 10
                                                // 総和

    writeln(reduce(1, [1, 2, 3, 4], &prd));     // 24
                                                // 総乗

    writeln(getFunc(false) == &sum);
    writeln(getFunc(true) == &prd);
}
~~~~~~~~~~~~~~~~~~


すべての関数に対して、`&<function>`が関数ポインタを返すわけではありません。
非`static`なネスト関数やメンバ関数(メソッド)についてはデリゲートというものを返します。


## デリゲート`delegate`

関数ポインタを使えば、たしかに関数から関数を返すことは可能です。
では、引数`int a`を取り、「引数`int b`を取って、`a`と`b`の和を返す関数」を返す関数`accum`を作れるでしょうか？
つまり、次のようなコードを満たす関数です。

~~~~d
// accum関数は引数を一つ取って、関数を返す
auto func1 = accum(5);
writeln(func1(3));          // 8
                            // 5 + 3

auto func2 = accum(8);
writeln(func2(12));         // 20
                            // 12 + 8

writeln(func1(3));          // 8
                            // 5 + 3
                            // func1の状態は、func2に影響されない
~~~~~~~~~~~~~~~~~~

グローバル変数に最初の引数の値を保存すれば実現できそうですが、`func1`の状態が`func2`に影響されてしまします。


~~~~d
import std.stdio;


int a;  // accumで、第一引数を保存する変数


auto accum(int a)
{
    // グローバルなaにローカルなaを代入
    .a = a;

    // accumImplへの関数ポインタを返す
    return &accumImpl;
}


int accumImpl(int b)
{
    // グローバルなaとローカルのbの和を返す
    return .a + b;
}


void main()
{
    // accum関数は引数を一つ取って、関数を返す
    auto func1 = accum(5);
    writeln(func1(3));          // 8
                                // 5 + 3

    auto func2 = accum(8);
    writeln(func2(12));         // 20
                                // 8 + 12

    writeln(func1(3));          // 11
                                // 5 + 3 = 8 なのに、func2の影響を受けて、
                                // 8 + 3 = 11 になってしまった。
}
~~~~~~~~~~~~~~~~~~

グローバル変数の代わりに`static`変数を使ってもこのような関数は作れないのですが、では関数のローカル変数を触れるネスト関数を作り、その関数ポインタを返すのはどうでしょう？この実装だと、仕様を満たす関数になります。

~~~~d
auto accum(int a)
{
    int accumImpl(int b)
    {
        return a + b;
    }

    return &accumImpl;
}
~~~~~~~~~~~~~~~~~~

実は、`accum`は関数ポインタを返すのではなくて、<b>デリゲート</b>(delegate)というものを返しています。
試しに、返り値の推論をやめて`int function(int) accum(int a)`と書けばコンパイルエラーになりますね。

~~~~
Error: cannot implicitly convert expression (&accumImpl) of type int delegate(int b) to int function(int)
~~~~

コンパイラがいうには、「`(&accumImpl)`は`int delegate(int)`型であって、`int function(int)`型には暗黙変換できませんよ」ということなのです。
`int delegate(int)`型は`int`を受け取って`int`を返すデリゲート型のことです。

デリゲートは、関数ポインタと、それが作られた環境についての情報(スタックポインタ)を併せて持っています。
そのため、`accumImpl`から作られたデリゲートは`accum`の`a`の値を参照できるのです。
この`a`の寿命は、`accum`関数が終了しても継続し続け、`accumImpl`から作られたデリゲートや、そのデリゲートのコピーがすべて無くなったら、次のガベージコレクタの回収時に回収されます。  
<small>(このようなデリゲートをクロージャ(closure)と呼びます。)</small>

`accum`を2回呼び出し、その2つの返り値のデリゲートが持っているスタックポインタを比較すると、それらは異なります。
つまり、`accum`の環境(スタック)の複製をデリゲートは持ちます。
このような性質により、`accum`を何回呼び出したとしてもメモリがある限り、返されるデリゲートは独立します。

「`A`型を受け取り、`B`型を返すデリゲート」の型は`B delegate(A)`となります。

関数オブジェクト(関数ポインタや、`opCall`の定義
されている構造体やクラス)をデリゲートに変換したい場合には、`std.functional.toDelegate`を使います。

~~~~d
import std.functional;

int foo(int a){ return a; }

void main()
{
    int delegate(int) dlg = toDelegate(&foo);   // 関数ポインタ -> デリゲート
    writeln(dlg(3));                            // 3
}
~~~~~~~~~~~~~~~~~~

[Goto: 問題7 「カウンター」](#Q7)  


## 関数のリテラルとラムダ

先の例では、関数内にネスト関数を宣言し、そのネスト関数から作られるデリゲートを返していました。
しかし、関数(関数ポインタやデリゲート)がリテラルとしてソースコード中に表現できるなら、わざわざネスト関数を宣言する必要はありませんね。

今回は先ほどの`accum`をなるべく短く実装していきましょう。
ネスト関数を使った`accum`を以下にもう一度示しておきます。

~~~~d
int delegate(int) accum(int a)
{
    int accumImpl(int b)
    {
        return a + b;
    }

    return &accumImpl;
}
~~~~~~~~~~~~~~~~~~

まず、`accumImpl`をリテラルで表現してみると次のようになります。

~~~~d
int delegate(int) accum(int a)
{
    return delegate int(int b){ return a + b; };
}
~~~~~~~~~~~~~~~~~~

行数が極端に減りましたね。
もし、関数ポインタを返したいなら、`delegate`を`function`にしますが、関数ポインタでは外部の環境(`a`)へアクセスできないので、今回の場合は関数ポインタにできません。

リテラル表現では、`delegate`や返り値の`int`を省くことができます。
すると、次のようにさらに短くなります。

~~~~d
int delegate(int) accum(int a)
{
    return (int b){ return a + b; }
}
~~~~~~~~~~~~~~~~~~

このようなリテラルの場合には、関数ポインタかデリゲートかどうかが推論されます。
今回の場合には、外部の`a`をリテラル内で触っているので、もちろんデリゲートになります。

さらに、ラムダという記法を用いると、もっと短くなります。

~~~~d
int delegate(int) accum(int a)
{
    return (int b) => a + b;
}
~~~~~~~~~~~~~~~~~~

さて、最終の仕上げですが、引数の型も推論してもらいましょう。

~~~~d
int delegate(int) accum(int a)
{
    return b => a + b;
}
~~~~~~~~~~~~~~~~~~

おまけとして、`accum`をもっと短くすると、次のような面白い書き方になります。

~~~~d
enum accum = (int a) => (int b) => a + b;
~~~~~~~~~~~~~~~~~~

もっとも短い関数を表すリテラルは`{}`でしょう。
次いで`{;}`、`(){}`になります。

~~~~d
void function() f1 = {},
                f2 = {;},
                f3 = (){};

void delegate() d1 = {},
                d2 = {;},
                d3 = (){};
~~~~~~~~~~~~~~~~~~

ラムダでも`function`や`delegate`の指定ができます。

~~~~d
int delegate(int) accum(int a)
{
    return delegate (int b) => a + b;
}
~~~~~~~~~~~~~~~~~~


`pure`や`nothrow`, `@safe`などの関数属性は、リテラル表現では推論されますが、次のように指定することも可能です。

~~~~d
int delegate(int) accum(int a)
{
    return delegate int(int b) nothrow @safe { return a + b; };
    return delegate (int b) nothrow @safe { return a + b; };
    return (int b) nothrow @safe { return a + b; };
    return (int b) nothrow @safe => a + b;
    return (b) nothrow @safe => a + b;
}
~~~~~~~~~~~~~~~~~~


セーフ関数の中でメモリセーフでない関数や機能を使いたい場合には、`@trusted`付きのリテラルを使うのが習慣のようです。

~~~~d
int unsafe();           // セーフでない操作

void foo() /*@safe*/    // 関数全体でみるとメモリ安全なのに、unsafeがあるから@safeになれない
{
    //... unsafeの操作がメモリ安全になるような操作

    auto a = unsafe();
    
    //... unsafeの操作がメモリ安全になるような操作
}


void bar() @safe        // メモリ安全でない操作を行ってても、関数全体でみればメモリ安全だからOK
{
    //... unsafeの操作がメモリ安全になるような操作

    auto a = () @trusted => unsafe();

    //... unsafeの操作がメモリ安全になるような操作
}
~~~~


[Goto: 問題8 「関数型スタイルなD」](#Q8)  


## UFCS(Uniform Function Call Syntax)

関数は通常`func(a, b, c)`のように呼び出しますが、UFCSという糖衣構文を使うことで、`a.func(b, c)`というように、`func`が`a`のメンバ関数であるかのように記述できます。
たとえば、`std.conv.to`は、様々な型から他の型への変換を提供しますが、`to!string(a)`と書くよりも、`a.to!string()`の方がより英文みたいになってわかりやすくなります。
さらに、`f1(f2(f3(a)))`と書くよりも、`a.f3().f2().f1()`と書くほうが、`a`がどのような順番でどのような処理を受けるかがすぐにわかります。

スライスがレンジとして機能する理由は、UFCSによって`std.array`の関数が`arr.front`, `arr.popFront()`, `arr.empty`というように呼び出せるからです。

もちろん、`a.f()`の`()`はプロパティの記法によって省略できるので、`a.f3.f2.f1`とも書けます。
素晴らしいですね。

~~~~d
import std.algorithm;
import std.array;
import std.random;
import std.range;
import std.stdio;


void main()
{
    auto gen = Random(unpredictableSeed),   // 乱数生成器を作る
         r = iota(100).randomCover(gen);    // 0 ~ 99までをランダムな順番にする。

    // ランダムに並んだ0 ~ 99のうち、偶数のみを抜き取り(filter!"!(a&1)"), 文字列に変換(map!"a.to!string()")して、それを表示
    writeln(r.filter!"!(a&1)"().map!"a.to!string()"());


    int a = 5;

    // 狂気の如く連ねることも可能
    a.identity.identity.identity.identity.identity.identity.identity.writeln;
}


// そのまま返す関数
auto ref T identity(T)(auto ref T a)
{
    return a;
}
~~~~~~~~~~~~~~~~~~


## CTFE(Compile Time Function Execution)

関数は、ある程度の条件を満たせばコンパイル時に実行することができます。
コンパイル時とは、そのままの意味で、実行時ではなくてコンパイルしている段階ということです。
C++のテンプレートを用いたテンプレートメタプログラミング(TMP)や、`constexpr`を使用した経験がある人にとっては、D言語のCTFEは素晴らしい機能だとわかるでしょう。
コンパイル時プログラミングの経験がない人にとっては、コンパイル時に関数が走ってなにが嬉しいのだろうと思うでしょう。

もし、定数を事前に(コンパイル時に)計算できるなら？
もし、コンパイル時に関数がプログラムを生成してくれたら？

D言語では、CTFE以外にも快適なコンパイル時プログラミングを支援する機能が揃っています。

さて、話はCTFEに戻って、関数がCTFEableであるためには、以下の制約を満たす必要があります。
これらの制約はそのうち緩和される可能性があります。

+ 関数本体がD言語のソースコードとしてある
+ 関数の中で実行する式や文では以下の操作は行えない(実行されない式や文が、以下の操作を行うかもしれなくても、OK)
    - グローバル変数や、ローカルstatic変数の参照
    - インラインアセンブラ(`asm`文)
    - プラットフォーム依存なキャスト(`int[]`から`float[]`や、エンディアン依存なキャスト)
    - CTFEableでない関数の呼び出し
    - `delete`文

特別なシンボルとして`__ctfe`というものがあり、CTFE時には`true`となり、実行時には`false`となります。

~~~~d
import std.regex;
import std.stdio;


pragma(msg, ctEvaluated());                     // true


/// コンパイル時と、実行時で値が変わる関数。trueならコンパイルに評価された
bool ctEvaluated()
{
    if(!__ctfe){
        int[] arr = new int[10];
        delete arr;                 // コンパイル時には絶対に実行されないのでOK
    }

    return __ctfe;
}


void main()
{
    enum enumValue = ctEvaluated();
    immutable immValue = ctEvaluated();
    const cntValue = ctEvaluated();
    bool mutValue = ctEvaluated();

    static staticValue = ctEvaluated();

    writeln("enum:          ", enumValue);      // true
    writeln("immutable:     ", immValue);       // false
    writeln("const:         ", cntValue);       // false
    writeln("local mutable: ", mutValue);       // false
    writeln("local static:  ", staticValue);    // true
}
~~~~~~~~~~~~~~~~~~


## 問題

[解答](answer.md#function)

+ <a name = "Q1">問題1 「readIntを実装しよう」</a>  

    ユーザーが入力する数字を読み取って、`int`型で返す関数`readInt`を書いてください。
    `readInt`の引数や返り値の型は以下のとおりです。

    ~~~~d
    int readInt();
    ~~~~~~~~~~~~~~~~~~

    ヒント  
    - `std.conv.to!int`  
    - `std.stdio.readln`  
    - `std.string.chomp`  


+ <a name = "Q2">問題2 「sumを実装しよう」</a>  

    配列`int[]`を受け取って、その総和を返す関数`sum`を書いてください。
    `sum`の引数や戻り値の型は以下のとおりです。

    ~~~~d
    int sum(int[]);
    ~~~~~~~~~~~~~~~~~~


+ <a name = "Q3">問題3 「コンパイルできない！」</a>

    次のプログラムをコンパイルしてみると、`Deprecation: non-final switch statement without a default is deprecated`というメッセージと共にコンパイルエラー
    となってしまいます。
    エラー文を読んでみると、9行目の普通の`switch`文で、`default`が抜けているようです。
    `idx`の値は`1, 2, 3`しか受け取らないと仮定し、すべての間違いを修正して、コンパイルできるようにしてください。

    ~~~~d
    import std.stdio;

    int g1 = 1,
        g2 = 10,
        g3 = 20;


    int getGlobalValue(size_t idx)
    {
        switch(idx){
            case 1:
                return g1;

            case 2:
                return g2;

            case 3:
                return g3;
        }
    }


    void main()
    {
        writeln(getGlobalValue(1));
        writeln(getGlobalValue(10));
        writeln(getGlobalValue(20));
    }
    ~~~~~~~~~~~~~~~~~~


+ <a name = "Q4">問題4 「helpメッセージを表示せよ」</a>

    コンソールでコマンドを叩くときに、コマンドライン引数に`-h`とか`--help`を入れると、そのコマンドに対するメッセージがだいたい出力されますよね。
    試しに`dmd --help`と打ってみると、dmdのコマンド引数の一覧が出力されると思います。(`dmd`の場合は、`dmd`だけで表示されるのですが)

    以下に示すプログラムは、`add --a=12 --b=13`というように呼び出すと`12 + 13 = 15`と表示されるプログラムです。
    また、`getopt(...);`後の変数`h_sw`には、コマンド引数に`-h`や`--help`が出現したかどうかが入っています。
    (出現したら`true`)

    このプログラムを少し書き換えて、`-h`や`--help`がコマンド引数に現れた場合には`writeln(appInfo);`をして即座にプログラムが終了するようにしてください。

    ~~~~d
    import std.getopt;
    import std.stdio;


    immutable appInfo = `example:
    $ add --a=12 --b=13
    a + b = 25

    $ add --b=1, --a=3
    a + b = 4
    `;


    void main(string[] args)
    {
        int a, b;
        bool h_sw;              // argsに-h, --helpが出現したかどうか

        getopt(args,
            "a", &a,
            "b", &b,
            "h|help", &h_sw);

        writeln("a + b = ", a + b);
    }
    ~~~~~~~~~~~~~~~~~~


+ <a name = "Q5">問題5 「Grand Total」</a>

    関数を呼び出す毎に過去と今の`int`型引数の総和を返す関数`gt`を作ってください。
    つまり、次のような関数です。

    ~~~~d
    writeln(gt(10));            // 10
    writeln(gt(1));             // 11
    writeln(gt(9));             // 20
    writeln(gt(8));             // 28

    writeln(gt(5, true));       // 5    第二引数をtrueにすると、0になる
    writeln(gt(10));            // 10
    ~~~~~~~~~~~~~~~~~~


+ <a name = "Q6">問題6 「Tagged Grand Total」</a>

    [Q5](#Q5)とほとんど同じですが、今回の関数は新たにもう一つ引数として`string`型をとります。
    この引数`string`を「タグ」と呼ぶことにしましょう。
    `taggedGt`関数を作ってもらうわけですが、先ほどの`gt`は関数`gt`1つにつき、同時に合計が計算できるのは1つでした。
    `taggedGt`では、タグを指定することで、同時に複数の合計を計算できるようにしてください。

    ~~~~d
    writeln(taggedGt("A", 10));             // 10
    writeln(taggedGt("B", 1));              // 1
    writeln(taggedGt("C", 3));              // 3

    writeln(taggedGt("A", 100));            // 110
    writeln(taggedGt("B", 10));             // 11
    writeln(taggedGt("C", 3));              // 6

    writeln(taggedGt("A", 3, true));        // 3    第3引数がtrueでクリア

    writeln(taggedGt("B", 2, true, true));  // 2    第4引数がtrueなら、そのタグの終了

    writeln(taggedGt("A", 3));              // 6
    writeln(taggedGt("B", 4));              // 4
    writeln(taggedGt("C", 5));              // 11

    taggedGt("A", 0, true, true);           // 数え上げ終わりのときは、必ず第4引数をtrueにする
    taggedGt("B", 0, true, true);           // 同上
    taggedGt("C", 0, true, true);           // 同上
    ~~~~~~~~~~~~~~~~~~

    ヒント:
    - 連想配列
    - 第4引数がtrueのときは、連想配列からそのタグを削除


+ <a name = "Q7">問題7 「カウンター」</a>

    次のようなソースコードを満たす、`createCounter`を実装してください。

    ~~~~d
    auto cnt1 = createCounter();

    writeln(cnt1());             // 1
    cnt1();
    cnt1();
    writeln(cnt1());             // 4

    auto cnt2 = createCounter();

    writeln(cnt2());            // 1
    writeln(cnt1());            // 5
    writeln(cnt2());            // 2
    ~~~~~~~~~~~~~~~~~~


+ <a name = "Q8">問題8 「関数型スタイルなD」</a>

    関数を関数に渡して処理の内容を変えたりするという技法は、関数型プログラミングというものに属するそうです。
    D言語の標準ライブラリPhobosは、基本的にこの技法をベースにして作成されています。

    例えば、`std.algorithm.map`を見てみましょう。

    ~~~~d
    import std.algorithm,
           std.conv,
           std.stdio;

    void main(){
        auto r = [0, 1, 2];

        writeln(r.map!(a => a + 1)());          // [1, 2, 3]
        writeln(r.map!(a => a.to!string()));    // ["0", "1", "2"]
    }
    ~~~~~~~~~~~~~~~~~~

    `map!(a => a + 1)`というシンタックスは見慣れませんね。
    (まだ説明してないからなのですが。)
    簡単に説明すると、`map`関数にコンパイル時引数として、ラムダ`a => a + 1`を渡しているという意味です。

    `r.map!(a => a + 1)()`は`r`の全ての要素に1足すという意味で、`r.map!(a => a.to!string())`は`r`のすべての要素を文字列表現に変換するという意味です。

    `filter`と`reduce`という素晴らしいものが`std.algorithm`にあるのですが、Phobosのドキュメントを読んで、次の関数を作ってください。

    - 配列`int[] arr`を受け取って、`arr`の要素のうち、偶数の要素の総和を返す関数`sumOfEven`
    - 配列`int[] arr`と`int needle`を受け取って、`arr`の中で最も`needle`に近い値を返す関数`getApprxEqElm`

    Phobosのドキュメント:
    - filter: [英語](http://dlang.org/phobos/std_algorithm.html#filter), [日本語](http://www.kmonos.net/alang/d/phobos/std_algorithm.html#filter)
    - reduce: [英語](http://dlang.org/phobos/std_algorithm.html#reduce), [日本語](http://www.kmonos.net/alang/d/phobos/std_algorithm.html#reduce)


+ 問題募集中


## 終わりに

実はこの関数の章は、文章量では、他の章に対して3倍(対：式と演算子)～15倍(対：ポインタ)もの量を誇っています。
それほど関数というのは複雑なのです。
ですが、これからは嫌というほど書いていくことになるので、自然と身につくはずです。

さて、次は「メイン関数」について説明します。


## キーワード

+ 関数(function)
+ 引数(argument, parameter)
    - 仮引数(parameter)
    - 実引数(argument)
+ 戻り値, 返り値(return value)
+ 関数本体
+ 関数プロトタイプ
+ `return`文
+ `assert(0);`
+ 仮引数のデフォルト値(parameter's default value)
+ 仮引数の記憶域クラス(parameter storage class)
    - `in`
    - `out`
    - `ref`
    - `lazy`
    - `const`
    - `immutable`
    - `shared`
    - `inout`
    - `scope`
    - (`auto ref`)
+ 可変個引数関数(variadic function)
+ `auto`関数, `auto ref`関数
+ 関数属性(function attribute)
    - `@property`
    - `@safe`, `@trusted`, `@system`
    - `pure`
    - `nothrow`
    - UDA(User Defined Attribute)
    - `const`, `immutable`, `inout`, `abstract`, `final`
+ 関数オーバーロード(overload)
    - オーバーロード集合(overload set)
+ ローカル`static`変数(local static variable)
+ ネスト関数(nested function)
+ 関数ポインタ(function pointer)
+ デリゲート(delegate)
+ ラムダ(lambda, λ)
+ UFCS(Uniform Function Call Syntax)
+ CTFE(Compile Time Function Execution)
+ 関数型プログラミング(functional programming)


## 仕様

+ 関数: [英語](http://dlang.org/function.html), [日本語](http://www.kmonos.net/alang/d/function.html)
