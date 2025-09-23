term.clear()
term.setCursorPos(1,1)

-- Reactor Connections --
R1 = peripheral.find("fissionReactorLogicAdapter")
R2 = peripheral.find("fissionReactorPort")
-- Turbine Connection --
T1 = peripheral.find("turbineValve")
-- Overflow Buffer Connection (Induction Matrix) --
P1 = peripheral.find("inductionPort")

M1 = peripheral.find("monitor")

sleep(0.25)
assert(R1,"Reactor Logic Missing")
print("Reactor Logic Found")    
sleep(0.15)
assert(R2,"Reactor Port Missing")
print("Reactor Port Found")
sleep(0.25)
assert(R1.isFormed(),"Reactor Structure Incomplete")
print("Reactor Structure Complete")
sleep(0.25)
assert(T1,"Turbine Connection Missing")
print("Turbine Found")
sleep(0.25)
assert(P1,"Overflow Buffer Missing")
print("Overflow Buffer Found")
sleep(0.5)
print("Initializing...")
sleep(1)  

function KtC(TempinK) 
    return TempinK - 273.15
end

function tKFE(EnergyMek)
    return EnergyMek / 2500
end

function Nominality()
    if not R1.getStatus()
        then RFunction = "Offline"
    elseif (KtC(Temp)) > 290
          then RFunction = "System Malfunction"
    else RFunction = "All Systems Nominal"
    end
end

----------------

while R1.isFormed() do

    local ROnOff
    local RFunction = "FunctionX"
    
    local Temp      = R1.getTemperature()
    local Status    = R1.getStatus()
    local Fuel      = R1.getFuelFilledPercentage()
    local CoolSod   = R1.getCoolantFilledPercentage()
    local HotSod    = R1.getHeatedCoolantFilledPercentage()
    local Damage    = R1.getDamagePercent()
    local Waste     = R1.getWasteFilledPercentage()
    local Burn      = R1.getBurnRate()
    local MaxBurn   = R1.getMaxBurnRate()
    local ActBurn   = R1.getActualBurnRate()
        
    local TProd     = T1.getProductionRate()
    local TPValue   --Raw Value Production Max Output
    local TPSignal  --Turbine Production Redstone Out
    
    local OFBEnergy = P1.getEnergy()
    local OFBCharge = math.floor(P1.getEnergyFilledPercentage()*100)
    local OFBMax    = P1.getMaxEnergy()
    local OFBIn     = P1.getLastInput()
    local OFBOut    = P1.getLastOutput()
    local OFBTime   = (math.floor((OFBMax - OFBEnergy) / (OFBIn-OFBOut))) 
    local OFBStat   = OFBTime
    
    local ActivSignal --Redstone Engaging Signal
    
    local Primewarn --Warning for Major Issues
    
    local monitor = peripheral.find("monitor_0")
    
-- Reactor On/Off --
        
    if not Status
        then ROnOff = "Reactor Idle"
    elseif ActBurn == 0
        then ROnOff = "Reactor Idle"    
    else ROnOff = "Reactor Working"
         
    end
    
-- Turbine Gauge Output Signal --

    TPValue = (tKFE(TProd))/(2056)
    TPSignal = math.floor(15 * TPValue)
    redstone.setAnalogOutput("left",TPSignal)
    
-- Reactor Heat Output Signal --

    RHValue = (KtC(Temp))
    if RHValue > 750
        then RHSignal = 15
    else RHSignal = math.floor((RHValue)/50)
    end    -- + 1 Redstone Level = +50C
    redstone.setAnalogOutput("back",RHSignal) 
    
-- Reactor Funtional Warnings --    
            
    if not Status
        then RFunction = "Offline"
             ActivSignal = true
             WarnSignal = false
    elseif (KtC(Temp)) > 290
        then RFunction = "Warning: Overheating"
             ActivSignal = false
             WarnSignal = true
    elseif (CoolSod < 0.05)
        then RFunction = "Warning: Low Coolant"
             ActivSignal = false
             WarnSignal = true
    elseif (HotSod > 0.5)
        then RFunction = "Warning: Coolant Blockage"
             ActivSignal = false
             WarnSignal = true      
    elseif (Damage > 0)
        then RFunction = "Warning: Integrity Compromised"
             ActivSignal = false
             WarnSignal = true
    elseif OFBTime*0.05 < 60
        then RFunction = "Warning: Overloading OFB"
             ActivSignal = true
             WarnSignal = true
    elseif (Waste > 0.5)
        then RFunction = "Warning: Waste Blockage"
             ActivSignal = true
             WarnSignal = true
    elseif (Fuel < 0.1)
        then RFunction = "Warning: Fuel Low"
             ActivSignal = true
             WarnSignal = false
    else RFunction = "All Systems Nominal"
         ActivSignal = true
         WarnSignal = false
    end
    redstone.setOutput("right",ActivSignal)
    redstone.setOutput("top",WarnSignal)
    
term.clear()
M1.setTextScale(0.5)  
term.redirect(M1)       
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)
print("Monitoring Reactor... "..RFunction)     

term.setTextColor(colors.orange)
print("-----------------------------------------")
term.setTextColor(colors.white)

term.write("Status      : ") print(ROnOff)
print("Temperature : "..math.floor(KtC(Temp)).."C")
print("Fuel Level  : "..math.floor(Fuel*100).."%")
print("Burn Rate   : "..Burn.."mB/t")
print("Processing  : "..ActBurn.."/"..MaxBurn.."mB/t")

term.setTextColor(colors.orange)
print("-----------------------------------------")
term.setTextColor(colors.red)
print("Hot Coolant in Vessel    : "..(math.floor(HotSod*100*22.5)*0.01).."kB")
term.setTextColor(colors.lightBlue)
print("Coolant Supply in Vessel : "..(math.floor(CoolSod*100*22.5)*0.01).."/22.5kB")    
            
term.setTextColor(colors.orange)
print("-----------------------------------------")
term.setTextColor(colors.white)
    
print("Current Turbine Output   : "..(math.floor((tKFE(TProd))*100)*0.01).."kFE/t")
    
term.setTextColor(colors.orange)
print("-----------------------------------------")
term.setTextColor(colors.white)

print("Overflow Buffer Charge   : "..OFBCharge.."%")

print("OFB Maximum Capacity     : "..(tKFE((OFBMax)*0.000001)).."GFE")

print("Time to OFB Capacity     : ")

    if OFBTime*0.05 > 36000
        then OFBStat = "10+ hours"
             term.setTextColor(colors.lightBlue)
    elseif OFBTime*0.05 < 36000 and OFBTime*0.05 > 7200
        then OFBStat = (math.floor(OFBTime/72000)).." hours"
            term.setTextColor(colors.white)
    elseif OFBTime*0.05 < 7200 and OFBTime*0.05 > 300
        then OFBStat = (math.floor(OFBTime/1200)).." minutes"
            term.setTextColor(colors.yellow)
    elseif OFBTime*0.05 < 300 and OFBTime*0.05 > 60
        then OFBStat = (math.floor(OFBTime*0.05)).." seconds /!\\"
            term.setTextColor(colors.orange)
    elseif OFBTime*0.05 <60
        then OFBStat = (math.floor(OFBTime*0.05)).." seconds /!\\ /!\\ /!\\"       
        term.setTextColor(colors.red)
    else OFBStat = "AT CAPACITY /!\\ /!\\ /!\\"
        term.setTextColor(colors.red)
    end

term.setCursorPos(28,16)
print(OFBStat)

sleep(0.25)

end
