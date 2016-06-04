COMPONENT=DataToRadioApp
CFLAGS += -DCC2420_DEF_CHANNEL=15
CFLAGS += -DRF230_DEF_CHANNEL=15

TOSMAKE_PRE_EXE_DEPS = DataMsg.java
TOSMAKE_CLEAN_EXTRA = $(BULID_EXTRA_DEPS)

DataMsg.java: DataToRadio.h
		nescc-mig -java-classname=DataMsg java DataToRadio.h datatoradiomsg -o $@

TINYOS_ROOT_DIR?=../../..
include $(TINYOS_ROOT_DIR)/Makefile.include
$(call TOSMake_include_sensor,mts400)