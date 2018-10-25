pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham


charpicker={
 glyphs="abcdefghijklmnopqrstuvwxyz0123456789 _*#",
 create=function(self,x,y)
  local o={x=x,y=y,cx=0,sx=x,rx=x,dx=0,c=1,no=3,max=#charpicker.glyphs*-4+4,chars={},complete=false}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 save=function(self)
  local pos=self.rx/-4+1
  printh("pos:"..pos)
  printh(sub(self.glyphs,pos,pos))
  add(self.chars,sub(self.glyphs,pos,pos))
  if self.c==self.no then self.complete=true end
  self.c=self.c+1
  self.x=self.x+4
  self:reset()
  for i,chr in pairs(self.chars) do printh(chr) end
 end,
 reset=function(self)
  self.cx=0
  rx=self.x
  self.dx=0
 end
}

function _init()
 picker=charpicker:create(58,64)
 printh(picker.max)
end

function _update60()
 if btnp(0) then
  picker.dx=0.5
  if picker.cx==0 then picker.rx=picker.max else picker.rx=picker.cx+4 end
 end
 if btnp(1) then
  picker.dx=-0.5
  if picker.cx==picker.max then picker.rx=0 else picker.rx=picker.cx-4 end
 end
 picker.cx= picker.cx+picker.dx
 if picker.cx==picker.rx then picker.dx=0 end
 if picker.dx<0 and picker.cx==-157 then picker.cx=3 end
 if picker.dx>0 and picker.cx==1 then picker.cx=-159 end
 if btnp(4) then
  picker:save()
 end
end

function _draw()
 cls(1)
 circfill(64,64,60,2)
  -- loop code
 for i,chr in pairs(picker.chars) do
  print(chr,picker.sx+((i-1)*4),picker.y,7)
 end
 if not picker.complete then
  clip(picker.x,picker.y,4,6)
  print(picker.glyphs,picker.x+picker.cx,picker.y,7)
  clip()
 end
 circfill(24,24,12,3)
end
--[[
function _init()
 chars="abcdefghijklmnopqrstuvwxyz0123456789 _*#"
 x=0
 rx=x
 dx=0


end

function _update60()
 if btnp(0) then
  dx=0.5
  if x==0 then rx=-156 else rx=x+4 end
  --printh("rx:"..rx)
 end
 if btnp(1) then
  dx=-0.5
  if x==-156 then rx=0 else rx=x-4 end
  --printh("rx:"..rx)
 end
 if btnp(4) then
  local pos=rx/-4+1
  printh("pos:"..pos)
  printh(sub(chars,pos,pos))
 end
 x=x+dx
 --printh("x:"..x)
 if x==rx then dx=0 end
 if dx<0 and x==-157 then x=3 end
 if dx>0 and x==1 then x=-159 end
end

function _draw()
 cls(1)
 clip(0,0,4,6)
 print(chars,x,0)
 clip()
 print(x,0,10)
end
]]