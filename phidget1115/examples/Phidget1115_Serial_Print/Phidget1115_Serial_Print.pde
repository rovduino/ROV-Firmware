#include <phidget1115.h>

phidget1115 sensor = phidget1115(4);  //analog pin 4
float sensorValue;

void setup()  {
  Serial.begin(9600);
  Serial.println("Initialized");
}

void loop()  {
  sensorValue = sensor.getDEPTH();
  Serial.println(sensorValue,DEC);
  delay(1000);
}

