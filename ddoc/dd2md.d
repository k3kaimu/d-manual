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

import std.array;
import std.conv;
import std.file;
import std.path;
import std.process;
import std.stdio;
import std.random;
import std.format;


void main(string[] args)
{
    immutable input = args[1],
              output = (args.length > 2) ? args[2] : (input.stripExtension() ~ ".md"),
              tempDir = .tempDir() ~ std.path.dirSeparator,
              rndStr = rndGen.front.to!string(),
              markdownDdocPath = "markdown.ddoc",
              dmdOutputFileName = "dmdoutput_" ~ rndStr,
              dmdOutputFilePath = tempDir ~ dmdOutputFileName;

    // dmdでddからmdファイルの生成
    auto app = appender!string();
    app.formattedWrite("dmd -c -o- -D %s %s -Df%s", markdownDdocPath, input, dmdOutputFilePath);
    executeShell(app.data);
    scope(exit) std.file.remove(dmdOutputFilePath);

    // 出力されたファイルの<(&lt;), >(&gt;), &(&amp;)を置換し、そのままターゲットに出力
    std.file.write(output, std.file.readText(dmdOutputFilePath).replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&"));
}