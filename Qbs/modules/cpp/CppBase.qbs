import qbs
import qbs.FileInfo
import qbs.Utilities
import qbs.TextFile
import qbs.Environment

import "utils.js" as utils

Module  {
    condition: false

    property bool verbose: false

    property bool debugInformation: qbs.debugInformation
    property string optimization: qbs.optimization

    property bool consoleApplication

    property string binutilsPath

    property string toolchainInstallPath: ""
    property string toolchainPrefix
    property string cCompilerName: ""
    property string compilerName: ""
    property string cxxCompilerName: ""
    property stringList platformCommonCompilerFlags
    property stringList platformLinkerFlags
    property stringList compilerDefinesByLanguage
    property stringList platformDefines
    property pathList systemIncludePaths
    property pathList frameworkPaths
    property pathList systemFrameworkPaths

    property string linkerName: ""
    property string staticLinkerName: ""

    property string sysroot: qbs.sysroot

    property stringList cxxArgs

    property pathList includePaths
    property stringList defines

    property stringList commonCompilerFlags
    property stringList assemblerFlags
    property stringList cFlags
    property stringList cxxFlags
    property stringList linkerFlags
    property stringList driverFlags: project.driverFlags
    property stringList driverLinkerFlags: project.driverLinkerFlags

    property pathList libraryPaths
    property stringList staticLibraries
    property stringList dynamicLibraries
    property pathList linkerScripts

    property string executableSuffix
    property string staticLibrarySuffix

    FileTagger {
        patterns: ["*.s"]
        fileTags: ["asm"]
    }

    FileTagger {
        patterns: "*.S"
        fileTags: ["asm_cpp"]
    }

    FileTagger {
        patterns: ["*.c"]
        fileTags: ["c"]
    }

    FileTagger {
        patterns: ["*.C", "*.cpp", "*.cxx", "*.c++", "*.cc"]
        fileTags: ["cpp"]
    }

    FileTagger {
        patterns: ["*.h", "*.H", "*.hpp", "*.hxx", "*.h++"]
        fileTags: ["hpp"]
    }

//    FileTagger {
//        patterns: ["*.ld"]
//        fileTags: ["inkerscript"]
//    }
}
