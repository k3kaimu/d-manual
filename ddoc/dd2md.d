/**
dd(Ddoc)ファイルをmd(markdown)形式に変換するスクリプト

dd2md (input.dd) (output.md)
    (input.dd): 入力のddファイル
    (output.md): 出力のmdファイル. 引数として与えられなければinput.mdとなる

Examples:
----
./dd2md hello_world.dd
./dd2md function.dd function_dd.md
----
*/

import std.algorithm;
import std.array;
import std.ascii;
import std.conv;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;
import std.random;
import std.regex;


void main(string[] args)
{
    immutable input = args[1],
              inputBase = input.baseName(),
              output = (args.length > 2) ? args[2] : (input.stripExtension() ~ ".md"),
              rndStr = rndGen.front.to!string(),
              inputTemp = tempDir ~ inputBase.stripExtension() ~ "_" ~ rndStr ~ ".dd",
              markdownDdocPath = "markdown.ddoc",
              dmdOutputFileName = "dmdoutput_" ~ rndStr,
              dmdOutputFilePath = tempDir ~ dmdOutputFileName;

    std.file.write(inputTemp, std.file.readText(input).replace(regex(`^---+`, "gm"), "$$(IDENTITY $0)"));
    scope(exit) std.file.remove(inputTemp);

    // dmdでddからmdファイルの生成
    auto app = appender!string();
    app.formattedWrite("dmd -c -o- -D %s %s -Df%s", markdownDdocPath, inputTemp, dmdOutputFilePath);
    executeShell(app.data);
    scope(exit) std.file.remove(dmdOutputFilePath);

    // 出力されたファイルの<(&lt;), >(&gt;), &(&amp;)を置換し、そのままターゲットに出力
    std.file.write(output, std.file.readText(dmdOutputFilePath).replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&").find('\n').find!(a => !a.isWhite)());
}