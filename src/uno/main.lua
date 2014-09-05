local skynet = require "skynet"

local max_client = 64

--增加读取lua文件的路径
package.path = string.format("%s;%s?.lua;",   package.path, "./center/")

skynet.start(function()
	print("Server start")
	skynet.newservice("center")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 10101,
		maxclient = max_client,
	})

	skynet.exit()
end)
