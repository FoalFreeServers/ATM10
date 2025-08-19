local assets = {
  [ "init.lua" ] = {
    id = 0,
    content = "if not self.init then\
    if not fs.exists(\"LevelOS/startup/LevelCloud.lua\") then\
        --LevelOS.maximize()\
        term.setBackgroundColor(colors.white)\
        term.clear()\
        os.queueEvent(\"term_resize\")\
        os.pullEvent()\
        local a = {lUtils.popup(\"LevelCloud\",\"Do you want to install LevelCloud?\",27,9,{\"Install\",\"Cancel\"})}\
        if a[1] and a[3] == \"Install\" then\
            local oterm = term.current()\
            local nterm = window.create(term.current(),1,1,51,19,false)\
            term.redirect(nterm)\
            shell.run(\"lStore get Sm0f1bwQ LevelOS/startup/LevelCloud.lua\")\
            term.redirect(oterm)\
            local b = {lUtils.popup(\"LevelCloud\",\"LevelCloud installed. Please reboot to synchronize.\",27,9,{\"Reboot\",\"Later\"})}\
            if b[1] and b[3] == \"Reboot\" then\
                lOS.save()\
                os.reboot()\
            end\
        end\
        shapescape.exit()\
    end\
    local w,h = lOS.wAll.getSize()\
    if lOS.tbSize then\
        h = h-lOS.tbSize\
    end\
    local th = 14\
    if h > 32 then\
        th = 25\
    end\
    LevelOS.self.window.win.reposition(w-30,h-(th-1),25,th)\
    LevelOS.setWin(25,th,\"borderless\")\
    LevelOS.setTitle(\"Cloud\")\
    \
    self.init = true\
end",
    name = "init.lua",
  },
  [ "open_folder.lua" ] = {
    id = 1,
    content = "lOS.execute(\"LevelOS/explorer.lua User/Cloud\")",
    name = "open_folder.lua",
  },
  [ "sync_click.lua" ] = {
    id = 7,
    content = "while true do\
    e = {os.pullEvent()}\
    if e[1] == \"mouse_click\" or e[1] == \"mouse_up\" then\
        if e[3] >= self.x1 and e[4] >= self.y1 and e[3] <= self.x2 and e[4] <= self.y2 then\
            if e[1] == \"mouse_click\" then\
                self.oldcolor = self.txtcolor\
                self.txtcolor = colors.lightBlue\
            else\
                --shell.run(\"pastebin run 4DaaHGRP\")\
                if not lOS.cloudSync then\
                    lOS.cloudTimer = 30\
                end\
            end\
        end\
        if e[1] == \"mouse_up\" and self.oldcolor then\
            self.txtcolor = self.oldcolor\
            self.oldcolor = nil\
        end\
    end\
end",
    name = "sync_click.lua",
  },
  colorsync2 = {
    id = 8,
    content = "if not lOS.userID then\
    self.color = colors.red\
    self.txt = \" Offline\"\
elseif lOS.cloudSync then\
    self.color = colors.orange\
    self.txt = \" Syncing...\"\
elseif self.color == colors.orange then\
    self.color = colors.blue\
    self.txt = \"LevelCloud\"\
end",
    name = "colorsync2",
  },
  [ "log.lua" ] = {
    id = 3,
    content = "local c = 0\
local scr = 0\
local scroll = 0\
local lasty = 0\
term.setBackgroundColor(colors.gray)\
term.clear()\
os.sleep(0.1)\
local isConflict\
local objs = {}\
local doRender = true\
local sl = shapescape.getSlides()\
while true do\
	isConflict = false\
	local w,h = term.getSize()\
	if lOS.cloudLog and (scr ~= scroll or #lOS.cloudLog ~= c or lOS.cloudSync or doRender) then\
		doRender = false\
		c = #lOS.cloudLog\
		if c > 40 then\
			for t=1,c-40 do\
				table.remove(lOS.cloudLog,t)\
			end\
		end\
		scr = scroll\
		c = #lOS.cloudLog\
		local l  = lOS.cloudLog\
		term.setBackgroundColor(colors.gray)\
		term.clear()\
		local y = 2-scroll\
		if lOS.cloud and lOS.cloud.conflicts and lOS.cloud.conflicts then\
			for k,v in pairs(lOS.cloud.conflicts) do\
				isConflict = true\
				-- will only run if theres an entry, but also only once\
				-- big brain moment :sunglasses:\
				term.setBackgroundColor(colors.red)\
				local txt = \"There are multiple versions of a file. Resolve >\"\
				local lines = lUtils.wordwrap(txt,w-2)\
				lOS.boxClear(1,y,w,y+2+#lines)\
				objs.conflict = {x1=1,y1=y,x2=w,y2=y+2+#lines}\
				term.setCursorPos(2,y+1)\
				term.setTextColor(colors.white)\
				term.write(\"There is a sync issue\")\
				term.setTextColor(colors.lightGray)\
				for i=1,#lines do\
					term.setCursorPos(2,y+i+1)\
					term.write(lines[i])\
				end\
				y = y+4+#lines\
				term.setBackgroundColor(colors.gray)\
				break\
			end\
		end\
		for t=c,1,-1 do\
			term.setCursorPos(1,y)\
			if l[t].action == \"Upload\" then\
				term.setTextColor(colors.blue)\
				term.write(\"\\24 \")\
			elseif l[t].action == \"Download\" then\
				term.setTextColor(colors.lime)\
				term.write(\"\\25 \")\
			elseif l[t].action == \"Deleted\" then\
				term.setTextColor(colors.red)\
				term.write(\"× \")\
			elseif l[t].action == \"Conflict\" then\
				term.setTextColor(colors.orange)\
				term.write(\"! \")\
			end\
			term.setTextColor(colors.white)\
			term.write(fs.getName(l[t].destination))\
			y = y+1\
			local dif = os.epoch(\"utc\")-l[t].timestamp\
			dif = math.floor(dif/1000)\
			term.setTextColor(colors.lightGray)\
			term.setCursorPos(1,y)\
			if dif <= 0 then\
				term.write(\"Just now\")\
			elseif dif == 1 then\
				term.write(\"1 second ago\")\
			elseif dif < 60 then\
				term.write(dif..\" seconds ago\")\
			elseif dif < 3600 then\
				term.write(math.floor(dif/60)..\" minute(s) ago\")\
			elseif dif < 86400 then\
				term.write(math.floor(dif/3600)..\" hour(s) ago\")\
			else\
				term.write(math.floor(dif/86400)..\" day(s) ago\")\
			end\
			y = y+1\
			term.setCursorPos(1,y)\
			term.setTextColor(colors.lightGray)\
			term.write(\"In \")\
			term.setTextColor(colors.cyan)\
			local loc = fs.getDir(l[t].destination)\
			if loc == \"\" then loc = \"Cloud\" end\
			if #loc+4 > w then\
				loc = \"..\"..loc:sub(#loc-(w-6))\
			end\
			term.write(loc)\
			term.setTextColor(colors.white)\
			y = y+2\
		end\
		lasty = y\
	end\
	e = {os.pullEvent()}\
	if lOS.cloudLog and e[1] == \"mouse_scroll\" and e[3] >= self.x1 and e[4] >= self.y1 and e[3] <= self.x2 and e[4] <= self.y2 then\
		if scroll+e[2] >= 0 then\
			scroll = scroll+e[2]\
		end\
	elseif e[1] == \"mouse_click\" and objs.conflict and lUtils.isInside(e[3],e[4],self) and lUtils.isInside(e[3],e[4],objs.conflict) then\
		local objs = {}\
		local stop = false\
		local function render()\
			local y = 1\
			objs = {}\
			term.setBackgroundColor(colors.gray)\
			term.clear()\
			term.setTextColor(colors.white)\
			term.setCursorPos(1,y)\
			term.write(\"< Sync issues\")\
			table.insert(objs,{x1=1,y1=y,x2=2,y2=y,func=function() stop = true end})\
			y = y+2\
			for path,v in pairs(lOS.cloud.conflicts) do\
				term.setBackgroundColor(colors.gray)\
				lOS.explorer.drawIcon(path,-1,y-1,true,true)\
				term.setTextColor(colors.white)\
				term.setCursorPos(5,y)\
				term.write(fs.getName(path))\
				y = y+1\
				--[[term.setCursorPos(5,y)\
				term.setTextColor(colors.lightGray)\
				term.write(\"In \")\
				term.setTextColor(colors.cyan)\
				local loc = fs.getDir(path)\
				if loc == \"\" then loc = \"Cloud\" end\
				if #loc+8 > w then\
					loc = \"..\"..loc:sub(#loc-(w-10)):gsub(\"^User/Cloud/\",\"\")\
				end\
				term.write(loc)]]\
				local btxt = \"Resolve\"\
				term.setTextColor(colors.cyan)\
				lUtils.border(5,y,5+#btxt+1,y+2,nil,1)\
				table.insert(objs,{x1=5,y1=y+1,x2=5+#btxt+1,y2=y+1,func=\
					function()\
						local tW,tH = lOS.wAll.getSize()\
						if tW <= 51 or tH <= 19 then\
							LevelOS.setWin(\"fullscreen\")\
						else\
							LevelOS.setWin(math.floor(tW/2-51/2)+1,math.floor(tH/2-19/2)+1,51,19,\"borderless\")\
							LevelOS.self.window.resizable = false\
						end\
						sl.resolvepath=path\
						shapescape.setSlide(2)\
						stop=true\
					end\
				})\
				term.setCursorPos(6,y+1)\
				term.setBackgroundColor(colors.cyan)\
				term.setTextColor(colors.white)\
				term.write(btxt)\
				y = y+3\
			end\
		end\
		render()\
		while not stop do\
			local e = {os.pullEvent()}\
			if e[1] == \"mouse_click\" then\
				for o=1,#objs do\
					if lUtils.isInside(e[3],e[4],objs[o]) then\
						objs[o].func()\
					end\
				end\
			end\
		end\
		doRender = true\
	end\
end",
    name = "log.lua",
  },
  [ "resolveaction.lua" ] = {
    id = 12,
    content = "local sl = shapescape.getSlides()\
if self.isSel then\
	self.border.color = colors.white\
	self.isSel = false\
	local mdpth = \"AppData/LevelCloud/\"..lOS.username\
	local cpath = sl.resolvepath:gsub(\"^User/Cloud\",\"\")\
	local mdfile = fs.combine(mdpth,cpath)\
	if self.txt:find(\"local\") then\
		-- delete online file\
		-- how tf u even do that bro\
		local h = http.post(\"https://os.leveloper.cc/cDelete.php\",\"path=\"..textutils.urlEncode(cpath),{Cookie=lOS.userID})\
		if h then\
			fs.delete(mdfile)\
			lOS.cloudTimer = 30\
			lOS.cloud.conflicts[sl.resolvepath] = nil\
		end\
	elseif self.txt:find(\"online\") then\
		-- delete local file\
		fs.delete(mdfile)\
		fs.delete(sl.resolvepath)\
		lOS.cloudTimer = 30\
		lOS.cloud.conflicts[sl.resolvepath] = nil\
	elseif self.txt:find(\"both\") then\
		local name = fs.getName(sl.resolvepath)\
		local pth = fs.getDir(sl.resolvepath)\
		while fs.exists(fs.combine(pth,name)) do\
			local temp,con = lUtils.inputbox(\"LevelCloud\",\"Please enter a new filename for \"..fs.getName(sl.resolvepath),25,11,{\"OK\"})\
			if not con then\
				return\
			end\
			if temp then\
				name = temp\
			end\
		end\
		local npth = fs.combine(pth,name)\
		fs.delete(mdfile)\
		fs.move(sl.resolvepath,npth)\
		lOS.cloud.conflicts[sl.resolvepath] = nil\
	end\
	sl.resolvepath = nil\
	local w,h = lOS.wAll.getSize()\
	if lOS.tbSize then\
		h = h-lOS.tbSize\
	end\
	local th = 14\
	if h > 32 then\
		th = 25\
	end\
	self.render()\
	LevelOS.self.window.win.reposition(w-30,h-(th-1),25,th)\
	LevelOS.setWin(25,th,\"borderless\")\
	LevelOS.setTitle(\"Cloud\")\
	shapescape.setSlide(1)\
end",
    name = "resolveaction.lua",
  },
  [ "resync.lua" ] = {
    id = 5,
    content = "if not lOS.cloudSync then\
    --shell.run(\"pastebin run 4DaaHGRP\")\
    lOS.cloudTimer = 30\
end",
    name = "resync.lua",
  },
  [ "coroclick.lua" ] = {
    id = 2,
    content = "while true do\
    e = {os.pullEvent()}\
    if e[1] == \"mouse_click\" or e[1] == \"mouse_up\" then\
        if e[3] >= self.x1 and e[4] >= self.y1 and e[3] <= self.x2 and e[4] <= self.y2 then\
            if e[1] == \"mouse_click\" then\
                self.oldcolor = self.txtcolor\
                self.txtcolor = colors.lightBlue\
            else\
                -- stupid bitch\
                --self.color = self.oldcolor or self.color\
            end\
        end\
        if e[1] == \"mouse_up\" and self.oldcolor then\
            self.txtcolor = self.oldcolor\
            self.oldcolor = nil\
        end\
    end\
end",
    name = "coroclick.lua",
  },
  [ "close_click.lua" ] = {
    id = 9,
    content = "local function dClose()\
while true do\
    local e = {os.pullEvent()}\
    --local x1,y1 = LevelOS.self.window.win.getPosition()\
    --local w,h = LevelOS.self.window.win.getSize()\
    --local x2,y2 = x1+(w-1),y1+(h-1)\
    if e[1] == \"mouse_up\" and e[3] == self.x1 and e[4] == self.y1 then\
        shapescape.exit()\
    --elseif e[1] == \"mouse_click\" and (e[3] < x1 or e[4] < y1 or e[3] > x2 or e[4] > y2) then\
    --elseif lOS.wins[#lOS.wins] ~= LevelOS.self.window then\
        --shapescape.exit()\
    end\
end\
end\
local ok,err = pcall(dClose)\
self.txt = err",
    name = "close_click.lua",
  },
  [ "closebutton.lua" ] = {
    id = 11,
    content = "local isSel = false\
local sl = shapescape.getSlides()\
while true do\
	local e = {os.pullEvent()}\
	if e[1] == \"mouse_click\" and lUtils.isInside(e[3],e[4],self) and not isSel then\
		self.otxtcolor = self.txtcolor\
		self.txtcolor = colors.lightGray\
		isSel = true\
	elseif e[1] == \"mouse_up\" and isSel then\
		isSel = false\
		self.txtcolor = self.otxtcolor\
		self.otxtcolor = nil\
		if lUtils.isInside(e[3],e[4],self) then\
			sl.resolvepath = nil\
			local w,h = lOS.wAll.getSize()\
			if lOS.tbSize then\
				h = h-lOS.tbSize\
			end\
			local th = 14\
			if h > 32 then\
				th = 25\
			end\
			LevelOS.self.window.win.reposition(w-30,h-(th-1),25,th)\
			LevelOS.setWin(25,th,\"borderless\")\
			LevelOS.setTitle(\"Cloud\")\
			shapescape.setSlide(1)\
		end\
	end\
end",
    name = "closebutton.lua",
  },
  [ "log_out.lua" ] = {
    id = 4,
    content = "if not lOS.cloudSync then\
    lUtils.logout()\
    lOS.cloudTimer = 30\
end",
    name = "log_out.lua",
  },
  colorsync = {
    id = 6,
    content = "if not lOS.userID then\
    self.color = colors.red\
    self.border.color = colors.black\
elseif lOS.cloudSync then\
    self.color = colors.orange\
    self.border.color = colors.red\
elseif self.color == colors.orange then\
    self.color = colors.blue\
    self.border.color = colors.cyan\
end",
    name = "colorsync",
  },
  [ "resolve.lua" ] = {
    id = 10,
    content = "local function func()\
local sl = shapescape.getSlides()\
self.isSel = false\
while true do\
	local e = {os.pullEvent()}\
	if e[1] == \"mouse_click\" and lUtils.isInside(e[3],e[4],self) then\
		self.border.color = colors.cyan\
		self.isSel = true\
	elseif e[1] == \"mouse_up\" and self.isSel then\
		self.border.color = colors.white\
		if lUtils.isInside(e[3],e[4],self) then\
			-- nothing anymore\
		end\
	end\
end\
end\
local ok,err = pcall(func)\
if not ok then\
	_G.clickerror = err\
end",
    name = "resolve.lua",
  },
}

local nAssets = {}
for key,value in pairs(assets) do nAssets[key] = value nAssets[assets[key].id] = assets[key] end
assets = nAssets
nAssets = nil

local slides = {
  {
    y = 21,
    x = 65,
    h = 19,
    w = 51,
    objs = {
      {
        color = 0,
        y2 = 17,
        y1 = 17,
        x1 = 27,
        txt = "helo am veri cool",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 1,
        input = false,
        x2 = 44,
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        x2 = 51,
        y2 = 19,
        y1 = 1,
        x1 = 1,
        type = "rect",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = 0,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        ox2 = 0,
        color = 128,
        border = {
          color = 256,
          type = 1,
        },
        snap = {
          Top = "Snap top",
          Right = "Snap right",
          Left = "Snap left",
          Bottom = "Snap bottom",
        },
        oy2 = 0,
      },
      {
        x2 = 50,
        y2 = 16,
        border = {
          color = 0,
          type = 1,
        },
        x1 = 2,
        type = "window",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 3,
          },
        },
        ox2 = 1,
        color = 32768,
        y1 = 4,
        snap = {
          Top = "Snap top",
          Right = "Snap right",
          Left = "Snap left",
          Bottom = "Snap bottom",
        },
        oy2 = 3,
      },
      {
        x2 = 51,
        y2 = 3,
        border = {
          color = 512,
          type = 1,
        },
        x1 = 1,
        type = "rect",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = 6,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        ox2 = 0,
        color = 2048,
        snap = {
          Top = "Snap top",
          Right = "Snap right",
          Left = "Snap left",
          Bottom = "Snap top",
        },
        y1 = 1,
      },
      {
        x2 = 32,
        y2 = 2,
        x1 = 21,
        ox1 = 5,
        txt = "LevelCloud",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = 8,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 1,
        ox2 = -6,
        border = {
          color = 0,
          type = 1,
        },
        input = false,
        color = 2048,
        snap = {
          Top = "Snap top",
          Right = "Snap center",
          Left = "Snap center",
          Bottom = "Snap top",
        },
        y1 = 2,
      },
      {
        color = 128,
        y2 = 19,
        border = {
          color = 256,
          type = 1,
        },
        x1 = 1,
        oy1 = 2,
        type = "rect",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        ox2 = 0,
        y1 = 17,
        x2 = 51,
        snap = {
          Top = "Snap bottom",
          Right = "Snap right",
          Left = "Snap left",
          Bottom = "Snap bottom",
        },
        oy2 = 0,
      },
      {
        x2 = 13,
        y2 = 18,
        x1 = 3,
        oy1 = 1,
        txt = "Open folder",
        type = "text",
        oy2 = 1,
        txtcolor = 512,
        border = {
          color = 0,
          type = 1,
        },
        event = {
          mouse_up = {
            [ 2 ] = 1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 2,
          },
        },
        input = false,
        color = 128,
        snap = {
          Top = "Snap bottom",
          Right = "Snap left",
          Left = "Snap left",
          Bottom = "Snap bottom",
        },
        y1 = 18,
      },
      {
        color = 128,
        y2 = 18,
        x1 = 43,
        ox1 = 8,
        oy1 = 1,
        txt = "Log out",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = 4,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 2,
          },
        },
        ox2 = 2,
        txtcolor = 512,
        border = {
          color = 0,
          type = 1,
        },
        x2 = 49,
        input = false,
        y1 = 18,
        snap = {
          Top = "Snap bottom",
          Right = "Snap right",
          Left = "Snap right",
          Bottom = "Snap bottom",
        },
        oy2 = 1,
      },
      {
        x2 = 49,
        y2 = 2,
        x1 = 49,
        ox1 = 2,
        txt = "",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 7,
          },
        },
        txtcolor = 1,
        ox2 = 2,
        y1 = 2,
        input = false,
        color = 0,
        snap = {
          Top = "Snap top",
          Right = "Snap right",
          Left = "Snap right",
          Bottom = "Snap top",
        },
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        x2 = 3,
        y2 = 2,
        y1 = 2,
        x1 = 3,
        txt = "×",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          Initialize = {
            [ 2 ] = -1,
          },
          selected = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 9,
          },
        },
        txtcolor = 1,
        input = false,
        color = 0,
        snap = {
          Top = "Snap top",
          Right = "Snap left",
          Left = "Snap left",
          Bottom = "Snap top",
        },
        border = {
          color = 0,
          type = 1,
        },
      },
    },
    c = 1,
  },
  {
    y = 21,
    x = 66,
    h = 19,
    w = 51,
    objs = {
      {
        x2 = 30,
        y2 = 2,
        y1 = 2,
        x1 = 6,
        txt = "Resolve the file conflict",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 2048,
        input = false,
        color = 0,
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        x2 = 50,
        y2 = 4,
        y1 = 3,
        x1 = 6,
        txt = "The online version and the local  version have changes that couldn't be merged.",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 32768,
        input = false,
        color = 0,
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        x2 = 50,
        y2 = 8,
        y1 = 5,
        x1 = 2,
        txt = " Keep local file",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = 12,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 10,
          },
        },
        txtcolor = 2048,
        input = false,
        color = 0,
        border = {
          color = 1,
          type = 1,
        },
      },
      {
        x2 = 49,
        y2 = 7,
        y1 = 7,
        x1 = 5,
        txt = "Overwrite the online file with the local one",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 32768,
        input = false,
        color = 0,
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        color = 0,
        y2 = 12,
        y1 = 9,
        x1 = 2,
        txt = " Keep online file",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = 12,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 10,
          },
          update = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 2048,
        input = false,
        x2 = 50,
        border = {
          color = 1,
          type = 1,
        },
      },
      {
        color = 0,
        y2 = 11,
        y1 = 11,
        x1 = 5,
        txt = "Overwrite the local file with the online one",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 32768,
        input = false,
        x2 = 49,
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        x2 = 50,
        y2 = 16,
        border = {
          color = 1,
          type = 1,
        },
        x1 = 2,
        txt = " Keep both files",
        type = "text",
        event = {
          render = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          mouse_up = {
            [ 2 ] = 12,
          },
          Coroutine = {
            [ 2 ] = 10,
          },
          update = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 2048,
        input = false,
        color = 0,
        snap = {
          Top = "Snap top",
          Right = "Snap left",
          Left = "Snap left",
          Bottom = "Snap top",
        },
        y1 = 13,
      },
      {
        color = 0,
        y2 = 15,
        y1 = 15,
        x1 = 5,
        txt = "Rename the local file",
        type = "text",
        event = {
          render = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          mouse_up = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 32768,
        input = false,
        x2 = 49,
        snap = {
          Top = "Snap top",
          Right = "Snap left",
          Left = "Snap left",
          Bottom = "Snap top",
        },
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        x2 = 51,
        y2 = 19,
        y1 = 17,
        x1 = 1,
        oy1 = 2,
        type = "rect",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        ox2 = 0,
        border = {
          color = 0,
          type = 1,
        },
        color = 256,
        snap = {
          Top = "Snap bottom",
          Right = "Snap right",
          Left = "Snap left",
          Bottom = "Snap bottom",
        },
        oy2 = 0,
      },
      {
        x2 = 50,
        y2 = 18,
        x1 = 44,
        ox1 = 7,
        oy1 = 1,
        txt = " Close",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 11,
          },
        },
        ox2 = 1,
        y1 = 18,
        border = {
          color = 0,
          type = 1,
        },
        color = 1,
        input = false,
        txtcolor = 32768,
        snap = {
          Top = "Snap bottom",
          Right = "Snap right",
          Left = "Snap right",
          Bottom = "Snap bottom",
        },
        oy2 = 1,
      },
      {
        color = 0,
        y2 = 17,
        y1 = 1,
        x1 = 1,
        type = "rect",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        ox2 = 0,
        x2 = 51,
        border = {
          color = 256,
          type = 1,
        },
        snap = {
          Top = "Snap top",
          Right = "Snap right",
          Left = "Snap left",
          Bottom = "Snap bottom",
        },
        oy2 = 2,
      },
      {
        x2 = 51,
        y2 = 1,
        border = {
          color = 0,
          type = 1,
        },
        x1 = 1,
        type = "rect",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        ox2 = 0,
        color = 128,
        snap = {
          Top = "Snap top",
          Right = "Snap right",
          Left = "Snap left",
          Bottom = "Snap top",
        },
        y1 = 1,
      },
      {
        x2 = 11,
        y2 = 1,
        y1 = 1,
        x1 = 2,
        txt = "LevelCloud",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
        txtcolor = 1,
        input = false,
        color = 0,
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        color = 0,
        y2 = 1,
        x1 = 49,
        ox1 = 2,
        txt = " ×",
        type = "text",
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = 11,
          },
        },
        txtcolor = 1,
        ox2 = 0,
        y1 = 1,
        input = false,
        x2 = 51,
        snap = {
          Top = "Snap top",
          Right = "Snap right",
          Left = "Snap right",
          Bottom = "Snap top",
        },
        border = {
          color = 0,
          type = 1,
        },
      },
      {
        type = "rect",
        x2 = 4,
        y2 = 4,
        y1 = 2,
        x1 = 2,
        image = {
          {
            "",
            " b ",
            "b  ",
          },
          {
            "",
            "bb9",
            " 9 ",
          },
          {
            "",
            "   ",
            "   ",
          },
        },
        border = {
          color = 0,
          type = 1,
        },
        color = 0,
        event = {
          mouse_up = {
            [ 2 ] = -1,
          },
          mouse_click = {
            [ 2 ] = -1,
          },
          focus = {
            [ 2 ] = -1,
          },
          render = {
            [ 2 ] = -1,
          },
          update = {
            [ 2 ] = -1,
          },
          Coroutine = {
            [ 2 ] = -1,
          },
        },
      },
    },
    c = 2,
  },
}

for s=1,#slides do
	local slide = slides[s]
	for o=1,#slide.objs do
		local obj = slide.objs[o]
		for key,value in pairs(obj.event) do
			if assets[ value[2] ] then
				lUtils.shapescape.addScript(obj,value[2],key,assets,LevelOS,slides)
			else
				obj.event[key] = {function() end,-1}
			end
		end
	end
end

	local tArgs = {...}
if tArgs[1] and tArgs[1] == "load" then
	return {assets=assets,slides=slides}
end


return lUtils.shapescape.run(slides,...)