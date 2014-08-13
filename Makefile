
SHARED := -fPIC --shared
CFLAGS = -g -O2 -Wall -I$(LUA_INC)

PBC_PATH = ./3rd/pbc

SKYNET_PATH ?= skynet
LUA_INC ?= $(SKYNET_PATH)/3rd/lua
LUA_LIB_PATH ?= $(SKYNET_PATH)/lualib
LUA_CLIB_PATH ?= $(SKYNET_PATH)/luaclib
CSERVICE_PATH ?= $(SKYNET_PATH)/cservice

ALL_FILE = $(LUA_CLIB_PATH)/protobuf.so $(LUA_LIB_PATH)/protobuf.lua \
		   $(LUA_CLIB_PATH)/p.so $(LUA_LIB_PATH)/p.lua \
		   res/talkbox.pb \

all: $(SKYNET_PATH)/skynet pbc $(ALL_FILE)
	@:
	

# skynet

$(SKYNET_PATH)/skynet:
	git submodule update --init
	cd ./skynet && $(MAKE) linux

# pbc

pbc:
	cd $(PBC_PATH) && $(MAKE) "CFLAGS = -O2 -fPIC" lib

$(LUA_CLIB_PATH)/protobuf.so: $(PBC_PATH)/binding/lua/pbc-lua.c pbc $(SKYNET_PATH)/skynet
	gcc $(CFLAGS) $(SHARED) -o $@ -I$(PBC_PATH) -L$(PBC_PATH)/build -lpbc $<

$(LUA_LIB_PATH)/protobuf.lua: $(PBC_PATH)/binding/lua/protobuf.lua $(LUA_CLIB_PATH)/protobuf.so
	cp -f $< $@

res/talkbox.pb: res/talkbox.proto $(LUA_LIB_PATH)/protobuf.lua $(LUA_CLIB_PATH)/protobuf.so
	protoc -o $@ $<

$(LUA_CLIB_PATH)/p.so: ./3rd/p/lua-p.c
	gcc $(CFLAGS) $(SHARED) -o $@ $<

$(LUA_LIB_PATH)/p.lua: ./3rd/p/lua-p.c $(LUA_CLIB_PATH)/p.so
	cp -f $< $@

clean:
	rm -f $(ALL_FILE)

cleanall: clean
	cd $(PBC_PATH) && $(MAKE) clean
	cd $(SKYNET_PATH) && $(MAKE) clean

