# 条件分岐


## 文のいろいろ

復習しますと、文というのはD言語の小さな単位です。
`<expr>;`のように、式の後に`;`をつけると、それは「式`<expr>`を評価する」という文になりますし、
`{`と`}`の間に複数の分を記述すれば、「複数の文を順番に実行する」という文になります。
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
`readln().chomp()`となっているのは改行文字を消すためで、なぜこのように書けるかというと、UFCS(Uniform Function Call Syntax)のおかげだと前回説明しましたね。

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
たとえば数値型であれば、非ゼロな値は`true`となります。
文字列型だったら、文字列の長さが0であれば`false`になります。
その他、たくさんの型は`bool`型に暗黙変換されます。

~~~~d
int a = -12;            //マイナスも非ゼロなのでtrue
string str = "";

if(a)
    writeln("aは0以外");

if(str)
    writeln("strは空でない");
else
    writeln("strは空である");
~~~~


## if(宣言)な文

string型の値が、文字列の長さが非ゼロであれば`true`となるという特性を利用して、次のプログラムを書きたいことがあります。

~~~~d
string str = func();

if(str)
    writeln(str);
else
    writeln("空");
~~~~

プログラムの説明は、いい練習問題になるので省略しますが、
このようにstrを宣言して、`if`文中で使いたい場合には次のようなことができます。

~~~~d
if(string str = func())
    writeln(str);
else
    writeln("空");
~~~~

なにが嬉しいかというと、`str`の使用出来る範囲が`if`文中だけになることが嬉しいのです。
このうれしさはプログラムをバリバリ書けるようになってくると実感します。

ちなみに、`else`節では`str`は使えません。


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


## 問題

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