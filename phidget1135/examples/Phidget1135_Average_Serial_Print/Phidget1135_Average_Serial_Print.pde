#include <phidget1135.h>

phidget1135 sensor = phidget1135(4);  //analog pin 4
float sensorValue;

void setup()  {
  Serial.begin(9600);
  Serial.println("Initialized");
}

void loop()  {
  sensorValue = sensor.getAVERAGE(10);	//averages 10 readings
  Serial.println(sensorValue,DEC);
  delay(1000);
}

