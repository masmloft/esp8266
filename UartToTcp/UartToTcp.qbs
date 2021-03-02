import qbs.FileInfo

CppApplication {
    Depends { name: "ESP8266WiFi" }

    ESP8266Cfg.serialPort: "COM4"

    Group {
        name: "Files to install"
        qbs.install: true
        qbs.installDir: ""
        fileTagsFilter: product.type
    }

    files: [
        "**/*.h",
        "**/*.c",
        "**/*.cpp",
    ]
}

