sprite=component:create(
 function(self,sprite)
  self.sprite=sprite
 end
)

sprite.draw=function(self,entity)
 local position=entity:get(position)
 spr(self.sprite,position.x,position.y)
end