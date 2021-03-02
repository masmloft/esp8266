import qbs
import qbs.FileInfo
import qbs.TextFile

Module {
    property string serialPort: "COM1"

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
            cmd.description = "***Info: " + output.filePath;
            cmd.highlight = "linker";

            return [cmd, cmdFile];
        }
    }

    Rule
    {
        name: "application.bin"
        condition: true
        inputs: ["application.elf"]
        Artifact
        {
            filePath: input.baseName + ".bin"
            fileTags: "application.bin"
        }
        prepare:
        {
            var esptool = project.path + "/ESP8266/Tools/esptool.exe";
            var eboot = project.path + "/ESP8266/Bootloaders/eboot/eboot.elf";
            var args = [
                        "-eo", eboot,
                        "-bo",output.filePath,
                        "-bm","dio","-bf","40","-bz","4M","-bs",".text","-bp","4096","-ec",
                        "-eo",input.filePath,
                        "-bs",".irom0.text","-bs",".text","-bs",".data","-bs",".rodata","-bc","-ec"
                    ];
            var cmd = new Command(esptool, args);
            cmd.description = "***Generate: " + output.filePath;
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
            cmd.description = "***Generate: " + output.filePath;
            cmd.sourceCode = function() {
                var ofile = new TextFile(output.filePath, TextFile.WriteOnly);
                ofile.write(project.path + "/ESP8266/Tools/esptool.exe ")
                ofile.write(" -cd nodemcu");
                ofile.write(" -cb 115200");
                ofile.write(" -cp " + product.ESP8266BuildConfig.serialPort);
                ofile.write(" -ca 0x00000");
                ofile.write(" -cf " + inputs["application.bin"][0].filePath);
                ofile.close();
            }
            return [cmd];
        }
    }
}
