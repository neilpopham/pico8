pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- button counter
-- by neil popham

pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

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
 cls()
 print("test using \142")
 print("enable/disable \142 with \151")
 b1=button:create(pad.btn1)
 b1.on_short=function(self,tick)
  print("on_short: "..tick.." ticks")
 end
 b1.on_long=function(self,tick)
  print("on_long: "..tick.." ticks")
 end
 b1.on_max=function(self)
  print("on_max: max reached")
 end
 b1.on_release=function(self,tick)
  print("on_release: "..tick.." ticks")
 end
 b2=button:create(pad.btn2)
 b2.on_release=function(self)
  b1.disabled = not b1.disabled
  print("\142 "..(b1.disabled and "disabled" or "enabled"))
 end
end

function _update60()
 if b1:pressed() then
  print("pressed: "..b1.tick)
 elseif b1.released then
  b2:pressed()
 end
end

--[[
function create_counter(min,max)
 local t={tick=0,min=min,max=max}
 t.increment=function(self)
  self.tick=self.tick+1
  if self.tick>self.max then
   self:reset()
   if type(self.on_max)=="function" then
    self:on_max()
   end
  end
 end
 t.reset=function(self,value)
  value=value or 0
  self.tick=value
 end
 t.valid=function(self)
  return self.tick>=self.min and self.tick<=self.max
 end
 return t
end

function create_button(index)
 local b=create_counter(1,20)
 b.index=index
 b.released=true
 b.disabled=false
 b.check=function(self)
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
 end
 b.pressed=function(self)
  self:check()
  return self:valid()
 end
 return b
end

function _init()
 cls()
 print("test using \142")
 print("enable/disable \142 with \151")
 b1=create_button(pad.btn1)
 b1.on_short=function(self,tick)
  print("on_short: "..tick.." ticks")
 end
 b1.on_long=function(self,tick)
  print("on_long: "..tick.." ticks")
 end
 b1.on_max=function(self)
  print("on_max: max reached")
 end
 b1.on_release=function(self,tick)
  print("on_release: "..tick.." ticks")
 end
 b2=create_button(pad.btn2)
 b2.on_release=function(self)
  b1.disabled = not b1.disabled
  print("\142 "..(b1.disabled and "disabled" or "enabled"))
 end
end

function _update60()
 if b1:pressed() then
  print("pressed: "..b1.tick)
 elseif b1.released then
  b2:pressed()
 end
end
]]
