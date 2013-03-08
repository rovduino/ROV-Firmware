

//---------------------------------------------------------------------------------------------------------
// ROVduino Firmware v1.0 - AngelFish
// Released by Greg Marchese & ROVduino
//---------------------------------------------------------------------------------------------------------
// This code is released under the ROVduino Open Source License. 
// More Info is Availible at http://rovduino.zerogx.net
//
// The default code assumes that the ROV uses Vector/4H2V drive and that is has 4 relays.
//---------------------------------------------------------------------------------------------------------
// VERSIONIONING INFO | Firmware Versioning Info
float VERSION = 1.00;

//INCLUDES | All the various libraries used are declared here.
//---------------------------------------------------------------------------------------------------------
#include <math.h>
#include <SPI.h>
#include <Ethernet.h>
#include <String.h>
#include <Udp.h>
#include <stdlib.h>
#include <Wire.h>
#include <Servo.h>


//NETWORKING SETUP | These are the settings for networking. These will change by setup.
//---------------------------------------------------------------------------------------------------------
byte rovMAC[] = { 0x90, 0xA2, 0xDA, 0x00, 0x25, 0xF6 }; //MAC Address of ROV. Use numbers on Eth Shield.
byte rovIP[]  = {192,168,1,3}; // IP Address of ROV. Feel free to change. 768 is shorthand for ROV
const unsigned int coriPORT = 20000; //CORI Port

byte controlIP[] = {255,255,255,255}; //this will let us do broadcast based UDP. If you need a P2P Connection, please change to your IP Address.
unsigned int ciroPORT = 21000; // CIRO Port
int timeout = 5000; //time before error state is raised. time is measured in milliseconds.

//MOTOR SETUP  |  These are motor settings. Nulls, Maxs, Mins, Pins are declared here.
//---------------------------------------------------------------------------------------------------------
const int numTHRUSTERS = 6;           //0    1    2    3    4    5               //| Order: FL, FR, RR, RL, VL, VR (Vector Drive)
const int thrusterNULL[numTHRUSTERS] = {90,  90,  90,  90,  90,  90};            //|--------------------------------------------   
const int thrusterMAX[numTHRUSTERS]  = {179, 179, 179, 179, 179, 179};           //| Graphical View (from top) (vector drive)
const int thrusterMIN[numTHRUSTERS]  = {0,   0,   0,   0,   0,   0};             //|  [0]--[1]            [4]--[5] 
const int thrusterPINS[numTHRUSTERS] = {2,   3,   4,   5,   6,   7};             //|  [3]--[2]  <- horiz. ^-vert
                                                                                 //|-------------------------------------------- 
                                                                                 //| Graphical View (from top) (2H2V Drive)
                                                                                 //|  [0]--[1] <-H    V-> [2]--[3]
                                                                                 //|-------------------------------------------- 
                                                                                 //| Graphical View (from top) (2H1V Drive)
                                                                                 //|  [0]--[1] <-H    V-> [2]
                                 


//RELAY SETUP  |  These are the settings for relays. Pins are really the only things to change here.
//---------------------------------------------------------------------------------------------------------
const int numRELAYS = 5;           // 0,  1,  2,  3,  4       //| Number of Relays on the ROV.
const int relayPINS[numRELAYS]     = {6,  7,  8,  9,  10};    //| Pin Number Array. 
const int relayDEFAULT[numRELAYS]  = {0,  0,  0,  0,  0};     //| Default State of Relays


//CAMERA SETUP  | This is where the camera servo PWM pin is attached. 
//---------------------------------------------------------------------------------------------------------
const int cameraPIN = 11;

//VARIABLES     |  Variables here do not need to be changed by the user. The ROVduino Control system uses
//              |  these for control of the robot. These will probably only be changed by ROVduino Developers.
//---------------------------------------------------------------------------------------------------------
unsigned int nullPORT = 0;
unsigned int rxPACKETS;
char incomingDATA[60];
char outgoingDATA[60];
char buffer[10];

const int incomingLENGTH = sizeof(incomingDATA);
const int outgoingLENGTH = sizeof(outgoingDATA);

int thrusterVALS[numTHRUSTERS] = {thrusterNULL[numTHRUSTERS]};
int relaySTATE[numRELAYS] = {relayDEFAULT[numRELAYS]};

int cameraVAL = 90;

long lastCONNECTION;
long currentCONNECTION;

bool rovCONNECTED;



//DECLARATIONS  |  Declare instances of objects used in your ROVduino build. By default: 6 motors, 1 camera
//---------------------------------------------------------------------------------------------------------
Servo thruster[6];
Servo camera;


//ROV Boot      | This runs when the ROV boots. 
//---------------------------------------------------------------------------------------------------------
void setup()
{
  //init communications
  Ethernet.begin(rovMAC, rovIP);
  Udp.begin(coriPORT);
  
  //init motors
  for (int i = 0; i < numTHRUSTERS; i++) 
  { 
    thruster[i].attach(thrusterPINS[i]);
  }
  
  //init relays
  for (int i = 0; i < numRELAYS; i++)
  { 
    pinMode(relayPINS[i],OUTPUT);
  }
  //put ROV in Safe Mode
  rovSAFEMODE();
  
  //init camera
  camera.attach(cameraPIN);
  camera.write(cameraVAL);
  //init timers
  lastCONNECTION = currentCONNECTION = millis();
  
}

//ROV Loop
//---------------------------------------------------------------------------------------------------------
void loop()
{
  currentCONNECTION = millis();
  if(Udp.available())
    {
      if (!rovCONNECTED)
      {
        rovREGAINCONTROL();
      }
    //state update
      rxPACKETS = rxPACKETS + 1;
      rovCONNECTED = true;
      lastCONNECTION = millis();
    //Process Packet
      Udp.readPacket(incomingDATA, incomingLENGTH, controlIP, nullPORT);
      sscanf(incomingDATA, "%d %d %d %d %d %d %d %d %d %d %d %d", 
      &thrusterVALS[0], &thrusterVALS[1], &thrusterVALS[2], &thrusterVALS[3], &thrusterVALS[4], &thrusterVALS[5],
      &relaySTATE[0], &relaySTATE[1], &relaySTATE[2], &relaySTATE[3], &relaySTATE[4], &cameraVAL);
    // Write Thruster Values
      for (int i = 0; i < numTHRUSTERS; i++) 
        { 
           thruster[i].write(constrain(thrusterVALS[i],thrusterMIN[i],thrusterMAX[i]));
        }
    // Write Relay Values
      for (int i = 0; i < numRELAYS; i++) 
        { 
           digitalWrite(relayPINS[i], relaySTATE[i]);
        }
      //Write Camera Values
        camera.write(cameraVAL);
    }
  else if (currentCONNECTION - lastCONNECTION > timeout)
   {
     rovCONNECTED = false;
     rovSAFEMODE();
     lastCONNECTION = millis();
   }
   else if (currentCONNECTION - lastCONNECTION < 0)
   {
     currentCONNECTION = lastCONNECTION = millis();
   }
   sendROVC3();
}

//ROV Safemode
//--------------------------------------------------------------------------------------------------------
inline void rovSAFEMODE()
{
  for (int i = 0; i < numTHRUSTERS; i++)
  { 
    thruster[i].detach();
  }
  for (int i = 0; i < numRELAYS; i++)
  { 
     digitalWrite(relayPINS[i],LOW);
  }
  camera.detach();
}
//ROV Regain Control
//--------------------------------------------------------------------------------------------------------
inline void rovREGAINCONTROL()
{
 //init motors
  for (int i = 0; i < numTHRUSTERS; i++) { 
     thruster[i].attach(thrusterPINS[i]);
     thruster[i].write(thrusterNULL[i]);
  }
  
  //init relays
  for (int i = 0; i < numRELAYS; i++) { 
    pinMode(relayPINS[i],OUTPUT);
    digitalWrite(relayPINS[i],LOW);
  }
  camera.attach(cameraPIN);
  camera.write(cameraVAL);
}
//Send ROV C3 Packet
//--------------------------------------------------------------------------------------------------------
inline void sendROVC3()
{
  // clear outgoing data buffer
  memset(outgoingDATA, 0, sizeof(outgoingDATA));

  //rov version
  dtostrf(VERSION, 3, 1, buffer);
  strcat(outgoingDATA, buffer);
  strcat(outgoingDATA, " "); 
  
  //rov motors
  for (int i = 0; i < numTHRUSTERS; i++)
  {
    //memset(buffer, 0, sizeof(buffer));
    itoa(thrusterVALS[i],buffer,10);
    strcat(outgoingDATA,buffer);
    strcat(outgoingDATA, " ");
  }
  //rov relays
  for (int i = 0; i < numRELAYS; i++)
  {
     //memset(buffer,0, sizeof(buffer));
     itoa(relaySTATE[i],buffer,10);
     strcat(outgoingDATA,buffer);
     strcat(outgoingDATA, " ");   
  }
  
  //camera
  itoa(camera.read(),buffer,10);
  strcat(outgoingDATA,buffer);
  strcat(outgoingDATA, " ");
  
 //send the packet
  Udp.sendPacket(outgoingDATA, controlIP, ciroPORT);
}
