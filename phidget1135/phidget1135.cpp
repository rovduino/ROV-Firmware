/*
 phidgets1135.h
 Phidgets 1135 Precision Voltage Sensor Arduino Library
 Written by: Greg Marchese & ROVduino
 Released under ROVduino License. Full license at http://rovduino.zerogx.net
 */

#include "WProgram.h"
#include "phidget1135.h"

phidget1135::phidget1135(int pin)
{
    pinMode(pin, INPUT);
    _pin = pin;
}

float phidget1135::getVOLTAGE()
{
    _voltageIN = map(analogRead(_pin),0,1023,0,999);
    _voltageOUT = (((_voltageIN) / 200) - 2.48507 ) / 0.0681
    return _voltageOUT;
}

float phidget1135::getAVERAGE(unsigned int repeats)
{
	float _phidgetSUM = 0.0;
	for(int i = 0; i < repeats; i++)
	{
		_phidgetSUM += getVOLTAGE();
	}	
	return (_phidgetSUM/repeats);
}
		
		