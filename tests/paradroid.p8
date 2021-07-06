pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

l = {
 {
  {{0,0,2,4,0},{2,1,3,3,0},{1,1,1,3},{2,2,2,2}},
  {{1,0,3,4,0},{0,1,1,3,0},{2,1,2,3},{1,2,1,2}}
 }
}

function dumptable(t,l)
 l=l or 0
 local p=""
 for i=0,l do
  p=p.."  "
 end
 local i=0
 for k,v in pairs(t) do
  i+=1
  if type(v)=="table" then
   printh(p..k.. " => (table)")
   dumptable(v,l+1)
  else
   local t=type(v)
   if v==nil then v="nil" end
   if type(v)=="boolean" then v=v and "true" or "false" end
   printh(p..k.. " => "..v.." ("..t..")")
  end
 end
 if i==0 then printh(p.."(empty)") end
end


cls(4)

function arrow2(x,y,d)
 rectfill(x,y,x+2,y+4,0)
 rectfill(x+2,y+1,x+3,y+3,0)

 rectfill(x+1,y+1,x+1,y+3,9)
 pset(x+2,y+2,9)
end

function arrow(x,y,d,c)
 for o in all(l[1][d]) do
  f=o[5] or c
  rectfill(x+o[1],y+o[2],x+o[3],y+o[4],f)
 end
end

y=32

for i=0,11 do

 rect(56,y+i*6,71,y+6+i*6,0)
 rectfill(57,y+1+i*6,70,y+5+i*6,2)

 rectfill(8,y+3+i*6,55,y+3+i*6,0)
 rectfill(72,y+3+i*6,119,y+3+i*6,0)



 arrow(30,y+1+i*6,1,9)
 arrow(90,y+1+i*6,2,2)

 arrow(53,y+1+i*6,2,9)
 arrow(71,y+1+i*6,1,2)
end

 --[[
for i=0,11 do
 rect(56,24+i*8,72,32+i*8,0)
 rectfill(57,25+i*8,71,31+i*8,2)

 rectfill(8,28+i*8,55,28+i*8,0)
end
]]

 rect(56,y-14,71,y,0)
 rectfill(57,y-13,70,y-1,2)


rectfill(8,y,11,y+72,0)
rectfill(9,y+1,10,y+71,9)
rectfill()

rectfill(116,y,119,y+72,0)
rectfill(117,y+1,118,y+71,2)

rect(1,y,3,y+4,0)
rect(3,y+1,4,y+3,0)
rectfill(2,y+1,2,y+3,2)
--rectfill(3,y+2,3,y+2)
pset(3,y+2,2)

rect(1,y+10,3,y+14,0)
rectfill(2,y+11,2,y+13,2)


--[[
--rectfill(0,41,56,42,0)

rectfill(20,39,23,44,0)
rectfill(23,40,25,43,0)
rectfill(21,40,22,43,2)
rectfill(23,41,24,42,2)

--rectfill(0,55,56,56,0)

rectfill(20,53,25,58,0)
rectfill(21,54,24,57,2)

--spr(4,10,60)
]]

__gfx__
44444444444444444444444444444444444444444444444400000000000000004444444444444444000000000000000000000000000000000000000000000000
44444444444000444000000444444444400004444444444402222222222222200004444444444444000000000000000000000000000000000000000000000000
444444444440a004402222044444444440aa0004444444440222222222222220aa00044444444444000000000000000000000000000000000000000000000000
444444440000aa00002222000000000000aaaa00444444440222222222222220aaaa000000077000000000000000000000000000000000000000000000000000
444444440000aa00002222000000000000aaaa00444444440222222222222220aaaa000000770000000000000000000000000000000000000000000000000000
444444444440a004402222044444444440aa0004444444440222222222222220aa00044444444444000000000000000000000000000000000000000000000000
44444444444000444000000444444444400004444444444402222222222222200004444444444444000000000000000000000000000000000000000000000000
44444444444444444444444444444444444444444444444400000000000000004444444444444444000000000000000000000000000000000000000000000000
44444444444444444444444444444444444444444444444444444444444444444444444444444444000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000044444444444444444444444444444444000000000000000000000000000000000000000000000000
44444444444444444000444444444400022222220aaaaaaa40000044440000444444444444444444000000000000000000000000000000000000000000000000
444444444444444440a004444444400a022222220aaaaaaa40aaa044440aa0444444444444444444000000000000000000000000000000000000000000000000
444444440000000000aa0000000000aa022222220aaaaaaa00aaa000000aa0004444444444444444000000000000000000000000000000000000000000000000
444444444444444440a004444444400a022222220aaaaaaa40aaa044440aa0444444444444444444000000000000000000000000000000000000000000000000
44444444444444444000444444444400022222220aaaaaaa40000044440000444444444444444444000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000044444444444444444444444444444444000000000000000000000000000000000000000000000000

__map__
0505050505050505050505050510101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505171211111314101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505111117111314101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504030302030505111211111314101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505111111111315101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050506070809090905121314101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505110505050510101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050510101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
