pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

charpicker={
 glyphs="abcdefghijklmnopqrstuvwxyz0123456789 _*#+",
 create=function(self,x,y,no)
  local o={x=x,y=y,cx=0,sx=x,rx=0,dx=0,c=1,no=no,max=#charpicker.glyphs*-4+4,chars={},complete=false}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 save=function(self)
  if self.complete then return end
  local pos=self.rx/-4+1
  add(self.chars,sub(self.glyphs,pos,pos))
  if self.c==self.no then
   self.complete=true
  else
   self.c=self.c+1
   self.x=self.x+4
   self:reset()
  end
  printh(self:get())
 end,
 reset=function(self)
  self.cx=0
  self.rx=0
  self.dx=0
 end,
 get=function(self)
  local s=""
  for _,c in pairs(self.chars) do s=s..c end
  return s
 end,
 next=function(self)
  self.dx=-0.5
  if self.cx==self.max then self.rx=0 else self.rx=self.cx-4 end
 end,
 previous=function(self)
  self.dx=0.5
  if self.cx==0 then self.rx=self.max else self.rx=self.cx+4 end
 end,
 update=function(self)
  self.cx= self.cx+self.dx
  if self.cx==self.rx then self.dx=0 end
  if self.dx<0 and self.cx==self.max-1 then self.cx=3 end
  if self.dx>0 and self.cx==1 then self.cx=self.max-3 end
 end,
 draw=function(self)
  -- loop code
  for i,chr in pairs(picker.chars) do
   print(chr,picker.sx+((i-1)*4),picker.y,7)
  end
  if not picker.complete then
   clip(picker.x,picker.y,4,6)
   print(picker.glyphs,picker.x+picker.cx,picker.y,7)
   clip()
  end
 end
}

function _init()
 picker=charpicker:create(58,64,3)
end

function _update60()
 if btnp(0) then
  picker:previous()
 end
 if btnp(1) then
  picker:next()
 end
 if btnp(4) then
  picker:save()
 end
 picker:update()
end

function _draw()
 cls(1)
 circfill(64,64,60,2)
 picker:draw()
 circfill(24,24,12,3)
end
