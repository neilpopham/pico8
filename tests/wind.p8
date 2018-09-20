pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- wind
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

-- converts x/y co-ordinates into a screen memory address
function convert_point_to_address(x,y)
 return 0x6000+flr(x/2)+(y*64)
end

-- converts x/y co-ordinates into a general use memory address
function convert_point_to_general_use_address(x,y)
 return 0x4300+flr(x/2)+(y*64)
end

-- returns a table {c1,c2} containing the two colours
-- stored at the given screen memory address
function get_colour_pair(a)
 local b=peek(a)
 return {
  band(b,0b00001111),
  shr(band(b,0b11110000),4)
 }
end

function read_screen_area(x,y,w,h)
 w=w or 128
 h=h or 128
 local px={}
 local p
 ax={x,x+w-1}
 ay={y,y+h-1}
 a1=convert_point_to_address(x,y)
 a2=convert_point_to_address(ax[2],ay[2])
 while a2>a1 do
  if px[x]==nil then
   px[x]={}
   px[x+1]={}
  end
  p=get_colour_pair(a1)
  px[x][y]=p[1]
  px[x+1][y]=p[2]
  x=x+2
  if x>ax[2] then
   x=ax[1]
   y=y+1
  end
  a1=convert_point_to_address(x,y)
 end
 return px
end

-- reads a portion of screen memory
-- and creates a particle for each coloured pixel
-- use sparingly...
function convert_to_particles(x,y,w,h)
 w=w or 128
 h=h or 128
 ax={x,x+w-1}
 ay={y,y+h-1}
 a1=convert_point_to_address(x,y)
 a2=convert_point_to_address(ax[2],ay[2])
 while a2>a1 do
  local p=get_colour_pair(a1)
  for i=1,2 do
   if p[i]>0 then
    z=120+(x+i-1-ax[1])+((y-ay[1])*(rnd()+2))
    add(particles,create_particle(x+i-1,y,p[i],z))
   end
  end
  x=x+2
  if x>ax[2] then
   x=ax[1]
   y=y+1
  end
  a1=convert_point_to_address(x,y)
 end
end

function create_particle(x,y,colour,delay)
 local p={
  x=x,
  y=y,
  colour=colour,
  delay=delay,
  force=rnd(8)+2
 }
 return p
end

function _init()
 t=0
 cls()
 print("at times downtown",8,31,7)
 print("riding over galleries of air",8,41)
 print("so full of high excitement",8,51)
 print("howling",8,61)
 print("i borrow an old woman's hat",8,71)
 print("and fling it into the road",8,81)
 print("- james arthur",56,91,5)
 --memcpy(0x4300,0x6000,300)--8191)
 --cls()
 convert_to_particles(8,31,112,67)
end

function _update60()
 t=t+1
 if #particles>0 then
  for _,p in pairs(particles) do
   if t>p.delay then
    p.x=p.x+p.force
    p.y=p.y+rnd(6)-3
    if p.delay/t<0.97 and p.colour==7 then p.colour=6 end
    if p.delay/t<0.94 and p.colour==6 then p.colour=5 end
    printh(p.delay/t)
    if p.x>127 then del(particles,p) end
   end
  end
 else
  --printh("done")
 end
end

function _draw()
 cls()
 camera(0,0)
 for _,p in pairs(particles) do
  pset(p.x,p.y,p.colour)
 end
 --print(stat(0),0,0,10)
end
