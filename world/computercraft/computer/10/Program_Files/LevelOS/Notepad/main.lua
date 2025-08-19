local tArgs = {...}
local tFilepath = ""
if tArgs[1] ~= nil then
    tFilepath = tArgs[1]
end
local isReadOnly = false
if tArgs[2] ~= nil and tArgs[2] == "true" then
	isReadOnly = true
end
local tCol = {bg=colors.white,txt=colors.black,misc=colors.lightGray,misc2=colors.gray}
local btns = {{"File",{{"New","New window","Open...","Save","Save as..."},"Print","Quit"}},{"Edit",{"Undo",{"Search","Replace"},{"Time"}}},{"View",{"Dark Mode"}}}
local function topbar()
    local w,h = term.getSize()
    theline = ""
    for t=1,w-1 do
        theline = theline.."\131"
    end
    term.setCursorPos(1,1)
    term.setBackgroundColor(tCol.bg)
    term.setTextColor(tCol.misc)
    term.clearLine()
    term.setCursorPos(1,2)
    term.write(theline)
    term.setCursorPos(1,1)
    term.setTextColor(tCol.txt)
    for t=1,#btns do
        btns[t].x = ({term.getCursorPos()})[1]
        btns[t].w = string.len(btns[t][1])+2
        term.write(" "..btns[t][1].." ")
    end
end
local w,h = term.getSize()
local a = {}
local function txt()
    a = {{width=w-1,height=h-4,sTable={},filepath="",lines={""},changed=false},0,0,1,1}
	if tFilepath ~= "" then
		if fs.exists(tFilepath) == true then
			local openfile = fs.open(tFilepath,"r")
			a[1].lines = {}
			for line in openfile.readLine do
				a[1].lines[#a[1].lines+1] = line
			end
			openfile.close()
			if a[1].lines[1] == nil then
				a[1].lines[1] = ""
			end
		end
	end
    while true do
        local w,h = term.getSize()
        a[1].width = w-1
        a[1].height = h-4
        a[1].sTable = {background={tCol.bg},text={tCol.txt},cursor={colors.red}}
        term.setCursorPos(1,5)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        --print("I am present.")
        local changesAllowed = true
        if isReadOnly == true or (tFilepath ~= "" and fs.isReadOnly(tFilepath) == true) then
            changesAllowed = false
        end
        a = {lUtils.drawEditBox(a[1],1,3,a[2],a[3],a[4],a[5],true,true,nil,changesAllowed)}
        --term.setCursorPos(1,3)
        --term.clearLine()
        --term.write("HIII: ")
        --term.write(textutils.serialize(a))
        os.sleep(0)
    end
end
_G.thetxtfunction = txt
local function save()
    if tFilepath == "" then
        while true do
            local i = {lUtils.inputbox("Filepath","Please enter a new filepath:",29,10,{"Done","Cancel"})}
            if i[2] == false or i[4] == "Cancel" then
                return false
            end
            if fs.exists(i[1]) == true then
                lUtils.popup("Error","This path already exists!",29,9,{"OK"})
            else
                tFilepath = i[1]
                break
            end
        end
    end
    local savefile = fs.open(tFilepath,"w")
    for t=1,#a[1].lines do
        savefile.writeLine(a[1].lines[t])
    end
	savefile.close()
    return true
end
function uwansave()
    local name = ""
    if tFilepath == "" then
        name = "Untitled"
    else
        name = fs.getName(tFilepath)
    end
    local c = {lUtils.popup("Notepad","Do you want to save your changes in "..name.."?",30,8,{"Save","Don't save","Cancel"})}
    if c[1] == false then return false
    elseif c[3] == "Save" then
        if tFilepath == "" then
            -- select file path with explorer asap
            return false
        end
        local ayyy = fs.open(tFilepath,"w")
        for t=1,#a[1].lines do
            ayyy.writeLine(a[1].lines[t])
        end
    end
    if c[3] ~= "Cancel" then
        return true
    end
end
local function scrollbars()
    local w,h = term.getSize()
    term.setCursorPos(1,h-1)
    term.setBackgroundColor(tCol.misc)
    term.setTextColor(tCol.misc2)
    term.clearLine()
    term.setCursorPos(1,h-1)
    term.write("\17")
    term.setCursorPos(w-1,h-1)
    term.write("\16")
    for t=2,h-2 do
        term.setCursorPos(w,t)
        if t == 3 then
            term.write("\30")
        elseif t == h-2 then
            term.write("\31")
        else
            term.write(" ")
        end
    end
    term.setCursorPos(1,h)
    for t=1,w do
        term.write("\131")
    end
end
function LevelOS.close()
	local u = true
	if a[1].changed == true then
		u = uwansave()
	end
	if u == true then
		return
	else
		regevents()
	end
end
function regevents()
    scrollbars()
    local txtcor = coroutine.create(txt)
    topbar()
    coroutine.resume(txtcor)
    while true do
        e = {os.pullEvent()}
        scrollbars()
        if not ((e[1] == "mouse_click" or e[1] == "mouse_up") and e[4] == 1) then
            coroutine.resume(txtcor,table.unpack(e))
        end
        --term.setCursorPos(1,3)
        --term.setBackgroundColor(colors.white)
        --term.setTextColor(colors.black)
        --term.clearLine()
        --term.setCursorPos(1,3)
        --term.write(coroutine.status(txtcor).." "..textutils.serialize(a[1]))
        if e[1] == "term_resize" then
            topbar()
            scrollbars()
            coroutine.resume(txtcor,"mouse_click",1,1,1)
        elseif e[1] == "mouse_click" then
            if e[4] == 1 then
                topbar()
                term.setCursorBlink(false)
                local oldcursorpos = {term.getCursorPos()}
                for t=1,#btns do
                    if e[3] >= btns[t].x and e[3] <= btns[t].x+btns[t].w-1 then
                        -- open menu and color button light blue
                        term.setCursorPos(btns[t].x,1)
                        term.setBackgroundColor(colors.blue)
                        term.write(" "..btns[t][1].." ")
                        local disabled = {}
                        if btns[t][1] == "File" then
                            if a[1].changed == false then
                                disabled = {"Save","Save as..."}
                            end
                        end
                        local b = {lUtils.clickmenu(btns[t].x,2,20,btns[t][2],true,disabled)}
                        if b[1] ~= false then
                            if b[3] == "New" then
                                local d = true
                                if a[1].changed == true then
                                    d = uwansave()
                                end
                                if d == true then
                                    tFilepath = ""
                                    txtcor = coroutine.create(txt)
                                    os.startTimer(0.1)
                                end
                            elseif b[3] == "New window" then
                                lOS.execute(LevelOS.path)
                            elseif b[3] == "Open..." then
                                local u = true
                                if a[1].changed == true then
                                    u = uwansave()
                                end
                                if u == true then
                                    local d = {lUtils.explorer("/","SelFile false")}
                                    if d[1] ~= nil then
                                        if fs.exists(d[1]) == true then
                                            a = {}
                                            txtcor = coroutine.create(txt)
                                            coroutine.resume(txtcor)
                                            tFilepath = d[1]
                                            local openfile = fs.open(tFilepath,"r")
                                            a[1].lines = {}
                                            for line in openfile.readLine do
                                                a[1].lines[#a[1].lines+1] = line
                                            end
                                            openfile.close()
                                            if a[1].lines[1] == nil then
                                                a[1].lines[1] = ""
                                            end
                                        end
                                    end
                                end
                            elseif b[3] == "Save" then
                                if save() == true then
                                    a[1].changed = false
                                end
                            elseif b[3] == "Save as..." then
                                local oldF = tFilepath
                                tFilepath = ""
                                if save() == false then
                                    tFilepath = oldF
                                else
                                    a[1].changed = false
                                end
                            elseif b[3] == "Quit" then
                                local u = true
                                if a[1].changed == true then
                                    u = uwansave()
                                end
                                if u == true then
                                    return
                                end
							elseif b[3] == "Dark Mode" then
								tCol = {bg=colors.black,txt=colors.white,misc=colors.gray,misc2=colors.lightGray}
								topbar()
								scrollbars()
								coroutine.resume(txtcor,"mouse_click",1,1,1)
								btns[3][2][1] = "Light Mode"
							elseif b[3] == "Light Mode" then
								tCol = {bg=colors.white,txt=colors.black,misc=colors.lightGray,misc2=colors.gray}
								topbar()
								scrollbars()
								coroutine.resume(txtcor,"mouse_click",1,1,1)
								btns[3][2][1] = "Dark Mode"
                            end
                        end
                    end
                end
                topbar()
                term.setCursorPos(table.unpack(oldcursorpos))
                term.setTextColor(colors.red)
                term.setCursorBlink(true)
            end
        end
    end
end
regevents()