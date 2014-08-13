
SHARED := -fPIC --shared
CFLAGS = -g -O2 -Wall -I$(LUA_INC)

PBC_PATH = ./3rd/pbc
PBC_LIB = $(PBC_PATH)/build/libpbc.a

SKYNET_PATH ?= skynet
LUA_INC ?= $(SKYNET_PATH)/3rd/lua

LUA_LIB_PATH ?= $(SKYNET_PATH)/lualib
LUA_CLIB_PATH ?= $(SKYNET_PATH)/luaclib
CSERVICE_PATH ?= $(SKYNET_PATH)/cservice

RES_PATH = ./res

ALL_FILE = $(LUA_CLIB_PATH)/protobuf.so $(LUA_LIB_PATH)/protobuf.lua \
		   $(LUA_CLIB_PATH)/p.so \
		   $(RES_PATH)/talkbox.pb \

all: $(PBC_LIB) $(SKYNET_PATH)/skynet $(ALL_FILE)
	@:
	
# pbc

$(PBC_LIB):
	git submodule update --init
	cd $(PBC_PATH) && $(MAKE) lib "CFLAGS = -O2 -fPIC"

# skynet

$(SKYNET_PATH)/skynet: $(PBC_LIB)
	cd $(SKYNET_PATH) && $(MAKE) linux

# pbc-lua

$(LUA_CLIB_PATH)/protobuf.so: $(PBC_PATH)/binding/lua/pbc-lua.c
	gcc $(CFLAGS) $(SHARED) -o $@ -I$(PBC_PATH) $< $(PBC_LIB)

$(LUA_LIB_PATH)/protobuf.lua: $(PBC_PATH)/binding/lua/protobuf.lua $(LUA_CLIB_PATH)/protobuf.so
	cp -f $< $@

# pack

$(LUA_CLIB_PATH)/p.so: ./3rd/p/lua-p.c
	gcc $(CFLAGS) $(SHARED) -o $@ $<

# proto file

$(RES_PATH)/talkbox.pb: $(RES_PATH)/talkbox.proto
	protoc -o $@ $<

clean:
	rm -f $(ALL_FILE)

cleanall: clean
	cd $(PBC_PATH) && $(MAKE) clean
	cd $(SKYNET_PATH) && $(MAKE) clean

