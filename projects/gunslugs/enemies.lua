enemy_shoot_dumb=function(self)
 local face=self.anim.current.dir
 bullets:add(
  bullet:create(
   self.x+(face==dir.left and 0 or 6),self.y+4,face,self.type.bullet_type
  )
 )
 shells:create(self.x+(face==dir.left and 2 or 4),self.y+3,1,{col=3})
 sfx(4)
end

enemy_has_shot_dumb=function(self,target)
 return true
end

enemy_has_shot_cautious=function(self,target)
 if p.complete then return false end
 if target.y~=self.y then return false end
 local tx,ty=flr(self.x/8),flr(self.y/8)
 local px=flr(target.x/8)
 local step=target.x>self.x and 1 or -1
 for x=tx,px,step do
  if zget(x,ty) then return false end
 end
 return true
end

enemy_add_stages=function(o,stage,count,loop,left,right,next)
 o.anim:add_stage(stage,count,loop,left,right,next)
end

enemy_stages_goon=function(o)
 enemy_add_stages(o,"still",1,false,{48},{51})
 enemy_add_stages(o,"run",5,true,{48,49,48,50},{51,52,51,53})
 enemy_add_stages(o,"jump",1,false,{50},{53})
 enemy_add_stages(o,"fall",1,false,{49},{52})
 enemy_add_stages(o,"run_turn",5,false,{48,55,51},{51,55,48},"still")
 enemy_add_stages(o,"jump_turn",1,false,{48},{51},"jump")
 enemy_add_stages(o,"fall_turn",1,false,{48},{51},"fall")
 enemy_add_stages(o,"jump_fall",1,false,{48},{51},"fall")
end

enemy_stages_spider=function(o)
 enemy_add_stages(o,"still",1,false,{48},{51})
 enemy_add_stages(o,"run",5,true,{48,49,48,50},{51,52,51,53})
end

enemy_types={
 { -- goon 1
  health=100,
  col=6,
  size={8,12},
  b=60,
  itchy=0.75,
  bullet_type=2,
  has_shot=enemy_has_shot_dumb,
  shoot=enemy_shoot_dumb,
  add_stages=enemy_stages_goon
 },
 { -- goon 2
  health=100,
  col=10,
  size={8,12},
  b=60,
  itchy=0.5,
  bullet_type=2,
  has_shot=enemy_has_shot_cautious,
  shoot=enemy_shoot_dumb,
  add_stages=enemy_stages_goon
 },
 { -- spider
  health=50,
  col=1,
  size={8,12},
  b=60,
  itchy=0,
  add_stages=enemy_stages_spider
 },
}

enemy={
 create=function(self,x,y,type)
  local ttype=enemy_types[type]
  local o=animatable.create(self,x,y,0.1,-2,1,2)
  ttype.add_stages(o)
  --[[
  local add_stage=function(...) o.anim:add_stage(...) end
  add_stage("still",1,false,{48},{51})
  add_stage("run",5,true,{48,49,48,50},{51,52,51,53})
  add_stage("jump",1,false,{50},{53})
  add_stage("fall",1,false,{49},{52})
  add_stage("run_turn",5,false,{48,55,51},{51,55,48},"still")
  add_stage("jump_turn",1,false,{48},{51},"jump")
  add_stage("fall_turn",1,false,{48},{51},"fall")
  add_stage("jump_fall",1,false,{48},{51},"fall")
  ]]
  o.anim:init("run",dir.left)
  o.type=ttype
  o.health=ttype.health
  o.b=0
  return o
 end,
 hit=function(self)
  smoke:create(self.x+4,self.y+4,10,{col=7,size=self.type.size})
  shells:create(self.x+4,self.y+4,5,{col=8,life={20,40}})
 end,
 destroy=function(self)
  self.complete=true
  self.visible=false
  printh("enemy destroyed at "..self.x..","..self.y)
  doublesmoke(
   (flr(self.x/8)*8)+3,
   (flr(self.y/8)*8)+3,
   {20,10,10},
   {
    {col=self.type.col,size=self.type.size},
    {col=7,size=self.type.size},
    {col=8,life={20,40}}
   }
  )
 end,
 update=function(self)
  if not self.visible then return end

  if not p.complete then
   if p.x<self.x then
     self.anim.current.dir=dir.left
     self.dx=self.dx-self.ax
   else
     self.anim.current.dir=dir.right
     self.dx=self.dx+self.ax
   end
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

  self.anim.current:set(round(self.dx)==0 and "still" or "run")

  -- shoot
  --[[
  if self.b>0 then
   self.b=self.b-1
  elseif self.type.has_shot(self,p) then
   local r=rnd()
   if r<self.type.itchy then
    self.type.shoot(self)
   end
   self.b=self.type.b
  else
   self.b=0
  end
  ]]

  -- shoot
  if self.b>0 then
   self.b=self.b-1
  else
   local r=rnd()
   if r<self.type.itchy and self.type.has_shot(self,p) then
    self.type.shoot(self)
   end
   self.b=self.type.b
  end

 end,
 draw=function(self)
  if not self.visible then return end
  -- set helmet colour according to enemy type
  pal(15,self.type.col)
  animatable.draw(self)
 end
} setmetatable(enemy,{__index=animatable})
