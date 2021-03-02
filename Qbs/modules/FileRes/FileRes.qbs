import qbs
import qbs.TextFile
import qbs.FileInfo
import qbs.ModUtils

Module {
    Depends { name: "cpp" }

    cpp.includePaths: [
        product.destinationDirectory
    ]

    FileTagger {
        patterns: ["*.fileres"]
        fileTags: ["fileres"]
    }

    Rule {
        inputs: ["fileres"]

        Artifact {
            //filePath: FileInfo.path(input.filePath) + '/' + input.fileName + ".h"
            filePath: input.fileName + ".c"
            fileTags: ["c"]
        }

        prepare: {
            //console.info(FileInfo.path(input.filePath) + "-suka1")

            //throw "dd"

            var cmd = new JavaScriptCommand();
            cmd.description = input.fileName + "->" + output.fileName;
            cmd.highlight = "codegen";
            cmd.sourceCode = function() {

                var file = new TextFile(input.filePath);
                var in_content = file.readAll();
                file.close()

                file = new TextFile(output.filePath, TextFile.WriteOnly);
                var out_content = "const char " + FileInfo.baseName(input.fileName) + "_res[] = {\n";
                var l = 0;
                for(var i = 0; i < in_content.length; ++i)
                {
                    var ch = in_content[i];
                    out_content += "0x" + ch.charCodeAt(0).toString(16) + ",";

                    l++;
                    if(l % 16 == 0)
                        out_content += '\n';
                }
                out_content += "\n};\n"

                file.write(out_content);
                file.close();
            }
            return cmd;
        }
    }
}
