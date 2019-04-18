pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- roguelike
-- by neil popham

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
canvas={width=128,height=32,x2=127,y2=31,ratio=4}

--screen={width=240,height=136,x2=239,y2=135}
--pad={left=2,right=3,up=0,down=1,btn1=4,btn2=5,btn3=6,btn4=7}
--canvas={width=240,height=136,x2=239,y2=135,ratio=2}

dir={left=1,right=2,up=3,down=4}
drag=0.5

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
 find=function(self,start,finish,max)
  self.open={}
  self.closed={}
  self.path={}
  self.start=start
  self.finish=finish
  self.max=max
  add(self.open,astar:create(start.x,start.y,0,start:distance(finish)))
  if self:_check_open() then
   return self.path
  end
 end,
 _check_open=function(self)
  local current=self:_get_next()
  if current==nil then
   return false
  else
   if current.x==self.finish.x and current.y==self.finish.y then
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
   add(self.closed,current)
   self:_add_neighbours(current)
   del(self.open,current)
   self:_check_open()
   return true
  end
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
 _add_neighbour=function(self,current,x,y)
  local tx=current.x+x
  local ty=current.y+y
  local tile=mget(tx,ty)
  if not fget(tile,0) then
   local exists=false
   --[[
   local g=current.g+1
   --]]
   local g=current.g+sqrt(x^2+y^2)
   for _,closed in pairs(self.closed) do
    if closed.x==tx and closed.y==ty then
     exists=true
     break
    end
   end
   if not exists then
    for _,open in pairs(self.open) do
     if open.x==tx and open.y==ty then
      if g<open.g then
       open.g=g
       open.f=open.g+open.h
       open.parent=current
      end
      exists=true
      break
     end
    end
   end
   if not exists then
    local cell=vec2:create(tx,ty)
    add(
     self.open,
     astar:create(tx,ty,g,cell:distance(self.finish),current)
    )
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
     self:_add_neighbour(current,x,y)
    end
   end
  end
 end
}

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
  o.total=params.total or 320
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
  -- loop through threads until we have enough tiles
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
   local i=self:get_index(vec2:create(cell.x+ox,cell.y+oy))
   cells[i]=vec2:create(cell.x+ox,cell.y+oy)
  end
  self.cells=cells
  self.x=self.x+ox
  self.y=self.y+oy
  self.complete=true
  return self.cells
 end,
 spawn=function(self,params)
  local t=self:thread(params)
  t:add_cell(self,vec2:create(t.x,t.y))
  add(self.threads,t)
 end,
 get_index=function(self,cell)
  return cell.y*canvas.width+cell.x
 end,
 thread=function(self,params)
  params=params or {}
  local o=extend(self.params,params)
  o.lx=1
  o.ly=1
  o.update=function(self,parent)
   self.lx=cos(self.angle)
   self.ly=-sin(self.angle)
   local cells={vec2:create(0,0)}
   local added=0
   local done=false
   local t90=self.t90
   local da=0.25
   local m=0.5
   local n=0
   local t=0
   -- #1. if we're moving up or down then
   -- increase the chance (t90) to turn 90º
   -- as we need to stay wider than higher
   -- #2. if we're close to the edge of the canvas
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
     vec2:create(self.x+cell.x,self.y+cell.y)
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
    if cell.x<parent.min.x then
     parent.min.x = cell.x
    elseif cell.x>parent.max.x then
     parent.max.x = cell.x
    end
    if cell.y<parent.min.y then
     parent.min.y = cell.y
    elseif cell.y>parent.max.y then
     parent.max.y = cell.y
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
     add(r,vec2:create(x*dx,y*dy))
    end
   end
   return r
  end
  o.get_angle=function(self)
   local options={}
   if self.x>7 then add(options,0.5) end
   if self.x<canvas.width-8 then add(options,0) end
   if self.y>7 then add(options,0.75) end
   if self.y<canvas.height-8 then add(options,0.25) end
   return options[flr(rnd(4)+1)]
   --return flr(rnd(4))*0.25
  end
  return o
 end
}

object={
 create=function(self,x,y)
  local o={x=x,y=y,hitbox={x=0,y=0,w=8,h=8,x2=7,y2=7}}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 add_hitbox=function(self,w,h,x,y)
  x=x or 0
  y=y or 0
  self.hitbox={x=x,y=y,w=w,h=h,x2=x+w-1,y2=y+h-1}
 end
}

movable={
 create=function(self,x,y,ax,ay)
  local o=object.create(self,x,y)
  o.ax=ax
  o.ay=ay
  o.dx=0
  o.dy=0
  o.min={dx=0.05,dy=0.05}
  o.max={dx=1,dy=1}
  o.complete=false
  o.health=0
  return o
 end,
 distance=function(self,target)
  local dx=self.x-target.x
  local dy=self.y-target.y
  local d=sqrt(dx^2+dy^2)
  return d>0 and d or 32727
 end,
 collide_object=function(self,object)
  if self.complete or object.complete then return false end
  local x=self.x
  local y=self.y
  local hitbox=self.hitbox
  return (x+hitbox.x<=object.x+object.hitbox.x2) and
   (object.x+object.hitbox.x<x+hitbox.w) and
   (y+hitbox.y<=object.y+object.hitbox.y2) and
   (object.y+object.hitbox.y<y+hitbox.h)
 end,
 can_move=function(self,points,flag)
  for _,p in pairs(points) do
   local tx=flr(p[1]/8)
   local ty=flr(p[2]/8)
   tile=mget(tx,ty)
   if flag and fget(tile,flag) then
    return {ok=false,flag=flag,tile=tile,tx=tx*8,ty=ty*8}
   elseif fget(tile,0) then
    return {ok=false,flag=0,tile=tile,tx=tx*8,ty=ty*8}
   end
  end
  return {ok=true}
 end,
 can_move_x=function(self)
  local x=self.x+round(self.dx)
  if self.dx>0 then x=x+7 end
  return self:can_move({{x,self.y},{x,self.y+7}},1)
 end,
 can_move_y=function(self)
  local y=self.y+round(self.dy)
  if self.dy>0 then y=y+7 end
  return self:can_move({{self.x,y},{self.x+7,y}})
 end,
 damage=function(self,health)
  self.health=self.health-health
  if self.health>0 then
   self:hit()
  else
   self:destroy()
  end
 end,
 hit=function(self)
  -- do nothing
 end,
 destroy=function(self)
  -- do nothing
 end,
 update=function(self)
  -- do nothing
 end,
 draw=function(self)
  -- do nothing
 end
} setmetatable(movable,{__index=object})

animatable={
 create=function(self,x,y,ax,ay)
  local o=movable.create(self,x,y,ax,ay)
  o.anim={
   init=function(self,stage,dir)
    -- record frame count for each stage dir
    for s in pairs(self.stage) do
     for d=1,4 do
      self.stage[s].dir[d].fcount=#self.stage[s].dir[d].frames
     end
    end
    -- init current values
    self.current:set(stage,dir)
   end,
   stage={},
   current={
    reset=function(self)
     self.frame=1
     self.tick=0
     self.loop=true
     self.transitioning=false
    end,
    set=function(self,stage,dir)
     if self.stage==stage then return end
     self.reset(self)
     self.stage=stage
     self.dir=dir or self.dir
    end
   },
   add_stage=function(self,name,ticks,loop,left,right,up,down,next)
    self.stage[name]={
     ticks=ticks,
     loop=loop,
     dir={{frames=left},{frames=right},{frames=up},{frames=down}},
     next=next
    }
   end
  }
  return o
 end,
 animate=function(self)
  local c=self.anim.current
  local s=self.anim.stage[c.stage]
  local d=s.dir[c.dir]
  if c.loop then
   c.tick=c.tick+1
   if c.tick==s.ticks then
    c.tick=0
    c.frame=c.frame+1
    if c.frame>d.fcount then
     if s.next then
      c:set(s.next)
      d=self.anim.stage[c.stage].dir[c.dir]
     elseif s.loop then
      c.frame=1
     else
      c.frame=d.fcount
      c.loop=false
     end
    end
   end
  end
  return s.dir[c.dir].frames[c.frame]
 end,
 update=function(self)
  -- do nothing
 end,
 draw=function(self)
  local sprite=self.animate(self)
  spr(sprite,self.x,self.y)
 end
} setmetatable(animatable,{__index=movable})

player={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0.2,0.2)
  o.anim:add_stage("still",5,true,{5},{6},{7},{8})
  o.anim:add_stage("walking",5,true,{9,5,10},{11,6,12},{13,7,14},{15,8,16})
  o.anim:init("still",dir.down)
  o.sx=x
  o.sy=y
  o:reset()
  o.max.health=o.health
  o.max.bombs=5
  return o
 end,
 reset=function(self)
  self.complete=false
  self.score=0
  self.health=500
  self.bullet=1
  self.bombs=3
  self.x=self.sx
  self.y=self.sy
 end,
 destroy=function(self)
  cam:shake(5,0.9)
  self.complete=true
 end,
 hit=function(self)
  cam:shake(2,0.8)
 end,
 update=function(self)
  if self.complete then return end
  animatable.update(self)
  -- horizontal movement
  if btn(pad.left) then
   self.anim.current.dir=dir.left
   self.dx=self.dx-self.ax
  elseif btn(pad.right) then
   self.anim.current.dir=dir.right
   self.dx=self.dx+self.ax
  else
   self.dx=self.dx*drag
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  if abs(self.dx)<self.min.dx then self.dx=0 end
  local move=self:can_move_x()
  if move.ok then
   self.x=self.x+round(self.dx)
  else
   self.x=move.tx+(self.dx>0 and -8 or 8)
  end
  -- vertical movement
  if btn(pad.up) then
   self.anim.current.dir=dir.up
   self.dy=self.dy-self.ay
  elseif btn(pad.down) then
   self.anim.current.dir=dir.down
   self.dy=self.dy+self.ay
  else
   self.dy=self.dy*drag
  end
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  if abs(self.dy)<self.min.dy then self.dy=0 end
  local move=self:can_move_y()
  if move.ok then
   self.y=self.y+round(self.dy)
  else
   self.y=move.ty+(self.dy>0 and -8 or 8)
  end
  if self.dx==0 and self.dy==0 then
   self.anim.current:set("still")
  else
   self.anim.current:set("walking")
  end
 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
 end
} setmetatable(player,{__index=animatable})

collection={
 create=function(self)
  local o={
   items={},
   count=0,
  }
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:update()
  end
 end,
 draw=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:draw()
   if i.complete then self:del(i) end
  end
 end,
 add=function(self,object)
  add(self.items,object)
  self.count=self.count+1
 end,
 del=function(self,object)
  del(self.items,object)
  self.count=self.count-1
 end,
 reset=function(self)
  self.items={}
  self.count=0
 end
}

function _init()
 local maker=floormaker:create()
 cells=maker:run()
 create_map(cells,maker.width,maker.height)
 p=player:create(maker.x*8,maker.y*8)
 cam=create_camera(p,maker.width*8,maker.height*8)
end

function _update60()
 cam:update()
 p:update()
end

function _draw()
 cls()
 camera(cam:position())
 map(0,0)
 p:draw()
 camera(0,0)
 -- hud
end

function extend(...)
 local o,arg={},{...}
 for _,a in pairs(arg) do
  for k,v in pairs(a) do o[k]=v end
 end
 return o
end

function create_map(cells,w,h)
 local sprite={roof=1,wall=2,shadow=3,floor=4}
 memset(0x2000,0,0x1000)
 for x=0,w-1 do
  for y=0,h-1 do
   mset(x,y,sprite.roof)
  end
 end
 for index,cell in pairs(cells) do
  local n2=vec2:create(cell.x,cell.y-1)
  local n=floormaker:get_index(n2)
  if cells[n]==nil then
   mset(cell.x,cell.y,sprite.wall)
  else
   n2=vec2:create(cell.x,cell.y-2)
   n=floormaker:get_index(n2)
   if cells[n]==nil then
    mset(cell.x,cell.y,sprite.shadow)
   else
    mset(cell.x,cell.y,sprite.floor)
   end
  end
 end
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

function round(x) return flr(x+0.5) end

function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

__gfx__
77777777999999994444444466666666777777770111110000111110011111100111111001111100011111000011111000111110011111100111111001111110
777777779999999944444444666666667777777701ff11100111ff10011111100111111001ff111001ff11100111ff100111ff10011111100111111001111110
7777777799999999444444446666666677777777ff1fff1001fff1ff0111111001ffff10ff1fff10ff1fff1001fff1ff01fff1ff011111100111111001ffff10
77777777999999994444444467676767777777770ffff110011ffff0011111100f1ff1f00ffff1100ffff110011ffff0011ffff001111110011111100f1ff1f0
777777779999999966666666777777777777777702222220022222202222222222ffff2202222220022222200222222002222220222222200222222222ffff22
77777777999999996666666677777777777777770222222002222220f222222fff2222ff02222220022222200222222002222220222222200222222002222222
7777777799999999666666667777777777777777022ff220022ff22002222220022222200ff2222002222ff002222ff00ff22220f222222002222220022222ff
77777777999999996666666677777777777777776644416666144466644664466446644666114446644411666444116666114446644666666666644664466666
01111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01ffff10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f1ff1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22ffff22000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666446000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a999999a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a999999a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94444449000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94499449000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94444449000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
