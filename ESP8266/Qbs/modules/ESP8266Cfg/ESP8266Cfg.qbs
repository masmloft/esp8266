import qbs
import qbs.FileInfo
import qbs.TextFile

Module {
    property string serialPort: "COM1"
    property string serialPortSpeed: "921600"

    property string flashMode: "dout"
    property string flashFreq: "40"
    property string flashSize: "1M"

    property path rootPath: path + "./../../../Libs/"
    property path python3: rootPath + "/tools/python3/3.7.2-post1/python3"
    property path elf2bin_py: rootPath + "/tools/elf2bin.py"
    property path upload_py: rootPath + "/tools/upload.py"
    property path bootloader: rootPath + "/bootloaders/eboot/eboot.elf"

    //to-do
    //"xtensa-lx106-elf-gcc" -CC -E -P -DVTABLES_IN_FLASH "tools/sdk/ld/eagle.app.v6.common.ld.h" -o "local.eagle.app.v6.common.ld"


    Depends { name: "cpp" }

    cpp.commonCompilerFlags: [

//        generic.menu.ip.lm2f=v2 Lower Memory
//        generic.menu.ip.lm2f.build.lwip_include=lwip2/include
//        generic.menu.ip.lm2f.build.lwip_lib=-llwip2-536-feat
//        generic.menu.ip.lm2f.build.lwip_flags=-DLWIP_OPEN_SRC -DTCP_MSS=536 -DLWIP_FEATURES=1 -DLWIP_IPV6=0

        "-D__ets__",
        "-DICACHE_FLASH",
        "-U__STRICT_ANSI__",
        "-c",
        "-Wall",
        "-Wextra",
        "-Os",
        "-g",

        "-DNONOSDK22x_190703=1",
        "-DF_CPU=80000000L",
        "-DLWIP_OPEN_SRC",
        "-DTCP_MSS=536",
        "-DLWIP_FEATURES=1",
        "-DLWIP_IPV6=0",
        "-DARDUINO=10805",
        "-DARDUINO_ESP8266_GENERIC",
        "-DARDUINO_ARCH_ESP8266",
        "-DARDUINO_BOARD=ESP8266_GENERIC",
        "-DLED_BUILTIN=2",
        "-DFLASHMODE_DOUT",
        "-DESP8266",

        "-MMD",
        "-ffunction-sections",
        "-fdata-sections",
        "-mtext-section-literals",
        "-falign-functions=4",
        "-mlongcalls",
        "-fno-exceptions",

    ]

    cpp.assemblerFlags: [
        "-x",
        "assembler-with-cpp",
    ]

    cpp.cFlags: [
        "-std=gnu99",
        "-nostdlib",
        "-fno-inline-functions",

        "-Wpointer-arith",
        "-Wno-implicit-function-declaration",
        "-Wl,-EL",
    ]

    cpp.cxxFlags: [
        "-std=gnu++11",
        "-fno-rtti",
    ]

    cpp.driverLinkerFlags: [
        "-fno-exceptions",
        "-g",
        "-Wall",
        "-Wextra",
        "-Os",
        "-nostdlib",
        "-Wl,--no-check-sections",
        "-u",
        "app_entry",
        "-u",
        "_printf_float",
        "-u",
        "_scanf_float",
        "-Wl,-static",
        "-Wl,--gc-sections",
        "-Wl,-wrap,system_restart_local",
        "-Wl,-wrap,spi_flash_read",
        "-Teagle.flash.1m64.ld"
    ]

    Rule
    {
        name: "info"
        condition: true
        inputs: ["application.elf"]
        Artifact
        {
            filePath: input.baseName + ".info"
            fileTags: "application.info"
        }
        prepare:
        {
            var app = product.cpp.toolchainInstallPath + (product.cpp.toolchainPrefix ? "/" + product.cpp.toolchainPrefix : "/") + "size";

            var cmdFile = new Command(app, [ input.filePath ]);
            cmdFile.stdoutFilePath = output.filePath;
            cmdFile.description = "***Info: " + output.filePath;
            cmdFile.highlight = "linker";

            var cmd = new Command(app, [ input.filePath ]);
            cmd.description = "***Info: " + output.fileName;
            cmd.highlight = "linker";

            return [cmd, cmdFile];
        }
    }

    Rule
    {
        name: "elf->bin"
        condition: true
        inputs: ["application.elf"]
        Artifact
        {
            filePath: input.baseName + ".bin"
            fileTags: "application.bin"
        }
        prepare:
        {
            var toolchainPath = product.cpp.toolchainInstallPath;

            var app = product.ESP8266Cfg.python3;
            var args = [
                        product.ESP8266Cfg.elf2bin_py,
                        "--eboot", product.ESP8266Cfg.bootloader,
                        "--app", input.filePath,
                        "--flash_mode", product.ESP8266Cfg.flashMode,
                        "--flash_freq", product.ESP8266Cfg.flashFreq,
                        "--flash_size", product.ESP8266Cfg.flashSize,
                        "--path", toolchainPath,
                        "--out", output.filePath
                    ];
            var cmd = new Command(app, args);
            cmd.description = "***Generate: " + output.fileName;
            cmd.highlight = "linker";
            return [cmd];
        }
    }


    Rule
    {
        name: "flash.bat"
        condition: true
        multiplex: true
        inputs: ["application.bin", "application.info"]
        Artifact
        {
            filePath: product.name + ".flash.bat"
            fileTags: "application"
        }
        prepare:
        {
            var cmd = new JavaScriptCommand();
            cmd.description = "***Generate: " + output.fileName;
            cmd.sourceCode = function() {
                var ofile = new TextFile(output.filePath, TextFile.WriteOnly);

                ofile.write(product.ESP8266Cfg.python3);
                ofile.write(" " + product.ESP8266Cfg.upload_py);
                ofile.write(" --chip esp8266");
                ofile.write(" --port " + product.ESP8266Cfg.serialPort);
                ofile.write(" --baud " + product.ESP8266Cfg.serialPortSpeed);
                ofile.write(" --before default_reset");
                ofile.write(" --after hard_reset write_flash");
                ofile.write(" 0x0 " + inputs["application.bin"][0].filePath);

                ofile.close();
            }
            return [cmd];
        }
    }
}
