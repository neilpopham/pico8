pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 
-- by neil popham


local cam={map={width=320,height=240}}

function create_item(x,y)
 local i={x=x,y=y,hitbox={x=0,y=0,w=8,h=8}}
 i.add_hitbox=function(self,w,h,x,y)
  x=x or 0
  y=y or 0
  self.hitbox={x=x,y=y,w=w,h=h,x2=x+w-1,y2=y+h-1}
 end
 return i
end

function create_movable_item(x,y)
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
end

function _init()
    
end

function _update()

end

function _draw()

end
