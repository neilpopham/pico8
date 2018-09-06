pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 
-- by neil popham

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5} -- pico-8
--local pad={left=2,right=3,up=0,down=1,btn1=4,btn2=5,btn3=6,btn4=7} -- tic-80

local screen={width=128,height=128} -- pico-8
--local screen={width=240,height=136} -- tic-80

function create_camera(item,width,height)
 local c={
  map={w=width,h=height},
  target=item,
  x=item.x,
  y=item.y,
  buffer={x=16,y=16},
  min={x=8*flr(screen.width/16),y=8*flr(screen.height/16)}  
 } 
 c.max={x=width-c.min.x,y=height-c.min.y,shift=2}
 c.update=function(self)
  self.x=mid(self.min.x,self.target.x,self.max.x)
  self.y=mid(self.min.y,self.target.y,self.max.y)
 end
 c.map=function(self)
  camera(self.x-self.min.x,self.y-self.min.y)
  map(0,0)
 end
 return c
end

function create_counter(min,max)
 local t={
  tick=0,
  min=min,
  max=max,
 }
 t.increment=function(self)
  self.tick=self.tick+1
  if self.tick>self.max then
   self:reset()
   if type(self.on_max)=="function" then
    self:on_max()
   end
  end 
 end
 t.reset=function(self)
  self.tick=0
 end
 t.valid=function(self)
  return self.tick>=self.min
   and self.tick<=self.max
 end
 return t
end

function create_button(index)
 local b=create_counter(2,20)
 b.index=index
 b.released=true
 b.check=function(self)
  if btn(self.index) then
   if self.tick==0 and not self.released then return end
   self:increment()   
   self.released=false
  else
   if self.tick<11 then
    if type(self.on_short)=="function" then
     self:on_long()
    end
   else 
    if type(self.on_long)=="function" then
     self:on_long()
    end
   end 
   self:reset()  
   self.released=true
  end
 end
 b.pressed=function(self)
  return self:valid()
 end
 b.on_max=function(self)
  if type(self.on_long)=="function" then self:on_long() end
 end
 return b
end

function create_item(x,y)
 local i={x=x,y=y,hitbox={x=0,y=0,w=8,h=8,x2=7,y2=7}}
 i.add_hitbox=function(self,w,h,x,y)
  x=x or 0
  y=y or 0
  self.hitbox={x=x,y=y,w=w,h=h,x2=x+w-1,y2=y+h-1}
 end
 return i
end

function create_movable_item(x,y,ax,ay)
 i = create_item(x,y)
 i.dx=0
 i.dy=0
 i.min={dx=0.05,dy=0.05}
 i.max={dx=1,dy=2}
 i.ax=ax
 i.ay=ay 
 i.draw=function(self)

 end
 i.collide_map=function(self)
  local x=self.x+self.dx
  local y=self.y+self.dy
  local hitbox=self.hitbox
  local x1=(x+hitbox.x)/8
  local y1=(y+hitbox.y)/8
  local x2=(x+hitbox.x2)/8
  local y2=(y+hitbox.y2)/8
  return fget(mget(x1,y1),0)
   or fget(mget(x1,y2),0)
   or fget(mget(x2,y2),0)
   or fget(mget(x2,y1),0)
 end
 i.collide_object=function(self,object)
  local x=self.x+self.dx
  local y=self.y+self.dy
  local hitbox=self.hitbox
  return object.x<x+hitbox.w
     and object.x+object.htbox.w>x
     and object.y<y+hitbox.h
     and object.y+object.hitbox.h>y
 end
 i.can_move=function(self,p1,p2,flag)
  for _,p in pairs({p1,p2}) do
   local tx=flr(p[1]/8)
   local ty=flr(p[2]/8)
   tile=mget(tx,ty)
   if fget(tile,0) then
    return 0
   elseif flag and fget(tile,flag) then 
    return flag
   end
   return 8
  end
 end
 i.can_move_x=function(self)
  local x=self.x+round(self.dx)
  if self.dx>0 then x=x+7 end
  return self:can_move({x,self.y},{x,self.y+7},1)
 end
 i.can_move_y=function(self)
  local y=self.y+round(self.dy)
  if self.dy>0 then y=y+7 end
  return self:can_move({self.x,y},{self.x+7,y})
 end
 
 return i
end

function create_controllable_item(x,y,ax,ay)
 local i=create_movable_item(x,y,ax,ay)
 i.btn1=create_button(pad.btn1)
 i.update=function(self)
  -- horizontal
  if btn(pad.left) then
   self.dx=self.dx-self.ax
  elseif btn(pad.right) then
   self.dx=self.dx+self.ax
  else
   self.dx=self.dx*drag.ground
  end

  -- vertical
  if btn(pad.up) then
   self.dy=self.dy-self.ay
  elseif btn(pad.down) then
   self.dy=self.dy+self.ay
  else
   self.dy=self.dy+drag.gravity
   --self.dy=self.dy*drag.ground
  end

  -- button
  self.btn1:check()
  if self.btn1:pressed() then
   -- do something
  end

 end
end

function _init()
    
end

function _update()

end

function _draw()

end
