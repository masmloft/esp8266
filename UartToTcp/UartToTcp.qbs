import qbs.FileInfo

CppApplication {
    //type: ["application", "application.info"]


    Depends { name: "ESP8266Core" }
    Depends { name: "ESP8266WiFi" }

    ESP8266Cfg.serialPort: "COM2"

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

