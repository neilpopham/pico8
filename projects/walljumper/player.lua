p=movable:create(32,32,0.25,-2,2,3)
p.sliding=false
p.walled=0
p.timer=0
p.jump=true
p.jumping=false
p.counters={}

p.btn1=button:create(pad.btn1)

-- update
p.update=function(self)

 if btn(pad.left) then
  self.dx-=self.ax
 elseif btn(pad.right) then
  self.dx+=self.ax
 else
  self.dx*=drag.air
 end
 self.dx=mid(-self.max.dx,self.dx,self.max.dx)
 if abs(self.dx)<0.05 then self.dx=0 end

 local mx=self:can_move_x()
 if mx.ok then
  self.x+=round(self.dx)
  if self.timer>0 then self.timer-=1 end
  if self.walled>0 then self.walled-=1 end
  if self.sliding then
   self.timer=12
  end
  self.sliding=false
 else
  self.dx=0
  self.sliding=true
  self.jump=true
  self.walled=3
  self.dy=0
 end


 if self.btn1:pressed() and self.jump then
  self.dy+=self.ay
 else
  if self.jumping then
   self.btn1.disabled=true
  else
   self.btn1.disabled=false
  end
 end

 if self.walled>0 then
  self.dy+=drag.wall
  printh("wall")
 else
  self.dy+=drag.gravity
  printh("gravity")
 end

 self.dy=mid(-self.max.dy,self.dy,self.max.dy)
 local my=self:can_move_y()

 if my.ok then
  self.y+=round(self.dy)
 else
  self.dy=0
 end

 if self.y>100 then self.y=100 self.dy=0 end

end

-- draw
p.draw=function(self)
 object.draw(self,2)
 print(tostr(p.jump),0,0,9)
 print(tostr(p.timer),30,0,9)
 print(tostr(p.walled),50,0,9)
end
