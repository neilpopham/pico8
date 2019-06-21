pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- ecs
-- by neil popham

#include ecs.lua

w=world:create()

position=component:create(
 function(self,x,y)
  self.x=x self.y=y
 end
)
movement=component:create(
 function(self,dx,dy,ax,ay)
  self.dx=dx
  self.dy=dy
  self.ax=ax
  self.ay=ay
 end
)



e=entity:create()
--e:add(c1,10,10)
--e:add(c2,20,20,1,2)
e
 :add(position,10,10)
 :add(movement,20,20,1,2)
 --:add(c1,100,100)
w:add_entity(e)

function _init()

end

function _update60()

end

function _draw()
 cls()
 local c1a=e:get(position)
 local c2a=e:get(movement)
 print(c1a.x)
 print(c1a.y)
 print(c2a.dx)
 print(c2a.dy)
 print(c2a.ax)
 print(c2a.ay)
 print(w.entities.count)
end
