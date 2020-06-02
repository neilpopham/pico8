p=movable:create(0,64,0,0,5,3)
p.update=function(self)
 self.dy+=drag.gravity
 self.dy=mid(-self.max.dy,self.dy,self.max.dy)

 self.y=self.y+self.dy
end
