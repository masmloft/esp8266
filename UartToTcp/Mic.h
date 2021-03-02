#ifndef MIC_H
#define MIC_H

#include <stdint.h>
#include <Esp.h>
#include <HardwareSerial.h>
#include <IPAddress.h>
#include <WiFiUdp.h>

#include "Classes/EEPROM.h"


class Mic
{
public:
	static const uint16_t UDP_LOCALPORT = 8001;
	static const uint16_t UDP_REMOTEPORT = 8002;

public:
	bool ledEnable = false;

public:
	bool _enabled = false;
	IPAddress udpRemoteIp;
	int txPacketCount = 500;
	int txPacketDelay = 10;

public:
	void loadCfg()
	{
		Serial.println("loadCfg");
		EEPROMClass eeprom;
		eeprom.begin(32);
		ledEnable = bool(eeprom.read(0));
		Serial.println(ledEnable);
	}

	void saveCfg()
	{
		Serial.println("saveCfg");
		EEPROMClass eeprom;
		eeprom.begin(32);
		eeprom.write(0, uint8_t(ledEnable));
		eeprom.commit();
	}

	bool enabled() const { return _enabled; }

	void checkStartTimeout()
	{
		uint32_t ms = millis();
		if(ms - _recvStartMs > 10000)
		{
			_enabled = false;
			udpRemoteIp = IPAddress();
//			Serial.print(ms);
//			Serial.print(" ");
//			Serial.print(_recvStartMs);
//			Serial.println("startTimeout");
		}
	}

	void parseCmd(WiFiUDP& udp, const char* cmd)
	{
		Serial.println(cmd);

		if(ets_strncmp(cmd, "start", 5) == 0)
		{
			_enabled = true;
			udpRemoteIp = udp.remoteIP();
			_recvStartMs = millis();
			Serial.println(udpRemoteIp.toString());
			return;
		}

		if(ets_strncmp(cmd, "stop", 5) == 0)
		{
			_enabled = false;
			udpRemoteIp = IPAddress();
			return;
		}

		if(ets_strncmp(cmd, "tc=", 3) == 0)
		{
			int v = atoi(cmd + 3);
			if((v >= 8) && (v <= 16000))
				txPacketCount = v;
			return;
		}

		if(ets_strncmp(cmd, "td=", 3) == 0)
		{
			int v = atoi(cmd + 3);
			if((v >= 0) && (v <= 4000))
				txPacketDelay = v;
			return;
		}

		if(ets_strncmp(cmd, "le=", 3) == 0)
		{
			int v = atoi(cmd + 3);
			ledEnable = bool(v);
			return;
		}

		if(ets_strncmp(cmd, "scf", 3) == 0)
		{
			saveCfg();
			return;
		}

	}

private:
	uint32_t _recvStartMs = 0;

};

#endif // MIC_H
