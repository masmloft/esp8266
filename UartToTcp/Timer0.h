#ifndef HWTIMER_H
#define HWTIMER_H

#include <Arduino.h>
#include <Esp.h>

class Timer0
{
	bool _enabled = false;
	timercallback _func = nullptr;
	uint32_t _interval = 0;
public:
	void setEnabled(bool val)
	{
		_enabled = val;
	}

	void setInterval(uint32_t interval)
	{
		_interval = interval;
	}

	void setFunc(timercallback func)
	{
		_func = func;
	}

	void start()
	{
		if(_enabled == false)
			return;
		noInterrupts();
		timer0_isr_init();
		timer0_attachInterrupt(_func);
		timer0_write(ESP.getCycleCount() + _interval);
		interrupts();
	}

};

#endif // HWTIMER_H
