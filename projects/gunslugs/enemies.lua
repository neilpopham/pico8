enemy_types={
 {health=100,col=13,range=1,size={8,12}}
}

enemy={
 create=function(self,x,y,type)
  local ttype=enemy_types[type]
  local o=animatable.create(self,x,y,0.1,-2,1,2)
  o.anim:add_stage("still",1,false,{48},{51})
  o.anim:add_stage("run",5,true,{48,49,48,50},{51,52,51,53})
  o.anim:add_stage("jump",1,false,{50},{53})
  o.anim:add_stage("fall",1,false,{49},{52})
  o.anim:add_stage("run_turn",5,false,{48},{51},"still")
  o.anim:add_stage("jump_turn",1,false,{48},{51},"jump")
  o.anim:add_stage("fall_turn",1,false,{48},{51},"fall")
  o.anim:add_stage("jump_fall",1,false,{48},{51},"fall")
  o.anim:init("run",dir.left)  
  o.type=ttype
  o.health=ttype.health
  return o
 end,
 hit=function(self)
  --smoke:create((flr(self.x/8)*8)+4,(flr(self.y/8)*8)+4,5,{col=self.type.col,size={6,12}})
 end,
 destroy=function(self)
  self.complete=true
  printh("enemy destroy at "..self.x..","..self.y)
  smoke:create((flr(self.x/8)*8)+4,(flr(self.y/8)*8)+4,20,{col=self.type.col,size=self.type.size})
  smoke:create((flr(self.x/8)*8)+4,(flr(self.y/8)*8)+4,10,{col=7,size=self.type.size})
  shells:create((flr(self.x/8)*8)+4,(flr(self.y/8)*8)+4,10,{col=8,life={20,40}})
 end,
 update=function(self)
  if not self.visible then return end
  if p.x<self.x then
    self.anim.current.dir=dir.left
    self.dx=self.dx-self.ax
  else
    self.anim.current.dir=dir.right
    self.dx=self.dx+self.ax
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)

  move=self:can_move_x()

  if move.ok then
   for _,d in pairs(destructables.items) do
    if d.visible and self:collide_object(d,self.x+round(self.dx),self.y) then
     move.ok=false
     move.tx=d.x
     break
    end
   end
  end

  if move.ok then
   self.x=self.x+round(self.dx)
  else
   self.dx=0
  end

  self.dy=self.dy+drag.gravity
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)

  move=self:can_move_y()

  if move.ok then
   self.max.dy=2
   for _,d in pairs(destructables.items) do
    if d.visible and self:collide_object(d,self.x,self.y+round(self.dy)) then
     move.ok=false
     move.ty=d.y
     break
    end
   end
  end

  if move.ok then
   self.y=self.y+round(self.dy)
  else
   self.dy=0
  end  

  --if self.dx==0 and self.dy==0 then
   self.anim.current:set(round(self.dx)==0 and "still" or "run")
  --end

 end,
 draw=function(self)
  if not self.visible then return false end
  if self.complete then return true end
  animatable.draw(self)
  return false
 end
} setmetatable(enemy,{__index=animatable})