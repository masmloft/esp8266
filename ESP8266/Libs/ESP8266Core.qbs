StaticLibrary {

    Depends { name: "cpp" }

    Depends { name: "ESP8266Cfg" }

    cpp.includePaths: [
        "./variants/nodemcu",
        "./cores/esp8266",

        "tools/sdk/include",
        "tools/sdk/lwip2/include",
        "tools/sdk/libc/xtensa-lx106-elf/include",
    ]

    files: [
        "cores/**/*.h",
        "cores/**/*.c",
        "cores/**/*.cpp",
        "cores/**/*.s",
//        "cores/libb64/*.h",
//        "cores/libb64/*.c",
//        "cores/spiffs/*.h",
//        "cores/spiffs/*.c",
//        "cores/umm_malloc/*.h",
//        "cores/umm_malloc/*.c",
    ]

    Export {
        Depends { name: "cpp" }

        Depends { name: "ESP8266Cfg" }

        cpp.includePaths: product.cpp.includePaths

        cpp.libraryPaths:
        [
            "./tools/sdk/lib",
            "./tools/sdk/lib/NONOSDK22x_190703",
            "./tools/sdk/ld",
            "./tools/sdk/libc/xtensa-lx106-elf/lib",
        ]

        cpp.linkerScripts: [
        ]

        cpp.staticLibraries:
        [
            "hal",
            "phy",
            "pp",
            "net80211",
            "lwip2-536-feat",
            "wpa",
            "crypto",
            "main",
            "wps",
            "bearssl",
            "axtls",
            "espnow",
            "smartconfig",
            "airkiss",
            "wpa2",
            "stdc++",
            "m",
            "c",
            "gcc",
        ]
    }
}
