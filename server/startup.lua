local function refresh()
	local s = _G.ME["params"]
	s.items = sitems.loadItems(s.network, s.chests)
	s.chests, s.storageMax, s.storageUsed = sitems.loadChests(s.network, s.transferInventory)
	s.itemdisplay = sitems.loadIDisplay(s.items)
	_G.ME["newparams"] = s
	return {a=s.items, b=s.chests, c=s.storageMax, d=s.storageUsed, e=s.itemdisplay}
end

local function sort()
	local s = _G.ME["params"]
	sitems.combine(s.network, s.chests, s.transferInventory, s.items)
	s.chests, s.storageMax, s.storageUsed = sitems.loadChests(s.network, s.transferInventory)
	s.items = sitems.loadItems(s.network, s.chests)
	s.itemdisplay = sitems.loadIDisplay(s.items)
	_G.ME["newparams"] = s
	return {a=s.items, b=s.chests, c=s.storageMax, d=s.storageUsed, e=s.itemdisplay}
end

local function push()
	local s = _G.ME["params"]
	local maxMax
	if s.transferInventory==s.network.getNameLocal() then
		maxMax = 16
	else
		maxMax = s.network.callRemote(s.transferInventory,"size")
	end
	for i=1,maxMax do
		s.chests, _ = sitems.send(s.network, s.chests, s.transferInventory, i)
	end
	s.chests, s.storageMax, s.storageUsed = sitems.loadChests(s.network, s.transferInventory)
	s.items = sitems.loadItems(s.network, s.chests)
	s.itemdisplay = sitems.loadIDisplay(s.items)
	_G.ME["newparams"] = s
	return {a=s.items, b=s.chests, c=s.storageMax, d=s.storageUsed, e=s.itemdisplay}
end

local function get(gitem, gamount)
	local s = _G.ME["params"]
	s.items, s.chests, _ = sitems.get(s.network, s.chests, s.transferInventory, s.items, gitem, tonumber(gamount))
	s.chests, s.storageMax, s.storageUsed = sitems.loadChests(s.network, s.transferInventory)
	s.itemdisplay = sitems.loadIDisplay(s.items)
	_G.ME["newparams"] = s
	return {a=s.items, b=s.chests, c=s.storageMax, d=s.storageUsed, e=s.itemdisplay}
end

local function getremote(gitem, gamount)
	local s = _G.ME["params"]
	local intro = peripheral.wrap("bottom")
	local echest = intro.getEnder()
	s.items, s.chests, _ = sitems.get(s.network, s.chests, s.transferInventory, s.items, gitem, tonumber(gamount))
	if s.transferInventory==s.network.getNameLocal() then
		maxMax = 16
	else
		maxMax = s.network.callRemote(s.transferInventory,"size")
	end
	for i=1,maxMax do
		echest.pullItems("top",i)
	end
	s.chests, s.storageMax, s.storageUsed = sitems.loadChests(s.network, s.transferInventory)
	s.itemdisplay = sitems.loadIDisplay(s.items)
	_G.ME["newparams"] = s
	return {a=s.items, b=s.chests, c=s.storageMax, d=s.storageUsed, e=s.itemdisplay}
end

local function pushremote()
	local s = _G.ME["params"]
	local intro = peripheral.wrap("bottom")
	local echest = intro.getEnder()
	echest.pushItems("top",27)
	s.chests, _ = sitems.send(s.network, s.chests, s.transferInventory, 1)
	s.chests, s.storageMax, s.storageUsed = sitems.loadChests(s.network, s.transferInventory)
	s.items = sitems.loadItems(s.network, s.chests)
	s.itemdisplay = sitems.loadIDisplay(s.items)
	_G.ME["newparams"] = s
	return {a=s.items, b=s.chests, c=s.storageMax, d=s.storageUsed, e=s.itemdisplay}
end


settings.set("bios.use_multishell", true)
os.loadAPI("/disk/sfunc.lua")
os.loadAPI("/disk/sitems.lua")
--shell.openTab("rom/programs/advanced/multishell.lua")
--shell.openTab("rom/programs/advanced/multishell.lua")

local ver = tonumber(fs.open("/disk/.version","r").readAll()) fs.open("/disk/.version","r").close()
local newver = tonumber(sitems.gitget("server/.version"))
if newver and newver ~= ver then
	term.clear()
	term.setCursorPos(1,1)
	print("New version detected, currently downloading, please wait!")
	sitems.gitsave("sinstall.lua","/.sinstall")
	shell.run("/.sinstall")
	shell.run("delete /.sinstall")
	local cx, cy = term.getCursorPos()
	for i=1,10 do
		term.setCursorPos(cx, cy)
		term.clearLine()
		print("Rebooting in " .. tostring(11-i) .. " seconds")
		sleep(1)
	end
	os.reboot()
end

parallel.waitForAny(function()
	while not ok do
		ok, err = pcall(dofile,"/disk/init.lua")
		if not ok then
			term.setBackgroundColor(colors.blue)
			term.setTextColor(colors.white)
			term.setCursorBlink(false)
			term.clear()
			term.setCursorPos(1,1)
			print("An error has occurred!")
			print(err)
			write("Restarting in 5...")
			x, y = term.getCursorPos()
			term.setCursorPos(x-4,y)
			write("5")
			term.setCursorPos(1,y+1)
			sleep(1)
			term.setCursorPos(x-4,y)
			write("4")
			term.setCursorPos(1,y+1)
			sleep(1)
			term.setCursorPos(x-4,y)
			write("3")
			term.setCursorPos(1,y+1)
			sleep(1)
			term.setCursorPos(x-4,y)
			write("2")
			term.setCursorPos(1,y+1)
			sleep(1)
			term.setCursorPos(x-4,y)
			write("1")
			term.setCursorPos(1,y+1)
			sleep(1)
		end
	end
	end, function()
	sleep(10)
	local _, _, _, receivePort = dofile("/disk/settings.txt")
	ender = peripheral.wrap("front")
	rednet.open("front")
	ender.open(receivePort)
	os.loadAPI("/disk/sitems.lua")
	while true do
		id, msg, protocol = rednet.receive("ME:" .. receivePort)
		_G.ME.newparams = {}
		if msg=="getParams" then
			local s
			while not s or not type(s)=="table" do
				s = _G.ME["params"]
			end
			sleep(0.1)
			rednet.send(id, s, "MEsent:" .. receivePort)
		elseif msg=="refresh" then
			ret = refresh()
			sleep(0.1)
			rednet.send(id, ret, "MEsent:" .. receivePort)
		elseif msg=="sort" then
			ret = sort()
			sleep(0.1)
			rednet.send(id, ret, "MEsent:" .. receivePort)
		elseif msg=="push" then
			ret = push()
			sleep(0.1)
			rednet.send(id, ret, "MEsent:" .. receivePort)
		elseif msg:sub(1,4)=="get " then
			ret = get(msg:sub(5,-4),msg:sub(-2,-1))
			sleep(0.1)
			rednet.send(id, ret, "MEsent:" .. receivePort)
		elseif msg=="pushremote" then
			ret = pushremote()
			sleep(0.1)
			rednet.send(id, ret, "MEsent:" .. receivePort)
		elseif msg:sub(1,10)=="getremote " then
			ret = getremote(msg:sub(11,-4),msg:sub(-2,-1))
			sleep(0.1)
			rednet.send(id, ret, "MEsent:" .. receivePort)
		else
			local newfunc = sfunc.unserialize(msg)
			local aa, ab, ac, ad, ae, af, ba, bb, bc, bd, be, bf, ca = newfunc(_G.ME.params)
			local ret = {
				aa = aa,
				ab = ab,
				ac = ac,
				ad = ad,
				ae = ae,
				af = af,
				ba = ba,
				bb = bb,
				bc = bc,
				bd = bd,
				be = be,
				bf = bf,
				ca = ca
			}
			sleep(0.1)
			rednet.send(id, ret, "MEsent:" .. receivePort)
		end
		if _G.ME["newparams"]=={} then _G.ME["newparams"]=nil end
	end
end)