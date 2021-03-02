import qbs.File
import qbs.FileInfo
import qbs.ModUtils
import qbs.PathTools
import qbs.Probes
import qbs.Process
import qbs.TextFile
import qbs.Utilities
import qbs.UnixUtils
import qbs.WindowsUtils

import "gcc-baremetal-win.js" as js

CppBase {
    condition: qbs.toolchain && qbs.toolchain.contains("gcc")
    priority: 100

    cCompilerName: "gcc"
    cxxCompilerName: "g++"
    linkerName: "gcc"
    staticLinkerName: "ar"

    executableSuffix: ".elf"
    staticLibrarySuffix: ".a"

    Rule {
        name: "compiler"
        inputs: ["c", "cpp", "asm_cpp"]
        Artifact {
            fileTags: ["obj"]
            //filePath: "" + input.fileName + ".o"
            filePath: FileInfo.joinPaths(Utilities.getHash(input.baseDir), input.fileName + ".o")
        }
        prepare: {
            return js.prepareCompiler(product, input, output);
        }
    }

    Rule {
        name: "StaticLibraryLinker"
        multiplex: true
        inputs: ['obj']
        Artifact {
            fileTags: ["staticlibrary"]
            filePath: product.name + product.cpp.staticLibrarySuffix
        }
        prepare: {
            return js.prepareStaticLibrary(product, inputs, output);
        }
    }

    Rule {
        name: "ApplicationLinker"
        multiplex: true
        inputs: ["obj", "linkerscript"]
        inputsFromDependencies: ["staticlibrary"]
        Artifact {
            fileTags: ["application.elf"]
            filePath: product.name + product.cpp.executableSuffix
        }
        prepare: {
            return js.prepareApplicationLinker(product, inputs, output);
        }
    }

}
