#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

// cc -g -O2 -Wall -I3rd/lua   -fPIC --shared lualib-src/lua-bson.c -o luaclib/bson.so -Iskynet-src
static int _add(lua_State *L)
{
	int a,b,c;
	a = lua_tonumber(L,1);
	b = lua_tonumber(L,2);
	c = a+b;
	
	lua_newtable(L);//新建table
	
	lua_pushstring(L,"key");//压入key
	lua_pushstring(L,"value");//压入value
	lua_settable(L,-3);//设置*-3[*-2]=*-1并弹出*-1 *-2
	
	lua_pushstring(L,"sub_array");//压入key
	//压入value(也是一个table){
		lua_newtable(L);//新建table
		
		lua_pushnumber(L,c);//压入value
		lua_rawseti(L,-2,1); //设置*-2[0]=*-1并弹出*-1
		
		lua_pushnumber(L,a);
		lua_rawseti(L,-2,2);
	//}
	lua_settable(L,-3);//设置
	
	printf("test hello!!!\r\n");
	return 1;
}

void Convert(int n, unsigned int radix)
{
	if (n < 0 && radix == 10)			 
	{							 
		putchar('-');
		n = -n;							 
	}
	n = (unsigned int)n;												 
	if (n / radix)						 
	{
		Convert(n / radix, radix);		 
	}
	if (n % radix > 9)													 
		putchar(n % radix - 10 + 'a');  
	else 
		putchar(n % radix + '0');								 								 
}

static int _unpack(lua_State *L)
{
	uint16_t v;
	uint32_t p;
	const char * data;
	const char * msg;
	size_t size;
	
	uint8_t * buffer=malloc(6);
	
	data = luaL_checklstring(L, 1, &size);
	
	memcpy(buffer, data, 6);
	msg = data+6;

	v = buffer[0] << 8 | buffer[1];
	p = (buffer[2] << 24) | (buffer[3] << 16) | (buffer[4] << 8) | buffer[5];
	
	
	// Convert(buffer[2], 2);printf("\n\n");
	// Convert(buffer[3], 2);printf("\n\n");
	// Convert(buffer[4], 2);printf("\n\n");
	// Convert(buffer[5], 2);printf("\n\n");
	// printf("version:%u protocol:%u size:%zu msg:%s\r\n",v,p,size-6,msg);
	// Convert(p, 2);printf("\n\n");
	
	lua_newtable(L);//新建table
	
	lua_pushstring(L,"v");//压入key
	lua_pushinteger(L,v);//压入value
	lua_settable(L,-3);//设置*-3[*-2]=*-1并弹出*-1 *-2
	
	lua_pushstring(L,"p");//压入key
	lua_pushinteger(L,p);//压入value
	lua_settable(L,-3);//设置*-3[*-2]=*-1并弹出*-1 *-2
	
	lua_pushstring(L,"msg");//压入key
	lua_pushstring(L,msg);//压入value
	lua_settable(L,-3);//设置*-3[*-2]=*-1并弹出*-1 *-2
	return 1;
}

static int _pack(lua_State *L)
{
	uint16_t v;
	uint32_t p;
	const char * msg;
	size_t size;
	uint8_t * buffer;
	
	v = luaL_checkinteger(L, 1);
	p = luaL_checkinteger(L, 2);
	msg = luaL_checklstring(L, 3, &size);
	if (size > 0x10000) {//2^16bit=2byte
		return luaL_error(L, "Invalid size (too long) of data : %d", (int)size);
	}
	
	// printf("version:%u protocol:%u size:%zu msg:%s\r\n",v,p,size,msg);
	
	buffer = malloc(size+6);
	
	buffer[0] = (v >> 8) & 0xff;
	buffer[1] = v & 0xff;
	
	buffer[2] = (p >> 24) & 0xff;
	buffer[3] = (p >> 16) & 0xff;
	buffer[4] = (p >> 8) & 0xff;
	buffer[5] = p & 0xff;
	
	
	memcpy(buffer+6, msg, size);
	lua_pushlstring(L, (const char *)buffer, size+6);
	return 1;
}

static const struct luaL_Reg lib[] =
{
	{"add",_add},
	{"pack",_pack},
	{"unpack",_unpack},
	{NULL,NULL}
};

int luaopen_p_core(lua_State *L)  // 注意这里的函数写法
{
	luaL_newlib(L,lib);
	return 1;
}