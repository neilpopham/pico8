weapon_types={
 {
  bullet_type=2,
  rate=10,
  sfx=0
 }
}

bullet_types={
 { -- standard
  force=3,
  size=2,
  update=function(self)
   entity.update(self,true)
  end,
  draw=function(self)
   circ(self.x,self.y,2,8)
  end
 },
 { -- homing
  force=3,
  size=2,
  init=function(self)
   local md,me=10000
   for _,e in pairs(enemies.items) do
    if e.visible then
     local d=self:distance(e)
     if d<md then self.target=e md=d end
    end
   end
  end,
  update=function(self)
   if self.target then
    local dx=self.target.x-self.x
    local dy=self.target.y-self.y
    local a=atan2(self.target.x-self.x,self.y-self.target.y)
    local dir=sgn(((a+0.5-self.angle)%1)-0.5)
    self.angle+=0.01*dir
    --local da=self:adiff(a)
    --self.df=self.df-da
    printh("force: "..self.force.. " df: "..self.df)
   end
   entity.update(self,true)
  end,
  draw=function(self)
   circ(self.x,self.y,2,15)
  end
 }
}

bullet={
 create=function(self,x,y,angle,type)
  local ttype=bullet_types[type]
  local o=entity.create(self,x,y,angle,0.02,0.0125)
  o=extend(
   o,
   {
    type=ttype,
    force=ttype.force,
    ttl=40
   }
  )
  if o.type.init then o.type.init(o) end
  return o
 end,
 update=function(self)
  if self.complete then return end
  self.type.update(self)
  if self.ttl==0 then
   self.complete=true
  else
   self.ttl=self.ttl-1
  end
 end,
 draw=function(self)
  self.type.draw(self)
 end
} setmetatable(bullet,{__index=entity})
