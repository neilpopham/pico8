p=animatable:create(8,112,0.15,-2,2,3)
local add_stage=function(...) p.anim:add_stage(...) end
add_stage("still",1,false,{16},{19})
add_stage("run",5,true,{16,17,16,18},{19,20,19,21})
add_stage("jump",1,false,{18},{21})
add_stage("fall",1,false,{17},{20})
add_stage("run_turn",3,false,{23},{23},"still")
add_stage("jump_turn",1,false,{16},{19},"jump")
add_stage("fall_turn",1,false,{16},{19},"fall")
add_stage("jump_fall",1,false,{16},{19},"fall")
p.anim:init("still",dir.right)
p.max.prejump=8 -- ticks allowed before hitting ground to jump
p.is={
 grounded=false,
 jumping=false,
 falling=false
}
p.b=0
p.f=0
p.bullet_type=1
p.health=500
p.camera=cam:create(p,1024,128)
p.btn1=button:create(pad.btn1)
p.cayote=counter:create(1,3)
p.cayote.on_max=function(self)
 printh("cayote timeout") -- #####################################################
 -- we can use p here, like p.is.grounded
end
p.set_state=function(self,state)
 for s in pairs(self.is) do
  self.is[s]=false
 end
 self.is[state]=true
end
p.can_jump=function(self)
 if self.is.jumping
  and self.btn1:valid() then
  printh("can jump: jumping") -- ###########################
  return true
 end
 if self.is.grounded
  and self.btn1.tick<self.max.prejump then
  printh("can jump: grounded: tick:"..(self.btn1.tick)) -- ###########################
  self.btn1.tick=self.btn1.min
  return true
 end
 if self.is.grounded
  and self.cayote:valid() then
  printh("can jump: cayote") -- ###########################
  return true
 end
 return false
end
p.hit=function(self,health)
 smoke:create(self.x+4,self.y+4,20,{col=12,size={12,20}})
 shells:create(self.x+4,self.y+4,5,{col=8,life={20,30}})
end
p.destroy=function(self,health)
 self.complete=true
 smoke:create(self.x+4,self.y+4,20,{col=12,size={12,30}})
 shells:create(self.x+4,self.y+4,20,{col=8,life={40,80}})
end
p.update=function(self)

  if self.complete then return end

  local face=self.anim.current.dir
  local stage=self.anim.current.stage
  local move

  -- checks for direction change
  local check=function(self,stage,face)
   if face~=self.anim.current.dir then
    if stage=="still" then stage="run" end
    if stage=="jump_fall" then stage="fall" end
    if not self.anim.current.transitioning then
     self.anim.current:set(stage.."_turn")
     self.anim.current.transitioning=true
    end
   end
  end

  -- horizontal
  if btn(pad.left) then
   self.anim.current.dir=dir.left
   check(self,stage,face)
   self.dx=self.dx-self.ax
  elseif btn(pad.right) then
   self.anim.current.dir=dir.right
   check(self,stage,face)
   self.dx=self.dx+self.ax
  else
   if self.is.jumping or self.is.falling then
    self.dx=self.dx*drag.air
   else
    self.dx=self.dx*drag.ground
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

  -- can move horizontally
  if move.ok then
   self.x=self.x+round(self.dx)

   if abs(self.dx)<0.1 then self.dx=0 end

   if abs(self.dx)>0 and self.is.grounded then
    particles:add(
     smoke:create(self.x+(face==dir.left and 3 or 4),self.y+7,1,{size={1,3}})
    )
   end

  -- cannot move horizontally
  else
   self.x=move.tx+(self.dx>0 and -8 or 8)
   self.dx=0
  end

  -- jump
  if self.btn1:pressed() and self:can_jump() then
   self.dy=self.dy+self.ay
   self.max.dy=3
  else
   if self.is.jumping then
    self.btn1.disabled=true
   else
    self.btn1.disabled=false
   end
  end
  self.dy=self.dy+drag.gravity
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)

  move=self:can_move_y()

  if move.ok then
   for _,d in pairs(destructables.items) do
    if d.visible and self:collide_object(d,self.x,self.y+round(self.dy)) then
     move.ok=false
     move.ty=d.y
     break
    end
   end
  end

  -- can move vertically
  if move.ok then

   -- moving down the screen
   if self.dy>0 then
    if self.is.grounded then
     self.cayote:increment()
     if self.cayote:valid() then
      self.dy=0
     else
      self.anim.current:set("fall")
      self:set_state("falling")
     end
    else
     if not self.anim.current.transitioning then
      self.anim.current:set(self.is.jumping and "jump_fall" or "fall")
     end
     self:set_state("falling")
    end
    self.f+=1

   -- moving up the screen
   else
    if not self.is.jumping then
     self.anim.current:set("jump")
     smoke:create(self.x+(face==dir.left and 3 or 4),self.y+7,20,{col=7,size={4,8}})
    end
    self:set_state("jumping")
   end

   self.y=self.y+round(self.dy)

  -- cannot move vertically
  else
   self.y=move.ty+(self.dy>0 and -8 or 8)
   if self.dy>0 then
    if not self.anim.current.transitioning then
     self.anim.current:set(round(self.dx)==0 and "still" or "run")
    end
    if self.is.falling then
     printh("f:"..self.f)
     smoke:create(
      self.x+(face==dir.left and 3 or 4),
      self.y+7,
      2*self.f,
      {col=self.f>10 and 10 or 7,size={self.f/3,self.f}}
     )
     -- if we've fallen far then do a little bounce
     if self.f>10 then
      self.dy=min(-3,-(round(self.f/6)))
      self.max.dy=6
      printh("dy:"..self.dy)
     end

    end
    self:set_state("grounded")
    self.cayote:reset()
   else -- we are jumping and have hit a roof
    self.btn1:reset()
    self.dy=0
    self.anim.current:set("jump_fall")
    self:set_state("falling")
   end
   self.f=0
  end

  -- fire
  if self.b>0 then
   self.b=self.b-1
  elseif btn(pad.btn2) then
   --sfx(0)
   bullets:add(
    bullet:create(
     self.x+(face==dir.left and 0 or 6),self.y+4,face,self.bullet_type
    )
   )
   shells:create(self.x+(face==dir.left and 2 or 4),self.y+3,1,{col=9})
   self.b=20
  else
   self.b=0
  end

end
