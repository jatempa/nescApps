#include "DataToRadio.h"

configuration DataToRadioApp {}

implementation {
	components MainC;
	components new Intersema5534C();
	components new SensirionSht11C();
	components ActiveMessageC;
	components new AMSenderC(AM_DATATORADIOMSG);
	components DataToRadioC as App;
	components new TimerMilliC() as TimerSense;
	
	App.Boot -> MainC;
	App.AMSend -> AMSenderC;
	App.SplitControl -> ActiveMessageC;
	App.TimerSense -> TimerSense;
	App.Temperature -> Intersema5534C.Intersema;
	App.Humidity -> SensirionSht11C.Humidity;
}