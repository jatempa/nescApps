#ifndef DATATORADIOMSG_H
#define DATATORADIOMSG_H

enum{
  	AM_DATATORADIOMSG=1,
	TIMER_PERIOD_MILLI = 1024,
	MAXSIZE = 5,
};

typedef nx_struct datatoradiomsg{
	nx_int8_t NodeID;				
	nx_int16_t Temp_data;	
	nx_uint16_t Hum_data;
}datatoradiomsg_t;
#endif
