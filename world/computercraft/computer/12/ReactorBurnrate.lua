R1 = peripheral.find("fissionReactorLogicAdapter")
R2 = peripheral.find("fissionReactorPort")
assert(R1,"Reactor Logic Missing")
assert(R2,"Reactor Port Missing")
assert(R1.isFormed(),"Reactor Structure Incomplete")

term.clear()
term.setCursorPos(1,2)

while R1.isFormed() do

print("Burnrate Set: "..R1.getBurnRate().."mB/t")
term.write("New Target Burn Rate: ")
BurnValue = tonumber(read())

term.clear()
term.setCursorPos(1,2)
    if (BurnValue == nil) then print("ERROR: Insert Numerical Value")
    elseif (BurnValue <0) then print("ERROR: Insert Positive Value")
    elseif (BurnValue >30) then print("ERROR: Maximum Target Burn Rate Exceeded")
    else R1.setBurnRate(BurnValue)
    end
end
