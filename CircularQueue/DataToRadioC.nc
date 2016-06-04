#include "DataToRadio.h"

module DataToRadioC {
	uses interface Boot;
	uses interface SplitControl;
	uses interface Intersema as Temperature;
	uses interface Read<uint16_t> as Humidity;
	uses interface Timer<TMilli> as TimerSense;
	uses interface AMSend;
}

implementation { 
	// Queue Circular variables
	bool isFull();
	void insertQ(float item);
	void popQ();
   	int16_t sliding_window[MAXSIZE];
   	int8_t index = 0, front = 0, max = (MAXSIZE);
   	float sum = 0, t_ratio = 0, Temp_data = 0;
	message_t message;
	datatoradiomsg_t* packet;
	
	event void Boot.booted() {
		call SplitControl.start();
	}

	event void SplitControl.startDone(error_t error) {
	 	if(error==SUCCESS) {
	 		call TimerSense.startPeriodic(TIMER_PERIOD_MILLI);
	 	} else {
			call SplitControl.start();			
	 	}
	}

	event void SplitControl.stopDone(error_t error){}

	event void TimerSense.fired() {
		call Temperature.read();
	}

	event void Temperature.readDone(error_t error, int16_t *mesResult) {
		Temp_data = (mesResult[0]/10);
		if(isFull()) {
			t_ratio = (Temp_data / (sum / (float) max));
			if(t_ratio > 1.01) {
				call Humidity.read();
			} else {
				popQ();
				insertQ(Temp_data);
			}
		} else {
			insertQ(Temp_data);
		}
	}

	event void Humidity.readDone(error_t result, uint16_t val){
		packet = (datatoradiomsg_t*)(call AMSend.getPayload(&message, sizeof(datatoradiomsg_t)));
		packet-> NodeID = TOS_NODE_ID;
		packet-> Temp_data = Temp_data;
		packet-> Hum_data = val;
		call AMSend.send(AM_BROADCAST_ADDR, &message, sizeof(datatoradiomsg_t));
	}

	event void AMSend.sendDone(message_t *msg, error_t error){
		popQ();
		insertQ(Temp_data);
	}

    // Queue circular tasks
	bool isFull() {
		if (index == max) {
			return TRUE;
		} else {
			return FALSE;
		}
	}

	void insertQ(float item){
		int8_t position = (front + index) % max;
		sliding_window[position] = item;
		sum = sum + sliding_window[position];
		index++;
	}
    
    void popQ() {
    	sum = sum - sliding_window[front];
    	front = (front + 1) % max;
    	index--;
    }
}