/*
    phidgets1135.h
    Phidgets 1135 Precision Voltage Sensor Arduino Library
    Written by: Greg Marchese & ROVduino
    Released under ROVduino License. Full license at http://rovduino.zerogx.net
 */



#ifndef phidget1135_h
#define phidget1135_h

#include "WProgram.h"

class phidget1135
{
  public:
    phidget1135(int pin);
    float getVOLTAGE();
	float getAVERAGE(unsigned int repeats);

  private:
    float _phidgetsSUM;
    int _pin;
    float _voltageIN;
    float _voltageOUT;
};

#endif
