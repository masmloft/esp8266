import qbs

Project {
    qbsSearchPaths: [
        "./Qbs",
        "./ESP8266/Qbs"
	]

    references: [
        "ESP8266/ESP8266.qbs",
        "UartToTcp/UartToTcp.qbs",
       ]
}
