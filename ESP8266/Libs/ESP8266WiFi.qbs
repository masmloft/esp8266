StaticLibrary {
    Export {
        Depends { name: "cpp" }

        Depends { name: "ESP8266Core" }

        cpp.includePaths: [
            "libraries/ESP8266WiFi/src",
        ]
    }

    Depends { name: "cpp" }

    Depends { name: "ESP8266Core" }

    cpp.executableSuffix: ".a"

    cpp.includePaths: [
        "libraries/ESP8266WiFi/src",
    ]

    files: [
        "libraries/ESP8266WiFi/src/**/*.h",
        "libraries/ESP8266WiFi/**/*.c",
        "libraries/ESP8266WiFi/**/*.cpp",
        "libraries/ESP8266WiFi/**/*.s",
    ]

}
