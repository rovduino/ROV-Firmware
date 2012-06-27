#include <phidget1135.h>

phidget1135 sensor = phidget1135(1);  //analog pin 1

void setup()  {
  Serial.begin(9600);
  Serial.println("Initialized");
}

void loop()  {
  Serial.println(sensor.getAVERAGE(10) ,DEC);
  delay(1000);
}

