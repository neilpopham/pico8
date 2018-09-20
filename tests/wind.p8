pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

-- 0x6000 0x7fff screen data (8k)

local particles={}

-- converts x/y co-ordinates into a screen memory address
function convert_point_to_address(x,y)
 return 0x6000+flr(x/2)+(y*64)
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
 print("at times downtown",0,0,7)
 print("riding over galleries of air",0,10)
 print("so full of high excitement",0,20)
 print("howling",0,30)
 print("i borrow an old woman's hat",0,40)
 print("and fling it into the road",0,50)
 print("- james arthur",56,60,5)
 convert_to_particles(0,0,112,66)
 cls()
end

function _update60()
 t=t+1
 for _,p in pairs(particles) do
  if t>p.delay then
   p.x=p.x+p.force
   p.y=p.y+rnd(6)-3
   if p.x>127 then del(particles,p) end
  end
 end
end

function _draw()
 cls()
 for _,p in pairs(particles) do
  pset(p.x+8,p.y+31,p.colour)
 end
 --print(stat(0),0,0,10)
end
