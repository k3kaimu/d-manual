/**
dd(Ddoc)ファイルをmd(markdown)形式に変換するスクリプト

dd2md (input.dd) (output.md)
    (input.dd): 入力のddファイル(Ddoc) 
*/

import std.array;
import std.conv;
import std.file;
import std.path;
import std.process;
import std.stdio;
import std.random;
import std.format;


enum markdown_ddoc = 
`B =     **$0**
I =     *$0*
S =     ~~$0~~

OL_1 =    <ol type="1">$0</ol>
OL_a =  <ol type="a">$0</ol>
OL_A =  <ol type="A">$0</ol>
OL_i =  <ol type="i">$0</ol>
OL_I =  <ol type="I">$0</ol>
UL_none = <ul style="list-style-type: none">$0</ul>
UL_disc = <ul style="list-style-type: disc">$0</ul>
UL_circle = <ul style="list-style-type: circle">$0</ul>
UL_square = <ul style="list-style-type: square">$0</ul>
LINK =  [$0]($0)
LINK2 = [$+]($1)
ANCHOR = <a name = "$1">$+</a>
D_CODE =
~~~~d
$0
~~~~
DDOC = $(BODY)
IDENTITY = $0`;


void main(string[] args)
{
    immutable input = args[1],
              output = (args.length > 2) ? args[2] : (input.stripExtension() ~ ".md"),
              tempDir = .tempDir() ~ std.path.dirSeparator,
              rndStr = rndGen.front.to!string(),
              markdownDdocPath = tempDir ~ "markdown_" ~ rndStr ~ ".ddoc",
              dmdOutputFileName = "dmdoutput_" ~ rndStr,
              dmdOutputFilePath = tempDir ~ dmdOutputFileName;

    // markdown.ddocをtempDirに出力
    std.file.write(markdownDdocPath, markdown_ddoc);

    // dmdでddからmdファイルの生成
    auto app = appender!string();
    app.formattedWrite("dmd -c -o- -D %s %s -Df%s", markdownDdocPath, input, dmdOutputFilePath);
    executeShell(app.data);

    // 出力されたファイルの<(&lt;), >(&gt;), &(&amp;)を置換し、そのままターゲットに出力
    std.file.write(output, std.file.readText(dmdOutputFilePath).replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&"));

    // いらないファイルの削除
    std.file.remove(markdownDdocPath);
    std.file.remove(dmdOutputFilePath);
}