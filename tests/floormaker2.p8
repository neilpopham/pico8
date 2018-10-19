pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
canvas={width=128,height=32,x2=127,y2=31,ratio=4}

--screen={width=240,height=136,x2=239,y2=135}
--pad={left=2,right=3,up=0,down=1,btn1=4,btn2=5,btn3=6,btn4=7}
--canvas={width=240,height=136,x2=239,y2=135,ratio=2}

floormaker={
 create=function(self,params)
  params=params or {}
  local o={}
  o.t90=params.t90 or 0.1
  o.t180=params.t180 or 0.05
  o.x2=params.x2 or 0.5
  o.x3=params.x3 or 0.4
  o.limit=params.limit or 6
  o.new=params.new or 0.05
  o.life=params.life or 0.02
  o.angle=params.angle or 0
  o.x=params.x or flr(canvas.width/2)
  o.y=params.y or flr(canvas.height/2)
  o.total=params.total or 192
  o.params=extend(o)
  setmetatable(o,self)
  self.__index=self
  canvas.pow={
   x=max(3,flr(canvas.width/20)),
   y=max(3,flr(canvas.height/20))
  }
  return o
 end,
 run=function(self)
  self.complete=false
  self.threads={}
  self.cells={}
  self.count=0
  self.min={x=self.x,y=self.y}
  self.max={x=self.x,y=self.y}
  self:spawn()
  repeat
   for _,thread in pairs(self.threads) do
    local done=thread:update(self)
    if done then
     if #self.threads==1 then self:spawn() end
     del(self.threads,thread)
    end
   end
  until self.count>=self.total
  -- shift cells so that the map starts at 0,0
  local dx=self.max.x-self.min.x+1
  local dy=self.max.y-self.min.y+1
  local sx=flr(screen.width/8)
  local sy=flr(screen.height/8)
  local ox=max(1,flr((sx-dx)/2))
  local oy=max(1,flr((sy-dy)/2))
  self.width=max(sx,ox*2+dx)
  self.height=max(sy,oy*2+dy)
  local ox=ox-self.min.x
  local oy=oy-self.min.y
  local cells={}
  for index,cell in pairs(self.cells) do
   local i=self:get_index({cell[1]+ox,cell[2]+oy})
   cells[i]={cell[1]+ox,cell[2]+oy}
  end
  self.cells=cells
  self.x=self.x+ox
  self.y=self.y+oy
  self.complete=true
  return self.cells
 end,
 spawn=function(self,params)
  local t=self:thread(params)
  t:add_cell(self,{t.x,t.y})
  add(self.threads,t)
 end,
 get_index=function(self,cell)
  return cell[2]*canvas.width+cell[1]
 end,
 thread=function(self,params)
  params=params or {}
  local o=extend(self.params,params)
  o.lx=1
  o.ly=1
  o.update=function(self,parent)
   self.lx=cos(self.angle)
   self.ly=-sin(self.angle)
   local cells={{0,0}}
   local added=0
   local done=false
   local t90=self.t90
   local da=0.25
   local m=0.5
   local n=0
   local t=0
   -- #1 if we're moving up or down then
   -- increase the chance (t90) to turn 90º
   -- as we need to stay wider than higher
   -- #2 if we're close to the edge of the canvas
   -- increase the chance (t90) to turn 90º
   -- and increase the chance (m)
   -- that the correct turn (da) is chosen
   if self.angle==0.25 or self.angle==0.75 then
    t90=t90*canvas.ratio
    n=min(self.y,canvas.y2-self.y)
    if n==0 then t=1 else t=2/n end
    t90=max(t90,t)
    m=max(0.5,(1-n/canvas.y2)^canvas.pow.y)
    if self.x<canvas.width/2 then
     da=self.angle-0.5
    else
     da=0.5-self.angle
    end
   else
    n=min(self.x,canvas.x2-self.x)
    if n==0 then t=1 else t=2/n end
    t90=max(t90,t)
    m=max(0.5,(1-n/canvas.x2)^canvas.pow.x)
    if self.y<canvas.height/2 then
     da=0.25-self.angle
    else
     da=self.angle-0.25
    end
   end
   -- change direction
   local r=rnd()
   if r<t90 then
    if rnd()<m then
     self.angle=self.angle+da
    else
     self.angle=self.angle-da
    end
   elseif r<t90+self.t180 then
    self.angle=self.angle+0.5
   end
   -- set new position
   self.angle=self.angle%1
   self.x=self.x+cos(self.angle)
   self.y=self.y-sin(self.angle)
   -- add room
   r=rnd()
   if r<self.x2 then
    cells=self:get_room(2)
   elseif r<self.x2+self.x3 then
    cells=self:get_room(3)
   end
   -- spawn new thread
   if #parent.threads<parent.limit then
    r=rnd()
    if r<self.new then
     local angle=self:get_angle()
     local m=parent:spawn({x=self.x,y=self.y,angle=angle})
    end
   end
   -- kill this thread
   r=rnd()
   if r<#parent.threads*self.life then
    done=true
   end
   -- kill this thread if we've strayed off canvas
   if self.x<0 or self.x>canvas.x2
    or self.y<0 or self.y>canvas.y2 then
    done=true
    cells={}
   end
   -- add the cells to the collection
   for _,cell in pairs(cells) do
    self:add_cell(
     parent,
     {self.x+cell[1],self.y+cell[2]}
    )
   end
   -- return the thread's status
   return done
  end
  o.add_cell=function(self,parent,cell)
   local index=parent:get_index(cell)
   if parent.cells[index]==nil then
    parent.cells[index]=cell
    parent.count=parent.count+1
    if cell[1]<parent.min.x then
     parent.min.x = cell[1]
    elseif cell[1]>parent.max.x then
     parent.max.x = cell[1]
    end
    if cell[2]<parent.min.y then
     parent.min.y = cell[2]
    elseif cell[2]>parent.max.y then
     parent.max.y = cell[2]
    end
   end
  end
  o.get_room=function(self,size)
   local dx=-self.lx
   local dy=-self.ly
   if self.x<size+4
    then dx=1
   elseif self.x>canvas.x2-size-4 then
    dx=-1
   end
   if self.y<size+4 then
    dy=1
   elseif self.y>canvas.y2-size-4 then
    dy=-1
   end
   local r={}
   for x=0,size-1 do
    for y=0,size-1 do
     add(r,{x*dx,y*dy})
    end
   end
   return r
  end
  o.get_angle=function(self)
   local options={}
   if self.x>7 then add(options,0) end
   if self.x<canvas.width-8 then add(options,0.5) end
   if self.y>7 then add(options,0.75) end
   if self.y<canvas.height-8 then add(options,0.25) end
   return options[flr(rnd(4)+1)]
   --return flr(rnd(4))*0.25
  end
  return o
 end
}

function reset()
 maker=floormaker:create()
 cells=maker:run()
 printh("width:"..maker.width.." height:"..maker.height)
 cam=create_camera({x=maker.x*8,y=maker.y*8},maker.width*8,maker.height*8)
end

function _init()
 printh("==================")
 t=0
 reset()
end

function _update()
 t=t+1
 if t%180==0 then reset() end
 cam:update()
end

function _draw()
 cls()

 camera(cam:position())
 local sprite={roof=1,wall=2,shadow=3,floor=4}

 memset(0x2000,0,0x1000)
 for x=0,maker.width-1 do
  for y=0,maker.height-1 do
   mset(x,y,sprite.roof)
  end
 end
 for index,cell in pairs(cells) do
  local north={cell[1],cell[2]-1}
  local n=maker:get_index(north)
  if cells[n]==nil then
   mset(cell[1],cell[2],sprite.wall)
  else
   north={cell[1],cell[2]-2}
   n=maker:get_index(north)
   if cells[n]==nil then
    mset(cell[1],cell[2],sprite.shadow)
   else
    mset(cell[1],cell[2],sprite.floor)
   end
  end
 end
 --if t==1 then cstore(0x2000,0x2000,0x1000,'floormaker2map.p8') end
 map(0,0)
 spr(5,maker.x*8,maker.y*8)

 camera(0,0)
 rectfill(0,0,maker.width-1,maker.height-1,1)
 for index,cell in pairs(cells) do
  pset(cell[1],cell[2],6)
 end
 pset(maker.x,maker.y,8)
 local cx,cy=cam:position()
 rect(cx/8,cy/8,cx/8+screen.width/8-1,cy/8+screen.height/8-1,3)

end

function extend(...)
 local o,arg={},{...}
 for _,a in pairs(arg) do
  for k,v in pairs(a) do o[k]=v end
 end
 return o
end

function create_camera(item,x,y)
 local c={
  target=item,
  x=item.x,
  y=item.y,
  buffer=16,
  min={x=8*flr(screen.width/16),y=8*flr(screen.height/16)}
 }
 c.max={x=x-c.min.x,y=y-c.min.y,shift=2}
 c.update=function(self)
  local min_x = self.x-self.buffer
  local max_x = self.x+self.buffer
  local min_y = self.y-self.buffer
  local max_y = self.y+self.buffer
  if min_x>self.target.x then
   self.x=self.x+min(self.target.x-min_x,self.max.shift)
  end
  if max_x<self.target.x then
   self.x=self.x+min(self.target.x-max_x,self.max.shift)
  end
  if min_y>self.target.y then
   self.y=self.y+min(self.target.y-min_y,self.max.shift)
  end
  if max_y<self.target.y then
   self.y=self.y+min(self.target.y-max_y,self.max.shift)
  end
  if self.x<self.min.x then
   self.x=self.min.x
  elseif self.x>self.max.x then
   self.x=self.max.x
  end
  if self.y<self.min.y then
   self.y=self.min.y
  elseif self.y>self.max.y then
   self.y=self.max.y
  end
 end
 c.position=function(self)
  return self.x-self.min.x,self.y-self.min.y
 end
 return c
end

function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

__gfx__
77777777999999994444444466666666777777771111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777999999994444444466666666777777771111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777999999994444444466666666777777771111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777999999994444444467676767777777771111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777999999996666666677777777777777771111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777999999996666666677777777777777771111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777999999996666666677777777777777771111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777999999996666666677777777777777771111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101020101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101030202010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101040303020202020202020202020101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101040404010101010101030301010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010401010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010202020102010101010101010101010101010101010401010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010103030203020101010101010101010101010101020402020101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020101010101010104010104030101010101010101010101010101030403030202020202020202020202020202020202020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103030103030201010101010101010104040101010101010101010101010101010401010103030303030303030303010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040204040302020202020202020204040202020202020202020202020202020402020204040404010104040404010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040301040403030303030303010104040303030303030303030301010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040402040404040404040404020204040404040104010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040403040401010101010101010101010401040101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104040404040401010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101040404040401010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
