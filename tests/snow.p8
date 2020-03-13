pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- snow
-- by neil popham

--[[
0x0 0x0fff sprite sheet (0-127)
0x1000 0x1fff sprite sheet (128-255) / map (rows 32-63) (shared)
0x2000 0x2fff map (rows 0-31)
0x3000 0x30ff sprite flags
0x3100 0x31ff music
0x3200 0x42ff sound effects
0x4300 0x5dff general use (or work ram)
0x5e00 0x5eff persistent cart data (64 numbers = 256 bytes)
0x5f00 0x5f3f draw state
0x5f40 0x5f7f hardware state
0x5f80 0x5fff gpio pins (128 bytes)
0x6000 0x7fff screen data (8k)
]]

local particles={}

function get_address(x,y)
 return 0x6000+flr(x/2)+(y*64) -- screen
 --return 0x4300+flr(x/2)+(y*64) -- user
end

function get_colour_pair(a)
 local b=peek(a)
 local l=b%16
 local r=(b-l)/16
 return {l,r}
end

function convert_to_particles(x,y,w,h)
 w=w or 128
 h=h or 128
 ax={x,x+w-1}
 ay={y,y+h-1}
 a2=get_address(ax[2],ay[2])
 repeat
  a1=get_address(x,y)
  local p=get_colour_pair(a1)
  for i=1,2 do
   if p[i]>0 then
    add(particles,create_particle(x+i-1,y,p[i]))
   end
  end
  x=x+2
  if x>ax[2] then
   x=ax[1]
   y=y+1
  end
 until a1>a2
end



function create_particle(x,y,colour)
 local p={
  x=x,
  y=-32,
  fy=y,
  colour=colour,
  force=rnd(2)+1,
 }
 return p
end

function _init()
 cls()
 print("it is the time of rain and snow",0,0,7)
 print("i spend sleepless nights",0,10)
 print("and watch the frost",0,20)
 print("frail as your love",0,30)
 print("gathers in the dawn",0,40)
 print("- izumi shikibu",68,50,5)
 a1=get_address(2,31)
 a2=get_address(128,56)
 --memcpy(0x4300,0x6000,a2-a1)
 --cls()
 convert_to_particles(0,0,128,67)
 t=#particles--+600
end

function _update60()
 ---[[
 for i=#particles,1,-1 do
  local p=particles[i]
  if p.y<p.fy and t<i then
   p.y=p.y+p.force*1.15
   if p.y>p.fy then p.y=p.fy end
  end
 end
 if t>0 then
  t=t-flr(rnd(3)+8)
  if t<0 then t=0 end
 end
 --]]
end

function _draw()
 cls()
 for _,p in pairs(particles) do
  pset(p.x,p.y+31,p.colour)
 end
 --print(stat(0),0,0,10)
end
