#include <ESP8266WiFi.h>

#include <algorithm> // std::min

#define SERIAL_LOOPBACK 0

#define BAUD_SERIAL 9600//10400
//#define BAUD_LOGGER 115200
#define RXBUFFERSIZE 1024


#define STACK_PROTECTOR  512 // bytes

//how many clients should be able to telnet to this ESP8266
#define MAX_SRV_CLIENTS 2

//HardwareSerial* logger = &Serial;
//HardwareSerial& dataUart = Serial;

HardwareSerial& uart = Serial;

const int port = 23;

WiFiServer server(port);
WiFiClient serverClients[MAX_SRV_CLIENTS];

void setup()
{
	uart.begin(BAUD_SERIAL);
	uart.setRxBufferSize(RXBUFFERSIZE);

	uart.println(ESP.getFullVersion());
	uart.printf("Serial baud: %d (8n1: %d KB/s)\n", BAUD_SERIAL, BAUD_SERIAL * 8 / 10 / 1024);
	uart.printf("Serial receive buffer size: %d bytes\n", RXBUFFERSIZE);

	WiFi.mode(WIFI_STA);
	WiFi.begin("Prog", "skynetltd");
	while (WiFi.status() != WL_CONNECTED)
	{
		uart.print('.');
		delay(500);
	}
	uart.println();
	uart.print("connected, address=");
	uart.println(WiFi.localIP());

	//start server
	server.begin();
	server.setNoDelay(true);

	uart.print("Ready! Use 'telnet ");
	uart.print(WiFi.localIP());
	uart.printf(" %d' to connect\n", port);

	uart.swap();
	uart.flush();
}

void toLog(const char* s)
{
	return;
	uart.swap();
	uart.flush();
	uart.write(s);
	uart.swap();
	uart.flush();
}

void toLog(unsigned int n, int base = 10)
{
	return;
	uart.swap();
	uart.flush();
	uart.print((unsigned long) n, base);
	uart.swap();
	uart.flush();
}

void loop()
{
//	dataUart.print('.');
	//check if there are any new clients
	if (server.hasClient())
	{
		//find free/disconnected spot
		int i;
		for (i = 0; i < MAX_SRV_CLIENTS; i++)
		{
			if (!serverClients[i])
			{ // equivalent to !serverClients[i].connected()
				serverClients[i] = server.available();
				toLog("New client: index ");
				toLog(i);
				break;
			}
		}

		//no free/disconnected spot so reject
		if (i == MAX_SRV_CLIENTS)
		{
			server.available().println("busy");
			// hints: server.available() is a WiFiClient with short-term scope
			// when out of scope, a WiFiClient will
			// - flush() - all data will be sent
			// - stop() - automatically too
			toLog("server is busy with %d active connections\n");//, MAX_SRV_CLIENTS);
		}
	}

	//check TCP clients for data
#if 1
	// Incredibly, this code is faster than the bufferred one below - #4620 is needed
	// loopback/3000000baud average 348KB/s
	for (int i = 0; i < MAX_SRV_CLIENTS; i++)
	{
		while (serverClients[i].available() && uart.availableForWrite() > 0)
		{
			// working char by char is not very efficient
			uart.write(serverClients[i].read());
		}
	}
#else
	// loopback/3000000baud average: 312KB/s
	for (int i = 0; i < MAX_SRV_CLIENTS; i++)
	{
		while (serverClients[i].available() && uart.availableForWrite() > 0)
		{
			size_t maxToSerial = std::min(serverClients[i].available(), uart.availableForWrite());
			maxToSerial = std::min(maxToSerial, (size_t)STACK_PROTECTOR);
			uint8_t buf[maxToSerial];
			size_t tcp_got = serverClients[i].read(buf, maxToSerial);
			size_t serial_sent = uart.write(buf, tcp_got);
			if (serial_sent != maxToSerial) {
				toLog("len mismatch: available:%zd tcp-read:%zd serial-write:%zd\n", maxToSerial, tcp_got, serial_sent);
			}
		}
	}
#endif

	// determine maximum output size "fair TCP use"
	// client.availableForWrite() returns 0 when !client.connected()
	size_t maxToTcp = 0;
	for (int i = 0; i < MAX_SRV_CLIENTS; i++)
	{
		if (serverClients[i])
		{
			size_t afw = serverClients[i].availableForWrite();
			if (afw)
			{
				if (!maxToTcp)
				{
					maxToTcp = afw;
				}
				else
				{
					maxToTcp = std::min(maxToTcp, afw);
				}
			}
			else
			{
				// warn but ignore congested clients
				toLog("one client is congested");
			}
		}
	}

	//check UART for data
	size_t len = std::min((size_t)uart.available(), maxToTcp);
	len = std::min(len, (size_t)STACK_PROTECTOR);
	if (len)
	{
		uint8_t sbuf[len];
		size_t serial_got = uart.readBytes(sbuf, len);
		// push UART data to all connected telnet clients
		for (int i = 0; i < MAX_SRV_CLIENTS; i++)
		{
			// if client.availableForWrite() was 0 (congested)
			// and increased since then,
			// ensure write space is sufficient:
			if (serverClients[i].availableForWrite() >= serial_got)
			{
				size_t tcp_sent = serverClients[i].write(sbuf, serial_got);
				if (tcp_sent != len)
				{
					toLog("len mismatch: available:%zd serial-read:%zd tcp-write:%zd\n");//, len, serial_got, tcp_sent);
				}
			}
		}
	}
}
