pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

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
  return self.y*16+self.x
 end
}

astar={
 create=function(self,x,y,g,h,parent)
  local o=vec2:create(x,y)
  o.f=g+h
  o.g=g
  o.h=h
  o.parent=parent
  return o
 end
} setmetatable(astar,{__index=vec2})

pathfinder={
 find=function(self,start,finish)
  self.open={}
  self.closed={}
  self.path={}
  self.start=start
  self.finish=finish
  self.open[start:index()]=astar:create(start.x,start.y,0,start:distance(finish))
  if self:_check_open() then
   return self.path
  end
 end,
 _check_open=function(self)
  local current=self:_get_next()
  if current==nil then
   return false
  else
   local idx=current:index()
   if idx==self.finish:index() then
    local t={}
    local cell=current
    while cell.parent do
     add(t,vec2:create(cell.x,cell.y))
     cell=cell.parent
    end
    --add(t,vec2:create(cell.x,cell.y))
    for i=#t,1,-1 do
     add(self.path,t[i])
    end
    return true
   end
   self.closed[idx]=current
   self:_add_neighbours(current)
   self.open[idx]=nil
   self:_check_open()
   return true
  end
 end,
 _get_next=function(self)
  local best={0,32727}
  for i,vec in pairs(self.open) do
   if vec.f<best[2] then
    best={i,vec.f}
   end
  end
  return best[1]==0 and nil or self.open[best[1]]
 end,
 _add_neighbour=function(self,current,cell)
  local idx=cell:index()
  local tile=mget(cell.x,cell.y)
  if not fget(tile,0) then
   local exists=false
   local g=current.g+((current.x==cell.x or current.y==cell.y) and 1 or 1.5)
   if type(self.closed[idx])=="table" then
    exists=true
   elseif type(self.open[idx])=="table" then
    if g<self.open[idx].g then
     self.open[idx].g=g
     self.open[idx].f=self.open[idx].g+self.open[idx].h
     self.open[idx].parent=current
    end
    exists=true
   end
   if not exists then
    self.open[idx]=astar:create(cell.x,cell.y,g,cell:distance(self.finish),current)
   end
  end
 end,
 _add_neighbours=function(self,current)
 --[[
  local offset={{0,-1},{1,0},{0,1},{-1,0}}
  for _,o in pairs(offset) do
   self:_add_neighbour(current,o[1],o[2])
  end
  --]]
  for x=-1,1 do
   for y=-1,1 do
    if not (x==0 and y==0) then
     local cell=vec2:create(current.x+x,current.y+y)
     self:_add_neighbour(current,cell)
    end
   end
  end
 end
}

function _init()
 s=vec2:create(2,2)
 f=vec2:create(12,6)
end

function _update60()
 if btnp(0) then f.x=f.x-1 end
 if btnp(1) then f.x=f.x+1 end
 if btnp(2) then f.y=f.y-1 end
 if btnp(3) then f.y=f.y+1 end
end

function _draw()
 cls()
 map(0,0)
 spr(3,s.x*8,s.y*8)
 spr(3,f.x*8,f.y*8)
 local t=time()
 local path=pathfinder:find(s,f)
 printh("time:"..time()-t)
 for _,v in pairs(path) do
  spr(2,v.x*8,v.y*8)
 end
 print(type(path).." "..#path,0,0,7)
end

__gfx__
00000000999999995555555588888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555588888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700999999995555555588888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000999999995555555588888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000999999995555555588888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700999999995555555588888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555588888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999995555555588888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000001000000010001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000001000101010001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000001000001000000010101000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000001000001000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000101010101000001000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000001010101000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000100000101010001000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000100000100010000000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000100000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000101010100010101010100010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
