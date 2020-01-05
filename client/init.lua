settings.set("bios.use_multishell", true)
_G.ME = {}
os.loadAPI("/disk/sfunc.lua")
os.loadAPI("/disk/sitems.lua")
os.loadAPI("/disk/gfx.lua")
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorBlink(false)
term.setCursorPos(1,1)
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
local modemSide, sendPort, computerId = dofile("/disk/settings.txt")

local network = peripheral.wrap(modemSide)
rednet.open(modemSide)
network.open(sendPort)


print("[System] Loading remote variables...")
_G.ME["params"] = {}
while _G.ME["params"].storageMax == nil do
	rednet.send(computerId, "getParams","ME:" .. sendPort)
	_, _G.ME["params"], _ = rednet.receive("MEsent:" .. sendPort,1)
end
local network = _G.ME["params"].network
local chests = _G.ME["params"].chests
local items = _G.ME["params"].items
local itemdisplay = _G.ME["params"].itemdisplay
local storageUsed = _G.ME["params"].storageUsed
local storageMax = _G.ME["params"].storageMax
local transferInventory = _G.ME["params"].transferInventory
sleep(1)
print("[System] Finished loading remote variables")

_G.ME["computerId"] = computerId
_G.ME["sendPort"] = sendPort
_G.ME["prOpen"] = false
_G.ME["prSelected"] = ""
_G.ME["amountString"] = ""
_G.ME["searchString"] = ""
_G.ME["searchScroll"] = 1
_G.ME["searchScrollMax"] = 255

os.loadAPI("/disk/gfx.lua")
gfx.drawBlankScreen()

while true do
	os.loadAPI("/disk/gfx.lua")
	_G.ME["params"] = {
		network = network,
		chests = chests,
		items = items,
		itemdisplay = itemdisplay,
		storageUsed = storageUsed,
		storageMax = storageMax,
		transferInventory = transferInventory
	}
	chests, items, itemdisplay, storageMax, storageUsed = gfx.loop(network, chests, items, itemdisplay, transferInventory, storageUsed, storageMax)
end


return items, itemdisplay, chests
