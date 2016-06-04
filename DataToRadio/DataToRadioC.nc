#include "DataToRadio.h"

module DataToRadioC{
	uses {	
		interface Boot;
		interface SplitControl;
		interface Intersema as Temperature;
		interface Read<uint16_t> as Humidity;
		interface Timer<TMilli> as TimerSense;
		interface AMSend;
	}
}

implementation{ 
	int16_t Temp_data;
	message_t message;
	bool busy = FALSE;
	datatoradiomsg_t* packet;
	
	event void Boot.booted(){
		call SplitControl.start();
	}

	event void SplitControl.stopDone(error_t error){}

	event void SplitControl.startDone(error_t error){
		if(error==SUCCESS){
			call TimerSense.startPeriodic(TIMER_PERIOD_MILLI);
		}else{
			call SplitControl.start();			
		}
	}

	event void TimerSense.fired(){
		call Temperature.read();
	}

	event void Temperature.readDone(error_t error, int16_t *mesResult){
		Temp_data = mesResult[0];
		call Humidity.read();
	}

	event void Humidity.readDone(error_t result, uint16_t val){
		packet = (datatoradiomsg_t*)(call AMSend.getPayload(&message, sizeof(datatoradiomsg_t)));	
		
		packet-> NodeID = TOS_NODE_ID;
		packet-> Temp_data = Temp_data;
		packet-> Hum_data = val;	

		call AMSend.send(AM_BROADCAST_ADDR, &message, sizeof(datatoradiomsg_t));
	}

	event void AMSend.sendDone(message_t *msg, error_t error){}
}