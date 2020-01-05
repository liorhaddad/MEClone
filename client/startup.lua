os.loadAPI("/disk/sitems.lua")
settings.set("bios.use_multishell", true)
--shell.openTab("rom/programs/advanced/multishell.lua")
--shell.openTab("rom/programs/advanced/multishell.lua")

local ver = tonumber(fs.open("/disk/.version","r").readAll()) fs.open("/disk/.version","r").close()
local newver = tonumber(sitems.gitget("client/.version"))
if newver and newver ~= ver then
	term.clear()
	term.setCursorPos(1,1)
	print("New version detected, currently downloading, please wait!")
	sitems.gitsave("cinstall.lua","/.cinstall")
	shell.run("/.cinstall")
	shell.run("delete /.cinstall")
	local cx, cy = term.getCursorPos()
	for i=1,10 do
		term.setCursorPos(cx, cy)
		term.clearLine()
		print("Rebooting in " .. tostring(11-i) .. " seconds")
		sleep(1)
	end
	os.reboot()
end


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
		sleep(1)
		term.setCursorPos(x-4,y)
		write("4")
		sleep(1)
		term.setCursorPos(x-4,y)
		write("3")
		sleep(1)
		term.setCursorPos(x-4,y)
		write("2")
		sleep(1)
		term.setCursorPos(x-4,y)
		write("1")
		sleep(1)
	end
end
