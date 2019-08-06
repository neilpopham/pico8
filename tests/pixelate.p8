pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by neil popham

-- converts x/y co-ordinates into a screen memory address
function get_address(x,y)
 return 0x6000+flr(x/2)+(y*64)
end

-- converts x/y co-ordinates into a general use memory address
function get_general_use_address(x,y)
 return 0x4300+flr(x/2)+(y*64)
end

-- returns a table {c1,c2} containing the two colours
-- stored at the given screen memory address
function get_colour_pair(a)
 local b=peek(a)
 local l=b%16
 local r=(b-l)/16
 return {l,r}
end


function get_screen_colours(x,y)
 local b=peek(0x6000+flr(x/2)+(y*64))
 local l=b%16
 local r=(b-l)/16
 return {l,r}
end

function get_screen_colour(x,y)
 local b=peek(0x6000+flr(x/2)+(y*64))
 return b%16
end

function _init()
 data={}
 p=false
end

function _update60()
 if p and s>1 and btnp(4) then s-=1 end
 if btnp(5) and s<5 then s+=1 end
 if not p and btnp(4) then
  for x=0,127,2 do
   data[x]={}
   for y=0,127,2 do
    data[x][y]=get_screen_colour(x,y)
   end
  end
  p=true
  s=1
  t=0
 end
end

function _draw()
 if p==false then
  --pset(rnd(127),rnd(127),rnd(14)+1)
  circfill(rnd(127),rnd(127),rnd(15),rnd(14)+1)
  --print("press z to pixelate",0,0,0)
  --print("and then use z and x to zoom in and out",0,8,0)
 elseif s<6 then
  for x=0,127,2^s do
   for y=0,127,2^s do
    rectfill(x,y,x+2^s-1,y+2^s-1,data[x][y])
   end
  end
  t+=1
  --if t>5 then s+=1 t=0 end
 end

end
