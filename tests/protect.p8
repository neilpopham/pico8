pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function _init()
 p={a=0,f=0,da=0}
end

function _update60()
 if btn(0) then
  p.da=p.da-0.001
 elseif btn(1) then
  p.da=p.da+0.001
 else
  p.da=p.da*0.92
 end
 if abs(p.da)<0.001 then p.da=0 end
 p.da=mid(-0.025,p.da,0.025)
 p.a=p.a+p.da
 p.a=p.a%1

 p.x=cos(p.a)*21
 p.y=-sin(p.a)*21
end

function _draw()
 cls()
 --circ(64,64,21,1)

for i=0,0.99,0.05 do
 pset(64+cos(i)*21,64-sin(i)*21,1)
end


 circ(64+p.x,64+p.y,2,2)

 local a1=(p.a-0.125)%1
 local a2=(p.a+0.125)%1


 --if a1>a2 then a1=1-a1 end

 --printh(p.a..", "..a1..", "..a2)

 --[[
 local x1=cos(a1)*92
 local y1=-sin(a1)*92
 local x2=cos(a2)*92
 local y2=-sin(a2)*92
 --printh(64+x1..","..64+y1.." and "..64+x2..","..64+y2)
 line(64,64,64+x1,64+y1,3)
 line(64,64,64+x2,64+y2,3)

]]
 --pset(64+x1,64+y1,4)
 --pset(64+x2,64+y2,4)


 s={{16,16},{64,16},{112,16},{16,64},{112,64},{16,112},{64,112},{102,112}}
 --s={{102,10},{108,10}}

 for i,d in pairs(s) do
  local c=7
  local a=atan2(d[1]-64,64-d[2])
  --printh(-(d[2]-64))
  --printh(a.." => "..a1.."-"..a2)

  if a1>a2 then
   if a>=a1 or a<=a2 then c=8 end
  else
    if a>=a1 and a<=a2 then c=8 end
  end

  if a>=a1 and a<=a2 then c=8 end
  pset(d[1],d[2],c)
  --line(64,64,64+cos(a)*50,64-sin(a)*50)
 end


end
