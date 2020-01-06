function gitget(filelocation)
	local site = http.get("https://raw.githubusercontent.com/liorhaddad/MEClone/master/" .. filelocation)
	if not (site == nil) then
		local sitetext = site.readAll()
		site.close()
		return sitetext
	else
		return
	end
end

function gitsave(gitlocation,filelocation)
	local site = http.get("https://raw.githubusercontent.com/liorhaddad/MEClone/master/" .. gitlocation)
	local sitetext = site.readAll()
	site.close()
	local file = fs.open(filelocation,"w")
	file.flush()
	file.write(sitetext)
	file.close()
	return sitetext
end
print("Client updating test")
gitsave("client/.version","/disk/.version")