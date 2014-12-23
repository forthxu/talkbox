local skynet = require "skynet"
--local redis = require "redis"
local netpack = require "netpack"
local socket = require "socket"
p=require("p.core")

local CMD = {}
local protobuf = {}
local auto_id=0
local talk_users={}
local client_fds={}

function print_r(table,str,r,k,n)
	local str =  str or ' '--分割符号
	local n =  n or 0--分割符号数量
	local k =  k or ''--KEY值
	local r =  r or false--是否返回，否则为打印
	
	local tab = ''	
	local val_str = ''

	tab = string.rep(str,n)
	
	if type(table) == "table" then
		n=n+1
		val_str = val_str..tab..k.."={"		
		for k,v in pairs(table) do
			if type(v) == "table" then
				val_str = val_str.."\n"..print_r(v,str,true,k,n)
			else
				val_str = val_str..k..'='..tostring(v)..','
			end
		end
		if string.sub(val_str,-1,-1) == "," then
			val_str = string.sub(val_str,1,-2)
			val_str = val_str..' '.."}"
		else
			val_str = val_str.."\n"..tab..' '.."}"
		end
	else
		val_str = val_str..tab..k..tostring(table)
	end
	
	if r then
		return val_str
	else
		print(val_str)
	end
end

function CMD.createUser(client_fd,talk_create)
	local createUserInfo = protobuf.decode("talkbox.talk_create",talk_create)

	if createUserInfo==false then
		return protobuf.encode("talkbox.talk_result",{id=1})--解析protocbuf错误
	end
	
	if isUser(createUserInfo.name) then
		return protobuf.encode("talkbox.talk_result",{id=2})--已经存在该名字
	end
	
	auto_id=auto_id+1
	
	local userInfo = {
		userid = auto_id,
		name = createUserInfo.name,
	}
	
	local data_UserInfo = protobuf.encode("talkbox.talk_create", userInfo)

	talk_users[userInfo.userid]=userInfo
	
	for userid in pairs(client_fds) do
		new_users = protobuf.encode("talkbox.talk_users",{['users']={userInfo}})
		socket.write(client_fds[userid], netpack.pack(p.pack(1,1002,new_users)))
	end
	
	client_fds[userInfo.userid]=client_fd;
	
	socket.write(client_fds[userInfo.userid], netpack.pack(p.pack(1,1008,data_UserInfo)))
	
	return protobuf.encode("talkbox.talk_result",{id=0})
end

function CMD.sentMsg(talk_message)
	local message = protobuf.decode("talkbox.talk_message",talk_message)
	
	if message==false then
		return protobuf.encode("talkbox.talk_result",{id=3})--解析protocbuf错误
	end
	
	if message.touserid==-1 then
		for userid in pairs(client_fds) do
			socket.write(client_fds[userid], netpack.pack(p.pack(1,1010,talk_message)))
		end
	else
		socket.write(client_fds[message.touserid], netpack.pack(p.pack(1,1010,talk_message)))
	end
	
	return protobuf.encode("talkbox.talk_result",{id=4})
end

function CMD.getUsers(msg)
	local users={}
	for userid in pairs(talk_users) do
		table.insert(users,talk_users[userid])
	end
	
	return protobuf.encode("talkbox.talk_users",{['users']=users})
end

function CMD.rmUser(client_fd)
	for userid in pairs(client_fds) do
		
		if client_fds[userid]==client_fd then
			for userid2 in pairs(client_fds) do
				socket.write(client_fds[userid2], netpack.pack(p.pack(1,1011,protobuf.encode("talkbox.talk_result",{id=userid}))))
			end
			
			talk_users[userid]=nil
			client_fds[userid]=nil
			
		end
	end
end

function isUser(name)
	for userid in pairs(talk_users) do
		if talk_users[userid].name==name then
			return true
		end
	end

	return false
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = CMD[cmd]
		
		skynet.ret(skynet.pack(f(...)))
	end)

	protobuf = require "protobuf"
	local player_data = io.open("../res/talkbox.pb","rb")
	local buffer = player_data:read "*a"
	player_data:close()
	protobuf.register(buffer)
	
	skynet.register "talkbox"
end)
