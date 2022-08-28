pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- advent of code day 11 2021
-- by neil popham

function round(x)
 return flr(x+0.5)
end

function lpad(x,n)
 n=n or 2
 return sub("0000000"..x,-n)
end

function _init()
 data={
  "5251578181",
  "6158452313",
  "1818578571",
  "3844615143",
  "6857251244",
  "2375817613",
  "8883514435",
  "2321265735",
  "2857275182",
  "4821156644",
 }
 for y,row in pairs(data) do
   data[y] = split(row,"",true)
 end
 ticks=0
 total=0
 limit=100
 flashes=0
 turn=0
 total100=0
 offsets={};
 for x=-1,1 do
  for y=-1,1 do
   if not (x==0 and y==0) then
    add(offsets,{x,y})
   end
  end
 end
end

function _update()
 if ticks%3~=0 then return end
 ticks+=1
 if flashes==100 then return end
 turn+=1
 queue={}
 flashes=0
 for y,row in pairs(data) do
  for x,_ in pairs(row) do
   data[y][x]+=1
   add(queue,{x,y})
  end
 end
 while #queue>0 do
  local item=del(queue,queue[1])
  local x=item[1]
  local y=item[2]
  local energy=data[y][x]
  if energy>9 then
   data[y][x]=0
   flashes+=1
   for offset in all(offsets) do
    oy=y+offset[2]
    if data[oy]~=nil then
     ox=x+offset[1]
     energy=data[oy][ox]==nil and 0 or data[oy][ox]
     if energy>0 then
      data[oy][ox]+=1
      add(queue,{ox,oy})
     end
    end
   end
  end
 end
 total+=flashes
 if turn==limit then total100=total end
end

function _draw()
 cls(0)
 local cols={1,2,2,8,8,9,9,10,10}
 local x,y,row,energy
 for y,row in pairs(data) do
  for x,energy in pairs(row) do
   local sx=x*10
   local sy=y*10
   local size=energy==0 and 10 or energy
   sx+=(round(5-size/2))
   sy+=(round(5-size/2))
   rectfill(sx,sy,sx+size,sy+size,energy==0 and 7 or cols[energy])
  end
 end
 print("turn:"..lpad(turn,3),11,2,10)
 print("flashes:"..lpad(total100==0 and total or total100,4),64,2,11)
 ticks+=1
end
