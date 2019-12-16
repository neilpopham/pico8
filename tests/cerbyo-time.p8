pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function _init()
 cls()
 time_diff=0 --flr(time())
 x=1
end

function _draw()
 cls()
 color(7)

---[[
local d=min(16,flr((time()-time_diff)*25))
for i=1,d do
 circ(i*8,i*8,8,10)
end
if time()-time_diff>1 then
 time_diff=time()
end
--]]

--[[
actioned=false
for i,timing in pairs(timings) do
 if not actioned and time()>timing then
  doaction(actions[i])
  actioned=true
 end
end
]]



 --[[
 for i=1,30 do
  if time() - time_diff>=1 then
   onesec=true
  end
  if onesec then
   circ(i*8,i*8,8,10)
  end
 end
 if onesec then
  onesec=false
  time_diff=time()
 end
 --]]

 --[[
 --printh("=== "..time())
 for i=1,30 do
  if i-1<time()*25 then
   --printh(i.." "..(time()*10))
   circ(i*8,i*8,8,10)
  end
 end
 --]]

 --[[
 if time()-time_diff>=1 then
  onesec=true
 end
 for i=1,30 do
  if onesec then
   circ(i*8,i*8,8,10)
  end
 end
 if onesec then
  onesec=false
  time_diff=time()
 end
 ]]
 --[[
 for i=1,10 do
  if time()-time_diff>1 then
   print(x..": ".." "..time())
   time_diff=time() -- flr(time())
   x+=1
  end
 end
 for i=1,10000 do
  pset(128+i,128+i,0)
 end
 ]]
end
