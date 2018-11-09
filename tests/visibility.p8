pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

screen={width=128,height=128,x2=127,y2=127}
canvas={width=16,height=16,x2=15,y2=15}
spritemap={width=16,height=16,x2=15,y2=15}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
ap={move90=4,move45=6,turn=1}

--screen={width=240,height=136,x2=239,y2=135}
--canvas={width=64,height=32,x2=63,y2=31}
--pad={left=2,right=3,up=0,down=1,btn1=4,btn2=5,btn3=6,btn4=7}

dir={left=1,right=2,up=3,down=4}

vec2={
 create=function(self,x,y)
  local o={x=x,y=y}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 distance=function(self,cell)
  local dx=cell.x-self.x
  local dy=cell.y-self.y
  return sqrt(dx^2+dy^2)
 end,
 manhattan=function(self,cell)
  return abs(cell.x-self.x)+abs(cell.y-self.y)
 end,
 index=function(self)
  return self.y*canvas.width+self.x
 end,
 difference=function(self,cell)
  local dx=cell.px.x-self.px.x
  local dy=cell.px.y-self.px.y
  return self:create(dx,dy)
 end,
}

tile={
 create=function(self,x,y)
  local o=vec2.create(self,x,y)
  o.px=vec2:create(o.x*8+4,o.y*8+4)
  return o
 end
} setmetatable(tile,{__index=vec2})



cells={}
visible={}
function create_cells()
 local t=time()
 local c={}
 printh(t)
 -- create an array of floor tiles
 for y=0,spritemap.y2 do
  for x=0,spritemap.x2 do
   local sprite=mget(x,y)
   if not fget(sprite,0) then
    local tile=tile:create(x,y)
    cells[tile:index()]=tile
    add(c,tile:index())
   end
  end
 end

 for i,c1 in pairs(cells) do
  visible[i]={}
  for j,c2 in pairs(cells) do
   if i==j then
    -- do nothing
   else
    local blocked=false
    local diff=c1:difference(c2)
    local angle=atan2(diff.x,-diff.y)
    local distance=sqrt(diff.x^2+diff.y^2)
    if distance<40 then
     local d=4
     while d<distance do
      local x=c1.px.x+cos(angle)*d
      local y=c1.px.y-sin(angle)*d
      --pset(x,y,i%14+1)
      local sprite=mget(flr(x/8),flr(y/8))
      if fget(sprite,0) then
       --pset(x,y,0)
       blocked=true
       break
      end
      d=d+4
     end
     if not blocked then
      add(visible[i],c2)
     end
    end
   end
  end
  --if i==40 then break end
 end
 local t2=time()
 printh(t2.." ("..(t2-t)..")")

 r=flr(rnd(#c)+1)
 i=c[r]
 c1=cells[i]
 spr(3,c1.x*8,c1.y*8)
 for j,c2 in pairs(visible[i]) do
  --printh(c1.x..","..c1.y.." -> "..c2.x..","..c2.y)
  spr(2,c2.x*8,c2.y*8)
 end
 for j,c2 in pairs(visible[i]) do
  line(c1.px.x,c1.px.y,c2.px.x,c2.px.y,2)
 end
 --map()
end

function _init()
 cls(1)
 map()
 create_cells()
end

function _update()

end

function _draw()

end
__gfx__
00000000dddddddd8888888899999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd8888888899999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd8888888899999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd8888888899999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd8888888899999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd8888888899999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd8888888899999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd8888888899999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000100000001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000100000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001010101000101010001010100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000100000101010001010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001010100010101010100010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000001000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000001000000010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000001000000010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000001000000010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
