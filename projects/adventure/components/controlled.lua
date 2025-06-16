controlled=component:create()

controlled.update=function(self,entity)
 local position,movement=entity:get(position),entity:get(movement)
 if btn(0) then
  movement.dx=movement.dx-movement.ax
 elseif btn(1) then
  movement.dx=movement.dx+movement.ax
 else
  movement.dx=movement.dx*drag.ground
  if abs(movement.dx)<movement.ax then movement.dx=0 end
 end
 movement.dx=mid(-movement.mdx,movement.dx,movement.mdx)
 position.x=position.x+movement.dx
 if btn(2) then
  movement.dy=movement.dy-movement.ay
 elseif btn(3) then
  movement.dy=movement.dy+movement.ay
 else
  movement.dy=movement.dy*drag.ground
  if abs(movement.dy)<movement.ay then movement.dy=0 end
 end
 movement.dy=mid(-movement.mdy,movement.dy,movement.mdy)
 position.y=position.y+movement.dy
end