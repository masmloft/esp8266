#ifndef AUDIOINPUT_H
#define AUDIOINPUT_H

//#include "Arduino.h"

#define atomicSet(a, b) \
{ \
	do \
		a = b; \
	while(a != b); \
}

class PcmBuf
{
private:
	using Item = uint16_t;

	enum Def
	{
		PCMBUF_SIZE = 4000,
		PCMBUF_COUNT = 2,
	};

	typedef Item Data[PCMBUF_SIZE];
private:
	Data _data[2];
	int _writePos = 0;

	int _writeBufNum = 0;

	volatile int _readPcmBufNum = {-1};
	volatile int _readPos = {0};
	uint64_t _txPos = 0;
public:
	const Data& data() const { return _data[0]; }

	void write(int val)
	{
		Data& data = _data[_writeBufNum];
		data[_writePos] = val;
		_writePos++;

		if(_writePos >= PCMBUF_SIZE)
		{
			static int t = 0;
//			Serial.print("bufWrite: ");
//			Serial.println(t++);

			_readPos = 0;
			_readPcmBufNum = _writeBufNum;

			_writePos = 0;

			_writeBufNum++;
			_writeBufNum = _writeBufNum % PCMBUF_COUNT;

//			Serial.print("ready: ");
//			Serial.println(_readPcmBufNum);
		}
	}

	int readAval()
	{
		return ((_readPos >= 0) && (_readPos < PCMBUF_SIZE));
	}

	template<class T>
	bool read(T& obj, size_t (T::*readFunc)(const uint8_t*, size_t), int maxCount)
	{
//		Serial.println(_readPos);
		int readPos;
		atomicSet(readPos, _readPos);

//		Serial.println(readPos);

		if((readPos < 0) || (readPos >= PCMBUF_SIZE))
			return false;

//		digitalWrite(LED_PIN, LOW);

//		Serial.print("rb: ");
//		Serial.print(readPos);

//		int readPos;
//		atomicSet(readPos, _readPos);

		int bufNum;
		atomicSet(bufNum, _readPcmBufNum);

		const Data& data = _data[bufNum];

		const int count = min(maxCount, PCMBUF_SIZE - readPos);
		const int size = count * sizeof(Item);

		(obj.*readFunc)((const uint8_t*)&_txPos, sizeof(_txPos));
		_txPos += size;

		(obj.*readFunc)((const uint8_t*)(data + readPos), size);

		if(readPos == _readPos)
		{
//			Serial.print(" inc ");
			readPos += count;
			atomicSet(_readPos, readPos);
		}

//		Serial.println(" re ");
//		digitalWrite(LED_PIN, HIGH);
	}
};


class AudioInput
{
public:

};

#endif // AUDIOINPUT_H

