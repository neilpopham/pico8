pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- fighter
-- by Neil Popham

pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
screen={width=128,height=128,x2=127,y2=127}
dir={left=1,right=2}
drag={air=0.95,ground=0.65,gravity=0.7}

counter={
 create=function(self,min,max)
  local o={tick=0,min=min,max=max}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 increment=function(self)
  self.tick=self.tick+1
  if self.tick>self.max then
   self:reset()
   if type(self.on_max)=="function" then
    self:on_max()
   end
  end
 end,
 reset=function(self,value)
  value=value or 0
  self.tick=value
 end,
 valid=function(self)
  return self.tick>=self.min and self.tick<=self.max
 end
}

button={
 create=function(self,index)
  local o=counter.create(self,1,20)
  o.index=index
  o.released=true
  o.disabled=false
  return o
 end,
 check=function(self)
  if btn(self.index) then
   if self.disabled then return end
   if self.tick==0 and not self.released then return end
   self:increment()
   self.released=false
  else
   if not self.released then
    local tick=self.tick==0 and self.max or self.tick
    if type(self.on_release)=="function" then
     self:on_release(tick)
    end
    if tick>12 then
     if type(self.on_long)=="function" then
      self:on_long(tick)
     end
    else
     if type(self.on_short)=="function" then
      self:on_short(self.tick)
     end
    end
   end
   self:reset()
   self.released=true
  end
 end,
 pressed=function(self)
  self:check()
  return self:valid()
 end
} setmetatable(button,{__index=counter})

function _init()
 p={x=64,y=120,dy=0,dx=0}
 p.btn1=button:create(pad.btn1)
 p.btn1.on_release=function(self,tick)
  --tick=tick or self.max
  printh(tick)
  p.dy=-tick/1.5
 end
 --p.btn1.on_max=p.btn1.on_release
end

function _update60()
 if p.btn1:pressed() then

 end
 p.dy+=drag.gravity
 p.y=p.y+p.dy
 if p.y>120 then p.y=120 end
end

function _draw()
 cls()
 rectfill(p.x,p.y,p.x+7,p.y+7,7)
end
