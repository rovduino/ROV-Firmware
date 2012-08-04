/*
 phidget1115.h
 Phidgets 1115 Absolute Gas Pressure Sensor
 Written by: Greg Marchese & ROVduino
 Released under ROVduino License. Full license at http://rovduino.zerogx.net
 */



#ifndef phidget1115_h
#define phidget1115_h

#include "WProgram.h"

    class phidget1115
    {
    public:
        phidget1115(int pin);
        float getKPA();
        float getDEPTH();
        float getAVERAGE(unsigned int repeats);
        void setZERO();
        
    private:
        float _phidgetsSUM;
        int _pin;
        float _voltageIN;
        float _KPA;
        float _zeroed;
    };

#endif
