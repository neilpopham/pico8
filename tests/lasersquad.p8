pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- roguelike
-- by neil popham

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
--screen={width=240,height=136,x2=239,y2=135}
--pad={left=2,right=3,up=0,down=1,btn1=4,btn2=5,btn3=6,btn4=7}

spritemap={width=128,height=64,x2=127,y2=63}
canvas={width=64,height=32,x2=63,y2=31}
ap={move90=4,move45=6,turn=1,open=2}

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
 diff=function(self,cell)
  local dx=cell.x-self.x
  local dy=cell.y-self.y
  return vec2:create(dx,dy)
 end,
 index=function(self)
  return self.y*canvas.width+self.x
 end
}

turnable={
 create=function(self,x,y)
  local o=vec2.create(self,x,y)
  return o
 end,
 face_from_angle=function(self,angle)
  return flr(angle/0.125)+1
 end,
 change_face=function(self,turn)
  self.face=self.face+turn
  if self.face<1 then self.face=8+self.face end
  if self.face>8 then self.face=self.face%9+1 end
 end,
 rotation=function(self,cell)
  local diff=self:diff(cell)
  local face=self:face_from_angle(atan2(diff.x,-diff.y))
  local oface=(face-self.face)%8
  return oface>4 and oface-8 or oface
 end,
 cost=function(self,cell)
  local diff=self:diff(cell)
  local cost=diff.x*diff.y==0 and ap.move90 or ap.move45
  return cost
 end,
} setmetatable(turnable,{__index=vec2})

tile={
 create=function(self,x,y)
  local o=turnable.create(self,x,y)
  o.px=vec2:create(o.x*16+8,o.y*16+8)
  return o
 end,
-- from_px=function(self,x,y)
--  return self:create(flr((x-8)/16),flr((y-8)/16))
-- end,
-- mget=function(self)
--  return mget(self.x*2,self.y*2)
-- end,
-- fget=function(self,flag)
--  return fget(self:mget(),flag)
-- end,
 diff=function(self,cell)
  local dx=cell.px.x-self.px.x
  local dy=cell.px.y-self.px.y
  return vec2:create(dx,dy)
 end
} setmetatable(tile,{__index=turnable})

astar={
 create=function(self,x,y,g,h,parent)
  local o=turnable.create(self,x,y)
  o.f=g+h
  o.g=g
  o.h=h
  o.parent=parent
  return o
 end
} setmetatable(astar,{__index=turnable})

neighbourer={
 reset=function(self,start)
  self.open={}
  self.closed={}
  self.path={}
  self.start=start
  self.max=32727
 end,
 _get_next=function(self)
  local best={0,32727}
  for i,vec in pairs(self.open) do
   if vec.f<best[2] and vec.g<self.max then
    best={i,vec.f}
   end
  end
  return best[1]==0 and nil or self.open[best[1]]
 end,
 _add_neighbour=function(self,current,cell)
  local idx=cell:index()
  if type(cells[idx])=="table" then
   local exists=false
   local g=self:get_g(current,cell)
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
    self.open[idx]=self:new(cell,g,current)
   end
  end
 end,
 _add_neighbours=function(self,current)
  for x=-1,1 do
   for y=-1,1 do
    if not (x==0 and y==0) then
     local cell=turnable:create(current.x+x,current.y+y)
     if cell.x>0 and cell.y>0 and cell.x<canvas.width and cell.y<canvas.height then
      self:_add_neighbour(current,cell)
     end
    end
   end
  end
 end
}

pathfinder={
 get_h=function(self,cell)
  return cell:distance(self.finish)
 end,
 get_g=function(self,current,cell)
  local g
  if current.x==cell.x or current.y==cell.y then g=1 else g=1.5 end
  --printh("g:"..g)
  return current.g+g
 end,
 new=function(self,cell,g,parent)
  return astar:create(cell.x,cell.y,g,self:get_h(cell),parent)
 end,
 find=function(self,start,finish,max)
  max=max or 32727
  self:reset()
  self.finish=finish
  self.max=max
  self.open[start:index()]=self:new(start,0)
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
    for i=#t,1,-1 do add(self.path,t[i]) end
    return true
   end
   self.closed[idx]=current
   self:_add_neighbours(current)
   self.open[idx]=nil
   return self:_check_open()
  end
 end
} setmetatable(pathfinder,{__index=neighbourer})

ranger={
 get_h=function(self,cell)
  return 0
 end,
 get_g=function(self,current,cell)
  local turn=abs(current:rotation(cell))
  local g=turn*ap.turn
  g=g+((current.x==cell.x or current.y==cell.y) and ap.move90 or ap.move45)
  return current.g+g
 end,
 new=function(self,cell,g,parent)
  local a=astar:create(cell.x,cell.y,g,0,parent)
  if type(parent)=="table" then
    a.face=parent.face
    local turn=parent:rotation(cell)
    a:change_face(turn)
  else
   a.face=cell.face
  end
  return a
 end,
 create=function(self,start,ap)
  self:reset()
  self.ap=ap
  self.open[start:index()]=self:new(start,0)
  if self:_check_open() then
   return self.closed
  end
 end,
 _check_open=function(self)
  local current=self:_get_next()
  if current==nil then
   return true
  else
   local idx=current:index()
   if current.g<=self.ap then
    self.closed[idx]=current
    self:_add_neighbours(current)
   end
   self.open[idx]=nil
   return self:_check_open()
  end
 end
} setmetatable(ranger,{__index=neighbourer})

--[[

explanation of some ap values
https://www.lemonamiga.com/games/docs.php?id=961

taking over 50 seconds to compute
perhaps record visibility of each tile as required
1. check the tiles that an ai could move to
2. if visibility not known
 a. calculate it
 b. store it under the cell index for future use
3. if visibility already known use that
4. maybe if path includes a door recalculate (or don't ever store)? door may be open this time

could use a sprite flag to record whether a cell is in a room
nb: as each tile is 2x2 but we only look for flags in top left only 1 sprite needs to be different
use this flag to work out danger from behind

sprite flags:
0. solid
1. room
2. doorway
3. starting square

grenades can tear down walls, need broken wall sprites

maintain array of cells seen by ai (neceessary? will change!)
ai can check a room to see if there is anyone in it, if not marked as safe
so maybe our array is just maintained per turn?

basically, want to be able to stand in the door of a room
and know that ai should be pointing outward at some angle
could basically treat seen cells as wall, so that ai faces away
there is something special about a sealed room, ai should know that it is safe

test: put ai at one cell and tell it to go to another
test it being direct and cautious
watch what it does
start with number of ap, 4 to go straight, 6 to go diagonally

--]]

cells={}
mapping={
 --[[
 cell_indexes={},
 current_key=1,
 progress=function(self)
  return flr((self.current_key/#self.cell_indexes)*100)
 end,
 update=function(self)
  if self.current_key<=#self.cell_indexes then
   self:record_visibility(self.cell_indexes[self.current_key])
   self.current_key=self.current_key+1
  else
   if self.current_key==#self.cell_indexes+1 then
    for i,cell in pairs(cells) do
     local s=0
     for j=1,8 do s=s+cell.visibility[j] end
     print(s,cell.tile.x*16+2,cell.tile.y*16+2,7)
    end
    self.current_key=self.current_key+1
   end
   --printh(time())
  end
 end,
 ]]
 create=function(self)
  for y=0,spritemap.y2,2 do
   for x=0,spritemap.x2,2 do
    local sprite=mget(x,y)
    if not fget(sprite,0) then
     local tile=tile:create(x/2,y/2)
     local i=tile:index()
     cells[i]={tile=tile,visibility={}}
    end
   end
  end
 end,
 record_visibility=function(self,i)
  for idx=1,9 do cells[i].visibility[idx]=0 end
  for x=-8,8 do
   for y=-8,8 do
    if not (x==0 and y==0) then
     local c2=tile:create(cells[i].tile.x+x,cells[i].tile.y+y)
     local j=c2:index()
     if cells[j]~=nil then
      local blocked=false
      local diff=cells[i].tile:diff(c2)
      local angle=atan2(diff.x,-diff.y)
      local distance=sqrt(diff.x^2+diff.y^2)
      local dd=8
      local d=dd
      while d<distance do
       local x=cells[i].tile.px.x+cos(angle)*d
       local y=cells[i].tile.px.y-sin(angle)*d
       local sprite=mget(flr(x/8),flr(y/8))
       if fget(sprite,0) then
        blocked=true
        break
       end
       d=d+dd
      end
      if not blocked then
       local idx=turnable:face_from_angle(angle)
       cells[i].visibility[idx]=cells[i].visibility[idx]+1
       cells[i].visibility[9]=cells[i].visibility[9]+1 -- total for cell
      end
     end
    end
   end
  end
 end
}

function _init()
 --cls()
 --map(0,0,0,0,16,16)
 --camera(128,128)
 printh("init")
 mapping:create()
 --line(0,0,100,0,1)

 p=turnable:create(2,2)
 p.face=6
 p.ap=40

 local t=time()
 s=vec2:create(2,2)
 f=vec2:create(58,27)
 local path=pathfinder:find(s,f)
 printh("pathfinding:"..time()-t)

 --[[
 for k,v in pairs(path) do
  turn=p:rotation(v)
  local cost=abs(turn)
  if p.ap>cost then
   p.face=p.face+turn
   if p.face<1 then p.face=8+p.face end
   if p.face>8 then p.face=p.face%9+1 end
   p.ap=p.ap-cost
  end
  local cost=p:cost(v)
  if p.ap>cost then
   p.x=v.x
   p.y=v.y
   p.ap=p.ap-cost
   --for x=0,1 do for y=0,1 do mset(2*v.x+x,2*v.y+y,19+turn) end end
   for x=0,1 do for y=0,1 do mset(2*v.x+x,2*v.y+y,31+p.face) end end
  end
  printh("ap:"..p.ap)
 end
 --]]

 for k,v in pairs(path) do
  printh(k..":"..(v.x)..","..(v.y))
  turn=p:rotation(v)
  --printh("face:"..p.face.." turn:"..turn)
  p.face=p.face+turn
  if p.face<1 then p.face=8+p.face end
  if p.face>8 then p.face=p.face%9+1 end
  p.x=v.x
  p.y=v.y
  --for x=0,1 do for y=0,1 do spr(2,8*(2*v.x+x),8*(2*v.y+y)) end end
  --for x=0,1 do for y=0,1 do mset(2*v.x+x,2*v.y+y,19+turn) end end
  for x=0,1 do for y=0,1 do mset(2*v.x+x,2*v.y+y,31+p.face) end end
 end


 printh("ranger")
 --p=turnable:create(3,3)
 --p=turnable:create(4,6)
 p=turnable:create(3,8)
 p.face=2
 p.ap=40
 local t=time()
 local range=ranger:create(p,p.ap)
 printh("ranging:"..time()-t)
 for k,v in pairs(range) do
  printh(k..":"..v.x..","..v.y.." g:"..v.g)
  for x=0,1 do for y=0,1 do mset(2*v.x+x,2*v.y+y,48+flr(v.g/5)) end end
 end

--[[
 local t=time()
 for k,v in pairs(range) do
  if #cells[k].visibility==0 then
   mapping:record_visibility(k)
   --printh("visibility:"..cells[k].visibility[9])
  end
 end
 printh("visibility:"..time()-t)
--]]

end

function _update()
 --mapping:update()
 if btn(pad.left) then p.x=p.x-1 end
 if btn(pad.right) then p.x=p.x+1 end
 if btn(pad.up) then p.y=p.y-1 end
 if btn(pad.down) then p.y=p.y+1 end
end

function _draw()
 cls()

 --map(p.x,p.y,0,0,16,16)
 map(0,0,0,0,128,64)
 camera(p.x*8,p.y*8)

 --printh(p.x..","..p.y)

 --fillp(0b0101101001011010.1)
 --rectfill(0,0,screen.x2,screen.y2,0)
 --fillp()
 --rectfill(0,0,64,screen.y2,1)
 --line(64,0,64,screen.y2,0)

 --camera()
 --line(0,0,100,0,1)
 --line(0,0,mapping:progress(),0,8)



end

__gfx__
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000777777787777777600000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000822222226ddddddd00000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccc000ccccc000ccccc00cccccc000ccccc00cccccc000ccccc000ccccc0c0c0000000000000000000000000000000000000000000000000000000000000000
cccccc0ccccccc0cccccc0cccccc0c0cccccc0cccccccc0ccccccc0ccccc0c0c0000000000000000000000000000000000000000000000000000000000000000
c00c000cc00c000cc00cc0cccccc0c0cccccc0cccccc000ccccc000ccccc000c0000000000000000000000000000000000000000000000000000000000000000
cccccc0ccccc0cccccccc0cccccc0c0cccccc0cccccc0ccccccccc0ccccccc0c0000000000000000000000000000000000000000000000000000000000000000
cccc000ccccc000ccccc000ccccc000ccccc000ccccc000ccccc000ccccccc0c0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccc0cccc0cccccccccc0ccccccccc0cccc0ccccc0000cccccc0ccccccc0000c0000000000000000000000000000000000000000000000000000000000000000
ccccc0cccc0ccccccccc0cccccccc0cccc0cccccc00ccccccc000cccccccc00c0000000000000000000000000000000000000000000000000000000000000000
c000000cccc0cc0ccccc0cccc0cc0cccc000000cc0c0ccccc0c0c0cccccc0c0c0000000000000000000000000000000000000000000000000000000000000000
ccccc0cccccc0c0ccc0c0c0cc0c0cccccc0cccccc0cc0cccccc0ccccccc0cc0c0000000000000000000000000000000000000000000000000000000000000000
cccc0cccccccc00cccc000ccc00cccccccc0ccccccccc0ccccc0cccccc0ccccc0000000000000000000000000000000000000000000000000000000000000000
ccccccccccc0000ccccc0cccc0000ccccccccccccccccc0cccc0ccccc0cccccc0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffff000000000000000000000000000000000000000000000000
eeee00eeeeee000eeeee000eeeee0e0eeeee000eeeee0eeeeeee000eeeee000eeeee000effffffff000000000000000000000000000000000000000000000000
eeeee0eeeeeeee0eeeeeee0eeeee0e0eeeee0eeeeeee0eeeeeeeee0eeeee0e0eeeee0e0effffffff000000000000000000000000000000000000000000000000
eeeee0eeeeee000eeeee000eeeee000eeeee000eeeee000eeeeeee0eeeee000eeeee000effffffff000000000000000000000000000000000000000000000000
eeeee0eeeeee0eeeeeeeee0eeeeeee0eeeeeee0eeeee0e0eeeeeee0eeeee0e0eeeeeee0effffffff000000000000000000000000000000000000000000000000
eeee000eeeee000eeeee000eeeeeee0eeeee000eeeee000eeeeeee0eeeee000eeeeeee0effffffff000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffff000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffff000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30303030101030303030101010101010303010101010101030303030101010101010303010101010101030303030101030303030303030303030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101010101010303010101010101030303030101010101010303010101010101030303030101030303030303030303030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030101010103030101010103030303030303030
30301010303030303030303030303030303030301010303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030101010103030101010103030303030303030
30301010303030303030303030303030303030301010303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030303030303030303030303030101030303030303030303030303030303030101030303030101030303030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030303030303030303030303030101030303030303030303030303030303030101030303030101030303030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030101030303030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030101030303030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101010101010101010101010101030303030101010101010101010101010101030303030101010101010101010101010101030301010
10101010303030301010101010101010101010101010303030301010101010101010101010101010101010101010101010101010101030303030101030303030
30303030101030303030101010101010101010101010101030303030101010101010101010101010101030303030101010101010101010101010101030301010
10101010303030301010101010101010101010101010303030301010101010101010101010101010101010101010101010101010101030303030101030303030
30303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303030303030
30301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303030303030
30301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303030303030
30301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303030303030
30301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101010101010101030301010101010101010101030301010101010103030303010101010101030301010101010103030303010103030303030303030
30301010303030301010101010103030101010101010303030301010101010101010303010101010101010101010101010103030101010101010101030303030
30303030101010101010101030301010101010101010101030301010101010103030303010101010101030301010101010103030303010103030303030303030
30301010303030301010101010103030101010101010303030301010101010101010303010101010101010101010101010103030101010101010101030303030
30303030101030303030303030303030303010103030303030303030303010103030303010103030303030303030303010103030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303010103030303030303030303010103030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303010103030303030303030303010103030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303010103030303030303030303010103030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303010103030303010101010101010101010101010103030303010101010101030301010
10101010303030301010101010101010101010101010303030303030303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303010103030303010101010101010101010101010103030303010101010101030301010
10101010303030301010101010101010101010101010303030303030303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101030303030
30303030101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
__gff__
0001000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030301010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010103030303
0303030301010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030301010101010101010101010101010303010101010101030303030101010101010101010101010101030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030301010101010101010101010101010303010101010101030303030101010101010101010101010101030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303010101010101030301010101010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303010101010101030301010101010103030303
0303030301010101010103030101010101010101010101010303010101010101010101010303010101010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010101010103030101010101010101010101010303010101010101010101010303010101010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030303030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030303030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030301010101010103030101010101010303030301010101010101010101010101010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030301010101010103030101010101010303030301010101010101010101010101010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030301010303030303030303030301010303030301010303030303030303030301010303030301010303030303030303030303030303030303030101030303030101010101010101010101010101030303030101010101010303010101010101010101010101010103030101010101010101010103030303
0303030301010303030301010303030303030303030301010303030301010303030303030303030301010303030301010303030303030303030303030303030303030101030303030101010101010101010101010101030303030101010101010303010101010101010101010101010103030101010101010101010103030303
0303030301010303030301010303030303030303030301010303030301010303030303030303030301010303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030301010303030303030303030301010303030301010303030303030303030301010303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030301010101010101010101010101010303030301010101010103030101010101010303030301010303030303030303030303030303030303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030301010101010101010101010101010303030301010101010103030101010101010303030301010303030303030303030303030303030303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101010101010101010101010101030303030101010101010101010101010101010101010101010101010101010103030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101010101010101010101010101030303030101010101010101010101010101010101010101010101010101010103030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303010103030303030303030101030303030303010103030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303010103030303030303030101030303030303010103030303010103030303
