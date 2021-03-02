#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <Esp.h>
#include <HardwareSerial.h>
#include <osapi.h>

extern "C" {
#include "user_interface.h"
}

#include "Mic.h"
#include "AudioInput.h"

#define LED_PIN (2)
#define TIMER_DELAY (60 * 80)


//static os_timer_t sleepTimer;

WiFiUDP udp;
PcmBuf pcmBuf;
Mic mic;

void timerEvent()
{
	ets_intr_lock( );
	timer0_write(ESP.getCycleCount() + TIMER_DELAY);
	uint16_t adc_addr[1];
	system_adc_read_fast(adc_addr, 1, 8);
	pcmBuf.write(adc_addr[0]);
	ets_intr_unlock();
}

void sleepTimerEvent(void* arg)
{
	uint8_t curClientCount = WiFi.softAPgetStationNum();
	if(curClientCount == 0)
	{
		Serial.println("Sleep");
		ESP.deepSleep(5e6);
	}
}

void setup(void)
{
	pinMode(LED_PIN, OUTPUT);
	digitalWrite(LED_PIN, LOW);
	delay(10);

	Serial.begin(115200);
	delay(10);

	mic.loadCfg();

	WiFi.persistent(false);

//	wifi_set_opmode(WIFI_OFF);
//	WiFi.mode(WIFI_OFF);

	bool wifi_ap = true;
	//bool wifi_ap = false;

	if(wifi_ap == true)
	{
//		WiFi.setSleepMode(WIFI_MODEM_SLEEP);
		WiFi.setPhyMode(WIFI_PHY_MODE_11B);
		Serial.print("Setting soft-AP ... ");
		boolean result = WiFi.softAP("MW", "wsadwsad", 1, 1, 3);
		if(result == true)
			Serial.println("Ready");
		else
			Serial.println("Failed!");
	}
	else
	{
		//String wc_ssid = "QW_SML_WLAN";
		//String wc_password = "WirelessSml";
		//IPAddress wc_ip(192,168,1,35);

		//String wc_ssid = "Prog";
		//String wc_ssid = "sn-600";
		//String wc_password = "skynetltd";
		//IPAddress wc_ip(192,168,9,35);

		IPAddress wc_gateway(0,0,0,0);
		IPAddress wc_subnet(255,255,255,0);
		String wc_ssid = "QW_SML_WLAN";
		String wc_password = "WirelessSml";

		WiFi.begin(wc_ssid.c_str(), wc_password.c_str());
//		WiFi.config(wc_ip, wc_gateway, wc_subnet);
		while (WiFi.status() != WL_CONNECTED)
		{
			delay(1000);
			Serial.print(".");
		}

		Serial.println("");
		Serial.print("Connected to ");
		Serial.println(wc_ssid.c_str());
		Serial.print("IP address: ");
		Serial.println(WiFi.localIP());
	}

	delay(100);

	udp.begin(mic.UDP_LOCALPORT);
	delay(100);

//	timer1_isr_init();
//	timer1_enable(3, 0, 1);
//	//  timer1_write(268430 / 1000);
//	//  timer1_write(39);
//	timer1_write(39 / 2);
//	timer1_attachInterrupt(timerEvent);

	{
		noInterrupts();
		timer0_isr_init();
		timer0_attachInterrupt(timerEvent);
		timer0_write(ESP.getCycleCount() + TIMER_DELAY);
		interrupts();
	}

	digitalWrite(LED_PIN, HIGH);
}

void loop(void)
{
//	{
//		int ba = udp.next();
//		if((ba > 0))
//			Serial.println(ba);
//		if((ba > 0) && (ba < 64))
//		{
//			char buf[64];
//			int br = udp.read(buf, sizeof(buf) - 1);
//			if((br >= 0) && (br < 64))
//			{
//				buf[br] = 0;
//				mic.parseCmd(udp, buf);
//			}
//		}
//	}

//	if((mic.udpRemoteIp != uint32_t(0)) && (pcmBuf.readAval() > 0))
//	{
//		if(mic.ledEnable)
//			digitalWrite(LED_PIN, LOW);

//		udp.beginPacket(mic.udpRemoteIp, mic.UDP_REMOTEPORT);
//		pcmBuf.read(udp, &WiFiUDP::write, mic.txPacketCount);
//		udp.endPacket();
//		mic.checkStartTimeout();
//		delay(mic.txPacketDelay);

//		if(mic.ledEnable)
//			digitalWrite(LED_PIN, HIGH);
//	}

}

