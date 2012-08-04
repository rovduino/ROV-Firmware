/*
 phidget1115.cpp
 Phidgets 1115 Depth Sensor Arduino Library
 Written by: Greg Marchese & ROVduino
 Released under ROVduino License. Full license at http://rovduino.zerogx.net
 */

#include "WProgram.h"
#include "phidget1115.h"

phidget1115::phidget1115(int pin)
{
    pinMode(pin, INPUT);
    _pin = pin;
}
void phidget1115::setZERO()
{
    _zeroed = getDEPTH();
}

float phidget1115::getKPA()
{
    _voltageIN = map(analogRead(_pin),0,1023,0,999);
    _KPA = (_voltageIN / 4) + 10.0;
    return _KPA;
}
float phidget1115::getDEPTH()
{
    return (getKPA() * 0.1019744) - _zeroed;  //constant for KPA to Meters H20;
}

float phidget1115::getAVERAGE(unsigned int repeats)
{
	float _phidgetSUM = 0.0;
	for(int i = 0; i < repeats; i++)
	{
		_phidgetSUM += getDEPTH();
	}	
	return (_phidgetSUM/repeats);
}
		
		