local function runRemote(func)
	rednet.send(_G.ME["computerId"], sfunc.serialize(func),"ME:" .. _G.ME["sendPort"])
	local _, msg, _ = rednet.receive("MEsent:" .. _G.ME["sendPort"],1)
	return msg["aa"], msg["ab"], msg["ac"], msg["ad"], msg["ae"], msg["af"], msg["ba"], msg["bb"], msg["bc"], msg["bd"], msg["be"], msg["bf"], msg["ca"]
end

local function drawBox(_bgc,_x,_y,_dx,_dy, _str,_tc)
	if not _str then _str = " " end
	if not _tc then _tc = _bgc end
	local _w, _h = term.getSize()
	local _oldbg = term.getBackgroundColor()
	local _oldtc = term.getTextColor()
	local _oldcb = term.getCursorBlink()
	local _oldposx, _oldposy = term.getCursorPos()
	if not _dx then _dx = _w end
	if not _dy then _dy = _h end
	if _x<0 then _x = _w+_x+1 end
	if _y<0 then _y = _h+_y+1 end
	if _dx<0 then _dx = _w+_dx+1 end
	if _dy<0 then _dy = _h+_dy+1 end
	term.setBackgroundColor(_bgc)
	term.setTextColor(_tc)
	for i=math.min(_x,_dx),math.max(_x,_dx) do
		for j=math.min(_y,_dy),math.max(_y,_dy) do
			term.setCursorPos(i,j)
			term.write(_str)
		end
	end
	term.setCursorPos(_oldposx, _oldposy)
	term.setBackgroundColor(_oldbg)
	term.setTextColor(_oldtc)
	term.setCursorBlink(_oldcb)
end

local function writeText(_text,_cbg,_ct,_x,_y)
	local _w, _h = term.getSize()
	local _oldbg = term.getBackgroundColor()
	local _oldcb = term.getCursorBlink()
	local _oldc = term.getTextColor()
	local _oldposx, _oldposy = term.getCursorPos()
	if not _x then _x = _oldposx end
	if not _y then _y = _oldposy end
	if _x<0 then _x = _w+_x+1 end
	if _y<0 then _y = _h+_y+1 end
	term.setBackgroundColor(_cbg)
	term.setTextColor(_ct)
	term.setCursorPos(_x,_y)
	term.write(_text)
	term.setCursorPos(_oldposx, _oldposy)
	term.setBackgroundColor(_oldbg)
	term.setCursorBlink(_oldcb)
	term.setTextColor(_oldc)
end

local function refresh(network, chests, items, transferInventory)
	drawBox(colors.white,1,2,width,2)
	term.setCursorBlink(false)
	writeText("Refreshing...", colors.white,colors.black,1,2)
	rednet.send(_G.ME["computerId"], "refresh","ME:" .. _G.ME["sendPort"])
	local _, msg, _ = rednet.receive("MEsent:" .. _G.ME["sendPort"])
	term.setCursorBlink(true)
	local items, chests, storageMax, storageUsed, itemdisplay = msg.a, msg.b, msg.c, msg.d, msg.e
	return items, chests, storageMax, storageUsed, itemdisplay
end

local function sort(network, chests, items, transferInventory)
	drawBox(colors.white,1,2,width,2)
	term.setCursorBlink(false)
	writeText("Sorting and refreshing...", colors.white,colors.black,1,2)
	rednet.send(_G.ME["computerId"], "sort","ME:" .. _G.ME["sendPort"])
	local _, msg, _ = rednet.receive("MEsent:" .. _G.ME["sendPort"])
	term.setCursorBlink(true)
	local items, chests, storageMax, storageUsed, itemdisplay = msg.a, msg.b, msg.c, msg.d, msg.e
	return items, chests, storageMax, storageUsed, itemdisplay
end

local function push(network, chests, items, transferInventory)
	drawBox(colors.white,1,2,width,2)
	term.setCursorBlink(false)
	writeText("Pushing and refreshing...", colors.white,colors.black,1,2)
	rednet.send(_G.ME["computerId"], "pushremote","ME:" .. _G.ME["sendPort"])
	local _, msg, _ = rednet.receive("MEsent:" .. _G.ME["sendPort"])
	term.setCursorBlink(true)
	local items, chests, storageMax, storageUsed, itemdisplay = msg.a, msg.b, msg.c, msg.d, msg.e
	return items, chests, storageMax, storageUsed, itemdisplay
end

function drawBlankScreen()
	if _G.ME["prOpen"] then
			-- Draw box
		drawBox(colors.white,7,3,-7,3,"\131",colors.lightGray)
		drawBox(colors.white,7,4,-7,-2)
		writeText("Amount:", colors.white,colors.black,8,4)

			-- Draw "Confirm" box
		drawBox(colors.green,8,-4,16,-4,"\143",colors.white)
		drawBox(colors.green,8,-3,16,-3)
		drawBox(colors.white,8,-2,16,-2,"\131",colors.green)
		writeText("Confirm", colors.green,colors.white,9,-3)

			-- Draw "Cancel" box
		drawBox(colors.red,-8,-4,-15,-4,"\143",colors.white)
		drawBox(colors.red,-8,-3,-15,-3)
		drawBox(colors.white,-8,-2,-15,-2,"\131",colors.red)
		writeText("Cancel", colors.red,colors.white,-14,-3)


	else
		drawBox(colors.gray,1,4,width,height)
		drawBox(colors.lightBlue,1,1,width,1)
		drawBox(colors.white,1,2,width,2)
		drawBox(colors.lightGray,1,3,width,3)
		writeText("Count", colors.lightGray,colors.white,-7,3)
		writeText("Item", colors.lightGray,colors.white,2,3)
	end
end

function loop(network, chests, items, itemdisplay, transferInventory, storageUsed, storageMax)
	local width, height = term.getSize()
	local usedtext = ""..storageUsed.."/"..storageMax.." used"

	term.setCursorBlink(false)

	-- Draw top menu
	writeText(usedtext, colors.blue,colors.white,-#usedtext,1)
	writeText(" Refresh ", colors.red,colors.white,1,1)
	writeText(" Sort ", colors.green,colors.white,10,1)
	writeText(" Push ", colors.magenta,colors.white,16,1)
	--drawBox(colors.green,8,1,8,1,"\149",colors.red)
	--drawBox(colors.magenta,13,1,13,1,"\149",colors.green)
	--drawBox(colors.lightBlue,18,1,18,1,"\149",colors.magenta)

	-- Draw the line
	--drawBox(colors.white,-9,3,-9,height)

	-- Type item names and counts
	if _G.ME["searchSelected"] then
		drawBox(colors.blue,1,_G.ME["searchSelected"]+3,-1,_G.ME["searchSelected"]+3)
	end
	if not _G.ME["prOpen"] then
	_G.ME["displayedItems"] = {}
	local i = 3
	local sScroll = 0
	_G.ME["searchScrollMax"] = 0
	for item, count in pairs(itemdisplay) do
		if string.match(string.lower(item), string.lower(_G.ME["searchString"])) then
			sScroll = sScroll + 1
			_G.ME["searchScrollMax"] = _G.ME["searchScrollMax"] + 1
			if sScroll >= _G.ME["searchScroll"] then
				i=i+1
				if i>width then break end
				_G.ME["displayedItems"][i] = item
				local itemsub
				if #item<width-10 then
					itemsub = item:sub(1,width-11)
				else
					itemsub = item:sub(1,width-14).."..."
				end
				if i-3==_G.ME["searchSelected"] then
					writeText(itemsub, colors.blue,colors.white,2,i)
					writeText(tostring(count), colors.blue,colors.white,-7,i)
				else
					writeText(itemsub, colors.gray,colors.white,2,i)
					writeText(tostring(count), colors.gray,colors.white,-7,i)
				end
			end
		end
	end
	-- Display search text
	writeText(_G.ME["searchString"], colors.white,colors.black,1,2)
	if not _G.ME["prOpen"] then
	term.setCursorPos(#_G.ME["searchString"]+1,2)
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	term.setCursorBlink(true)
	end
	end

	-- Display "count" dialog box
	if _G.ME["prOpen"] then
		-- Draw input box
	drawBox(colors.gray,8,6,-8,6,"\131",colors.white)
	drawBox(colors.gray,8,7,-8,7)
	drawBox(colors.white,8,8,-8,8,"\143",colors.gray)

	writeText(_G.ME["amountString"], colors.gray,colors.white,9,7)
	term.setCursorPos(#_G.ME["amountString"]+9,7)
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	term.setCursorBlink(true)
	end


	-- Wait for events
	local _ev, _btn, _clix, _cliy, _char, _key, _held
	parallel.waitForAny(
		function()
			_ev, _btn, _clix, _cliy = os.pullEvent( "mouse_click" )
		end,
		function()
			_ev, _char = os.pullEvent( "char" )
		end,
		function()
			_ev, _key, _held = os.pullEvent( "key" )
		end,
		function()
			_ev, _scrolld, _, _ = os.pullEvent( "mouse_scroll" )
		end,
		function() sleep(0.05) end
	)

	-- Handle scrolling
	if _ev=="mouse_scroll" then
		_G.ME["searchSelected"] = nil
		_G.ME["searchScrollMax"] = _G.ME["searchScrollMax"] - height + 4
		if not _G.ME["prOpen"] then
			if (_G.ME["searchScroll"] + _scrolld) <= _G.ME["searchScrollMax"] and (_G.ME["searchScroll"] + _scrolld) >= 1 then
				_G.ME["searchScroll"] = _G.ME["searchScroll"] + _scrolld
			end
		end
		drawBlankScreen()
	end

	-- Handle typing
	if _ev=="char" then
		if not _G.ME["prOpen"] then
			if string.match(_char,"^[0-9]+$") then
				if _char=="1" then items, chests, storageMax, storageUsed, itemdisplay = refresh(network, chests, items, transferInventory) end
				if _char=="2" then items, chests, storageMax, storageUsed, itemdisplay = sort(network, chests, items, transferInventory) end
				if _char=="3" then items, chests, storageMax, storageUsed, itemdisplay = push(network, chests, items, transferInventory) end
			else
				if #_G.ME["searchString"]<width-10 then
					_G.ME["searchString"] = _G.ME["searchString"] .. _char
					_G.ME["searchScroll"] = 1
				end
			end
		elseif string.match(_char,"^[0-9]+$") then
			if #_G.ME["amountString"]<width-16 then
				_G.ME["amountString"] = _G.ME["amountString"] .. _char
				_G.ME["amountScroll"] = 1
			end
		end
		drawBlankScreen()
	end

	-- Handle deleting
	if _ev=="key" then
		if not (
		_key == keys.up or
		_key == keys.down or
		_key == keys.enter) then
			_G.ME["searchSelected"] = nil
		end
		if _key==keys.backspace then
			if not _G.ME["prOpen"] then
				if #_G.ME["searchString"]>0 then
					_G.ME["searchString"] = _G.ME["searchString"]:sub(1,#_G.ME["searchString"]-1)
					_G.ME["searchScroll"] = 1
				end
			else
				if #_G.ME["amountString"]>0 then
					_G.ME["amountString"] = _G.ME["amountString"]:sub(1,#_G.ME["amountString"]-1)
					_G.ME["amountScroll"] = 1
				end
			end
		end
		if _key==keys.up and not _G.ME["prOpen"] then
			if _G.ME["searchSelected"] then
				if (_G.ME["searchSelected"] - 1) <= sitems.sizeOfTable(_G.ME["displayedItems"]) and (_G.ME["searchSelected"] - 1) >= 1 then
					_G.ME["searchSelected"] = _G.ME["searchSelected"] - 1
				end
			else _G.ME["searchSelected"] = 1 end
		end
		if _key==keys.down and not _G.ME["prOpen"] then
			if _G.ME["searchSelected"] then
				if (_G.ME["searchSelected"] + 1) <= sitems.sizeOfTable(_G.ME["displayedItems"]) and (_G.ME["searchSelected"] + 1) >= 1 then
					_G.ME["searchSelected"] = _G.ME["searchSelected"] + 1
				end
			else _G.ME["searchSelected"] = 1 end
		end
		if _key==keys.enter then
			if not _G.ME["prOpen"] then
				for ypos, itemname in pairs(_G.ME["displayedItems"]) do
					if ypos-3==_G.ME["searchSelected"] then
						_G.ME["amountString"] = ""
						_G.ME["prOpen"] = true
						_G.ME["prSelected"] = itemname
						_G.ME["searchSelected"] = nil
					end
				end
			else
				if tonumber(_G.ME["amountString"]) then
					if tonumber(_G.ME["amountString"])==0 then _G.ME["prOpen"] = false else
					term.setCursorBlink(false)
					writeText("Retrieving and Refreshing...", colors.white,colors.black,1,2)
					rednet.send(_G.ME["computerId"], "getremote " .. _G.ME["prSelected"] .. " " .. string.sub("  " .. _G.ME["amountString"], -2, -1),"ME:" .. _G.ME["sendPort"])
					local _, msg, _ = rednet.receive("MEsent:" .. _G.ME["sendPort"])
					_G.ME["prOpen"] = false
					term.setCursorBlink(true)
					items, chests, storageMax, storageUsed, itemdisplay = msg.a, msg.b, msg.c, msg.d, msg.e
					end
				end
			end
		end
		drawBlankScreen()
	end

	-- Handle clicking
	if _ev=="mouse_click" and _btn==1 then
		_G.ME["searchSelected"] = nil
		-- First row
		if _cliy==1 and not _G.ME["prOpen"] then
			-- "Refresh" button
			if _clix>=1 and _clix<=9 then
				items, chests, storageMax, storageUsed, itemdisplay = refresh(network, chests, items, transferInventory)
			end
			-- "Sort" button
			if _clix>=10 and _clix<=15 then
				items, chests, storageMax, storageUsed, itemdisplay = sort(network, chests, items, transferInventory)
			end
			-- "Push" button
			if _clix>=16 and _clix<=21 then
				items, chests, storageMax, storageUsed, itemdisplay = push(network, chests, items, transferInventory)
			end
		end
		if not _G.ME["prOpen"] and _cliy>=4 then
			for ypos, itemname in pairs(_G.ME["displayedItems"]) do
				if _cliy==ypos then
					_G.ME["amountString"] = ""
					_G.ME["prOpen"] = true
					_G.ME["prSelected"] = itemname
				end
			end
		end

		-- Amount dialog buttons
		if _G.ME["prOpen"] and _cliy==height-2 then
			-- "Confirm" button
			if _clix>=8 and _clix<=16 and tonumber(_G.ME["amountString"]) then
				if tonumber(_G.ME["amountString"])==0 then _G.ME["prOpen"] = false else
				term.setCursorBlink(false)
				writeText("Retrieving and Refreshing...", colors.white,colors.black,1,2)
				rednet.send(_G.ME["computerId"], "getremote " .. _G.ME["prSelected"] .. " " .. string.sub("  " .. _G.ME["amountString"], -2, -1),"ME:" .. _G.ME["sendPort"])
				local _, msg, _ = rednet.receive("MEsent:" .. _G.ME["sendPort"])
				_G.ME["prOpen"] = false
				term.setCursorBlink(true)
				items, chests, storageMax, storageUsed, itemdisplay = msg.a, msg.b, msg.c, msg.d, msg.e
				end
			end

			-- "Cancel" button
			if _clix>=width-14 and _clix<=width-7 then
				_G.ME["prOpen"] = false
			end
		end
		drawBlankScreen()
	end
	_ev, _btn, _clix, _cliy = nil, nil, nil, nil
	_key, _held, _char = nil, nil, nil
	return chests, items, itemdisplay, storageMax, storageUsed
end


