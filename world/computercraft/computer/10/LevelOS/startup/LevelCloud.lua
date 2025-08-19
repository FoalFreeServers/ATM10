os.sleep(1)

lOS.cloud = {conflicts={},lastSync=0,files={}}
local conflicts = lOS.cloud.conflicts
local function doSync()
	if not fs.exists("AppData") then
		fs.makeDir("AppData")
	end
	if not fs.exists("AppData/LevelCloud") then
		fs.makeDir("AppData/LevelCloud")
	end

	if not fs.exists("LevelOS/Global_Login.lua") then
		local f = fs.open("LevelOS/Global_Login.lua","w")
		f.writeLine("LevelOS.maximize()")
		f.writeLine("lOS.userID = nil")
		f.writeLine("lOS.username = nil")
		f.writeLine("while not lOS.userID do lOS.userID,lOS.username = dofile('LevelOS/login.lua') end")
		f.close()
	end


	local userID = lOS.userID
	local username = lOS.username
	if not lOS.cloudLog then
		lOS.cloudLog = {}
	end
	local l = lOS.cloudLog


	local function login()
		lOS.userID = nil
		lOS.username = nil
		local oT = {}
		local w,h = term.getSize()
		for t=1,h do
			oT[t] = {term.current().getLine(t)}
		end
		local oC = {term.getCursorPos()}
		local oTxt = term.getTextColor()
		local oBg = term.getBackgroundColor()
		lOS.execute("LevelOS/Global_Login.lua")
		local txt = "Login expired!"
		while not lOS.userID do
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.red)
			local w,h = term.getSize()
			term.clear()
			term.setCursorPos(math.ceil(w/2)-math.floor(#txt/2),math.ceil(h/2))
			term.write(txt)
			os.pullEvent()
		end
		for t=1,h do
			term.setCursorPos(t,1)
			term.blit(unpack(oT[t]))
		end
		term.setCursorPos(unpack(oC))
		term.setTextColor(oTxt)
		term.setBackgroundColor(oBg)
		userID,username = lOS.userID,lOS.username
	end

	if not lOS.username then
		lOS.notification("LevelCloud","No username found")
		login()
	end

	while not userID or not username do
		lOS.notification("LevelCloud","No userID found")
		login()
	end


	local md = "AppData/LevelCloud/"..username
	if not fs.exists(md) then
		fs.makeDir(md)
	end

	local function handleError(err)
		if err == "Unauthorized" then
			lOS.notification("LevelCloud","Login expired!")
			login()
			return true
		end
	end

	local function hpost(url,body)
		--print(...)
		--os.sleep(5)
		local a,err = http.post(url,body,{Cookie=lOS.userID})
		if not a then
			lOS.notification("LevelCloud","Error: "..tostring(err)..", cloud offline.")
			_G.debugRequest = {url,body,{Cookie=lOS.userID}}
			local skip
			while not a do
				skip = handleError(err)
				if skip then
					os.sleep(1)
				else
					os.sleep(20)
				end
				a,err = http.post(url,body,{Cookie=lOS.userID})
			end
			lOS.notification("LevelCloud","Back online.")
		end
		local r = a.readAll()
		function a.readAll()
			return r
		end
		a.close()
		return a
	end

	local function hget(url)
		local a,err = http.get(url,{Cookie=lOS.userID})
		if not a then
			lOS.notification("LevelCloud","Error: "..tostring(err)..", cloud offline.")
			_G.debugRequest = {url,{Cookie=lOS.userID}}
			local skip
			while not a do
				skip = handleError(err)
				if skip then
					os.sleep(1)
				else
					os.sleep(20)
				end
				a,err = http.get(url,{Cookie=lOS.userID})
			end
			lOS.notification("LevelCloud","Back online.")
		end
		local r = a.readAll()
		function a.readAll()
			return r
		end
		a.close()
		return a
	end

	local function download(pth,root,timestamp,log)
		local path = fs.combine(root,pth)
		local mpath = fs.combine(md,pth)
		lOS.cloud.files[path] = timestamp
		if fs.exists(path) and fs.exists(mpath) then
			local data = loadfile(mpath)()
			if data.downloaded < fs.attributes(path).modification then
				-- it has been modified, do not overwrite
				if timestamp > data.timestamp then
					-- there is a conflict
					-- handle conflict
					if not conflicts[path] then
						conflicts[path] = true
						--table.insert(l,{action="Conflict",timestamp=os.epoch("utc"),destination=pth})
						lOS.notification("LevelCloud","There are conflicting versions of "..fs.getName(pth))
					end
				end
				return false
			elseif data.timestamp == timestamp then
				-- nothing changed
				return false
			end
		elseif fs.exists(mpath) and not fs.exists(path) then
			--print(pth.." deleted.")
			lOS.cloud.files[path] = nil
			local f = hpost("https://os.leveloper.cc/cDelete.php","path="..textutils.urlEncode(pth)).readAll()
			fs.delete(mpath)
			table.insert(l,{action="Deleted",timestamp=os.epoch("utc"),destination=pth})
			return false,"Deleted",f
		end


		local f = hpost("https://os.leveloper.cc/cGet.php","path="..textutils.urlEncode(pth)).readAll()
		if f ~= "409" and f ~= "403" and f ~= "401" then
			lUtils.fwrite(fs.combine(root,pth),f)
			lUtils.fwrite(fs.combine(md,pth),"return {timestamp="..timestamp..",downloaded="..fs.attributes(fs.combine(root,pth)).modification.."}")
			if not log then
				table.insert(l,{action="Download",timestamp=os.epoch("utc"),destination=pth})
			end
			return true
		else
			return false
		end
	end


	local function upload(pth,root,tree)
		local path = fs.combine(root,pth)
		local mpath = fs.combine(md,pth)
		if fs.exists(path) then
			if tree[pth] and fs.exists(mpath) then
				local data = loadfile(mpath)()
				if data.downloaded < fs.attributes(path).modification then
					if tree[pth] > data.timestamp then
						--print("Server's "..tree[pth].." vs client's "..data.timestamp)
						return false
					end
					local f = hpost("https://os.leveloper.cc/cUpload.php","path="..textutils.urlEncode(pth).."&content="..textutils.urlEncode(lUtils.fread(path)).."&timestamp="..textutils.urlEncode(tostring(fs.attributes(path).modification))).readAll()
					if f == "200" then
						lOS.cloud.files[path] = os.epoch("utc")
						lUtils.fwrite(fs.combine(md,pth),"return {timestamp="..fs.attributes(path).modification..",downloaded="..fs.attributes(fs.combine(root,pth)).modification.."}")
						table.insert(l,{action="Upload",timestamp=os.epoch("utc"),destination=pth})
						return true
					else
						return false,f
					end
				end
			elseif not tree[pth] and not fs.exists(mpath) then
				--print("Scenario 2")
				local f = hpost("https://os.leveloper.cc/cUpload.php","path="..textutils.urlEncode(pth).."&content="..textutils.urlEncode(lUtils.fread(path)).."&timestamp="..textutils.urlEncode(tostring(fs.attributes(path).modification))).readAll()
				if f == "200" then
					lOS.cloud.files[path] = os.epoch("utc")
					table.insert(l,{action="Upload",timestamp=os.epoch("utc"),destination=pth})
					return download(pth,root,fs.attributes(path).modification,true)
				else
					return false,f
				end
			elseif not tree[pth] then
				-- file has been deleted, delete local file too?
				lOS.cloud.files[path] = nil
				table.insert(l,{action="Deleted",timestamp=os.epoch("utc"),destination=pth})
				fs.delete(path)
				fs.delete(mpath)
				return false,"Deleted"
			else
				--print("wtf?")
			end
		else
			return false,"File does not exist"
		end
	end


	local function sync(root)
		local uploaded = 0
		local downloaded = 0
		lOS.cloudSync = true
		if not fs.exists(root) then
			fs.makeDir(root)
		end
		local tree = {}
		local folders = {}
		local res = hget("https://os.leveloper.cc/cloud.php").readAll()
		local timestamps = textutils.unserializeJSON(res)

		for f,_ in pairs(timestamps.folders) do
			local path = fs.combine(root,f)
			local mdpath = fs.combine(md,f)
			if not fs.exists(mdpath) and not fs.exists(path) then
				fs.makeDir(mdpath)
				fs.makeDir(path)
			end
			if not fs.exists(path) and fs.exists(mdpath) then
				-- folder got deleted by user
				hpost("https://os.leveloper.cc/cDelete.php","path="..textutils.urlEncode(f))
				fs.delete(mdpath)
				for k,v in pairs(timestamps.folders) do
					if k:find(f,nil,true) == 1 then
						timestamps.folders[k] = nil
					end
				end
				for k,v in pairs(timestamps.files) do
					if k:find(f,nil,true) == 1 then
						timestamps.files[k] = nil
						table.insert(l,{action="Deleted",timestamp=os.epoch("utc"),destination=k})
					end
				end
			else
				folders[f] = ""
			end
		end

		--if not searchFolder("") then return false end

		local oTime = os.epoch("utc")
		for k,v in pairs(timestamps.files) do
			--print("Downloading file "..k)
			if os.epoch("utc") > oTime+50 then
				os.queueEvent("placeholder")
				os.pullEvent()
				oTime = os.epoch("utc")
			end
			if download(k,root,v) == true then
				downloaded = downloaded+1
			end
		end
		local function syncFolder(folder)
			--print("Syncing folder root/"..folder)
			local path = fs.combine(root,folder)
			if os.epoch("utc") > oTime+50 then
				os.queueEvent("placeholder")
				os.pullEvent()
				oTime = os.epoch("utc")
			end
			if not fs.exists(path) then return end
			local files = fs.list(path)
			for t=1,#files do
				local file = fs.combine(path,files[t])
				if fs.isDir(file) then
					if not folders[fs.combine(folder,files[t])] and fs.exists(fs.combine(md,fs.combine(folder,files[t]))) then
						--("Folder "..files[t].." was deleted from server.")
						fs.delete(fs.combine(md,fs.combine(folder,files[t])))
						fs.delete(file)
					elseif not folders[fs.combine(folder,files[t])] then
						hpost("https://os.leveloper.cc/cMkDir.php","path="..textutils.urlEncode(fs.combine(folder,files[t])))
						--print("Created folder "..fs.combine(folder,files[t]))
					end
					if fs.exists(file) then
						syncFolder(fs.combine(folder,files[t]))
					end
				else
					--print("Uploading file "..file)
					if upload(fs.combine(folder,files[t]),root,timestamps.files) == true then
						uploaded = uploaded+1
					end
				end
			end
		end

		syncFolder("")
		
		lOS.cloudSync = false	
		
		if uploaded > 0 then
			lOS.notification("LevelCloud",uploaded.." file(s) uploaded to cloud.")
		end
		if downloaded > 0 then
			lOS.notification("LevelCloud",downloaded.." file(s) downloaded from cloud.")
		end

		return true

	end

	sync("User/Cloud")
	lOS.cloud.lastSync = os.epoch("utc")
end
local init = false
while true do
	lOS.cloudTimer = 0
	if not lOS.cloudSync then
		local ok,err = pcall(doSync)
		if not ok then
			lOS.notification("LevelCloud",err)
			return
		end
		while not lOS.userID do
			os.pullEvent()
		end
		if lOS.userID and not init then
			lOS.notification("LevelCloud","Running in the background.")
			init = true
		end
	end
	while lOS.cloudTimer < 30 do
		os.sleep(1)
		lOS.cloudTimer = lOS.cloudTimer+1
	end
end
--term.redirect(owin)