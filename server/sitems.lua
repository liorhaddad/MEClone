function findInTable(table, check)
	for key, value in pairs(table) do
		if value==check then
			return key
		end
	end
	return nil
end

function sizeOfTable(table)
	local size = 0
	for key, value in pairs(table) do
		size=size+1
	end
	return size
end

function loadChests(network, transferInventory)
	local chests = {}
	local storageMax = 0
	local storageUsed = 0
	local i=0
	for _, _in in pairs(network.getNamesRemote()) do
		if string.match(_in,"chest") and _in~=transferInventory then
			i=i+1
			chests[i] = {}
			chests[i].name = _in
			chests[i].items = network.callRemote(_in,"list")
			chests[i].size = network.callRemote(_in,"size")
			chests[i].used = sitems.sizeOfTable(chests[i].items)
			chests[i].meta = network.callRemote(_in,"getMetadata")
			storageMax = storageMax + chests[i].size
			storageUsed = storageUsed + chests[i].used
		end
	end
	return chests, storageMax, storageUsed
end

function loadItems(network, chests)
	local items = {}
	local i=0
	for _, _c in pairs(chests) do
		for _slot, _item in pairs(network.callRemote(_c.name,"list")) do
			i=i+1
			local _itemmeta = network.callRemote(_c.name,"getItemMeta",_slot)
			items[i] = {}
			items[i].chest = _c.name
			items[i].slot = _slot
			items[i].item = _item
			items[i].meta = _itemmeta
			items[i].name = _itemmeta.displayName
			items[i].count = _itemmeta.count
		end
	end
	return items
end

function loadIDisplay(items)
	if items == nil then
		error("Usage: sitems.loadIDisplay(items)")
	end
	local itemdisplay = {}
	for _, item in pairs(items) do
		local loc = itemdisplay[item.name]
		if loc then
			loc = item.name
			itemdisplay[loc] = itemdisplay[loc] + item.count
		else
			loc = item.name
			itemdisplay[loc] = item.count
		end
	end
	return itemdisplay
end

function get(network, chests, transferInventory, items, a, b, c)
	if network == nil then
		error("Gets an item from the chests.\nUsage: sitems.get(network, chests, transferInventory, items, item [, limit] [, toSlot]) OR\nsitems.get(network, chests, items, name [, limit] [, toSlot])")
	end
	if type(a)=="table" then
		local item = a
		local limit = b
		local toSlot = c
		local ccc
		if limit and limit<1 then return false end
		network.callRemote(item.chest,"pushItems",transferInventory,item.slot,limit,toSlot)
		for _k, _v in pairs(chests) do
		if _v.name==item.chest then
			ccc = _k
		end
		end
		chests[ccc].used = chests[ccc].used - 1

		for _k, _v in pairs(items) do
			if _v==item then
				items[_k] = nil
				break
			end
		end
		return items, chests, item.count



	elseif type(a)=="string" then
			local name = a
			local limit = b
			local toSlot = c
			local gCount = limit
			local e = 0
			local tra = 0
			local ccc
			if type(gCount)=="number" and (gCount<0 or gCount>2147483647) then gCount=nil end
			if limit and limit<1 then return false end
			for pos, item in pairs(items) do
				if item.name==name and (not gCount or gCount>0) then
					tra = network.callRemote(item.chest,"pushItems",transferInventory,item.slot,gCount,toSlot)
					if gCount then gCount = gCount - tra else e=e+tra end
					for _k, _v in pairs(chests) do
						if _v.name==item.chest then
							ccc = _k
						end
					end
					items[pos].count = items[pos].count - tra
					if items[pos].count<=0 then
						items[pos] = nil
						chests[ccc].used = chests[ccc].used - 1
					else
						items[pos].meta.count = items[pos].count
					end
				end
			end
			if gCount then
				return items, chests, (limit-gCount)
			else
				return items, chests, e
			end


	else return false end
end

function send(network, chests, transferInventory, slot, limit)
	if network == nil then
		error("Sends an item into the chests.\nUsage: sitems.send(network, chests, transferInventory [, slot] [, limit])")
	end
	if (not slot) and (turtle) then slot=turtle.getSelectedSlot() end
	if (not slot) and (not turtle) then slot=1 end
	for pos, chest in pairs(chests) do
		if chest.used < chest.size then
			local tra = network.callRemote(chest.name,"pullItems",transferInventory,slot,limit)
			chests[pos].used = chests[pos].used + 1
			return chests, tra
		end
	end
end

function combine(network, chests, transferInventory, items)
	if network == nil then
		error("Combines all items in all chests.\nUsage: sitems.combine(network, chests, transferInventory, items)")
	end
	for _, item in pairs(items) do
		items, chests, _ = get(network, chests, transferInventory, items, item)
		chests, _ = send(network, chests, transferInventory, 1)
	end
	items = loadItems(network, chests)
	return chests, items
end
