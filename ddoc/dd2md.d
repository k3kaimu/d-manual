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
import std.range;
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
    std.file.write(output, dmdOutputFilePath.readText()
                                            .replace("&lt;", "<")
                                            .replace("&gt;", ">")
                                            .replace("&amp;", "&")
                                            .find('\n')
                                            .find!(a => !a.isWhite)()
                                            .to!dstring()
                                            .boldReplaceToHTMLTag()
                                            .to!string());
}


auto tails(R)(R range)
{
    static struct Result()          // template: for inference of member function attributes.
    {
        R front() @property { return _r; }
        void popFront() { _r.popFront(); }
        bool empty() { return _r.empty; }

      private:
        R _r;
    }


    return Result!()(range);
}

unittest{
    assert(equal(tails([0, 1, 2]), [[0, 1, 2], [1, 2], [2]]));
    assert(tails!(int[])([]).empty);
}


dstring boldReplaceToHTMLTag(dstring input)
{
    auto r = input.tails;
    auto app = appender!dstring();
    bool isInBoldTag;

    while(!r.empty)
    {
        auto e = r.front;

        // D言語のソースコード中に`**p`が出現することはないだろう…という前提
        if(e.startsWith("**")){
            app.put(isInBoldTag ? "</b>" : "<b>");
            isInBoldTag = !isInBoldTag;
            
            r.popFrontN(2);
            continue;
        }else
            app.put(e[0]);

        r.popFront();
    }

    return app.data;
}