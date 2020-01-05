settings.set("bios.use_multishell", true)
os.loadAPI("/disk/sitems.lua")
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorBlink(false)
term.setCursorPos(1,1)
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
local isTurtle, modemSide, transferInventory = dofile("/disk/settings.txt")

local network = peripheral.wrap(modemSide)

if transferInventory==nil then transferInventory=network.getNameLocal() end

print("[System] Loading containers...")

local chests, storageMax, storageUsed = sitems.loadChests(network, transferInventory)

print("[System] Finished loading containers")
print("[System] Getting items...")

local items = sitems.loadItems(network, chests)
local itemdisplay = sitems.loadIDisplay(items)

print("[System] Finished getting items")

_G.ME = {}
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
	if not _G.ME["newparams"] then
		_G.ME["params"] = {
			network = network,
			chests = chests,
			items = items,
			itemdisplay = itemdisplay,
			storageUsed = storageUsed,
			storageMax = storageMax,
			transferInventory = transferInventory
		}
	else
		_G.ME["params"] = _G.ME["newparams"]
		_G.ME["newparams"] = nil
	end
	chests, items, itemdisplay, storageMax, storageUsed = gfx.loop(network, chests, items, itemdisplay, transferInventory, storageUsed, storageMax)
end


return items, itemdisplay, chests