.PHONY : all clean

all :
	gcc -O2 -fPIC -Wall --shared -o protobuf.so -I../.. -I/usr/local/include -L/usr/local/bin -L../../build pbc-lua.c -lpbc -I../../../../skynet/3rd/lua/ 

51 :
#	gcc -O2 -Wall --shared -o protobuf.dll -I../.. -I/d/project/luajit-2.0/src -L/usr/local/bin -L../../build pbc-lua.c -lpbc -llua51
	gcc -O2 -Wall --shared -o protobuf.dll -I../.. -I/d/project/lua-5.1.4/src -L/usr/local/bin -L../../build pbc-lua.c -lpbc -llua51

clean :
	rm protobuf.so
