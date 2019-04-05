pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- camera lerp
-- by neil popham

function round(x) return flr(x+0.5) end

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
local screen={width=128,height=128}

--local p={x=flr(rnd(1024)),y=flr(rnd(256))}
local p={x=0,y=0}

function create_camera(item,width,height)
 local c={
  map={w=width,h=height},
  target=item,
  x=item.x,
  y=item.y,
  a=0.125,
  min={x=8*flr(screen.width/16),y=8*flr(screen.height/16)}
 }
 c.max={x=width-c.min.x,y=height-c.min.y,shift=128}
 c.update=function(self)
  local ax=ceil((self.target.x-self.x)*self.a)
  local ay=ceil((self.target.y-self.y)*self.a)
  ax=mid(-self.max.shift,ax,self.max.shift)
  ay=mid(-self.max.shift,ay,self.max.shift)
  self.x=self.x+ax
  self.y=self.y+ay
  self.x=mid(self.min.x,self.x,self.max.x)
  self.y=mid(self.min.y,self.y,self.max.y)
  --[[
  if self.x<self.min.x then
   self.x=self.min.x
  elseif self.x>self.max.x then
   self.x=self.max.x
  end
  if self.y<self.min.y then
   self.y=self.min.y
  elseif self.y>self.max.y then
   self.y=self.max.y
  end
  --]]
 end
 c.position=function(self)
  return self.x-self.min.x,self.y-self.min.y
 end
 c.map=function(self)
  camera(self:position())
  map(0,0)
 end
 return c
end

p.camera=create_camera(p,1024,256)

function _init()
 for y=0,31 do
  for x=0,127 do
   mset(x,y,1)
   if x%8==0 then
    if y%8==0 then
     mset(x,y,3)
    elseif y%2==0 then
     mset(x,y,2)
    end
   end
  end
 end
end

function _update60()

 if btnp(pad.btn1) then
  p.x=flr(rnd(1024))
  p.y=flr(rnd(256))
  --p.x=flr(rnd(128))
  --p.y=flr(rnd(128))
 end

 p.camera:update()

end

function _draw()
 cls()
 p.camera:map()
 spr(4,p.x,p.y)
 camera(0,0)
 print(p.x..","..p.y)
 print(p.camera.min.x..","..p.camera.min.y)
 print(p.camera.max.x..","..p.camera.max.y)
 print(p.camera.x..","..p.camera.y)
end

__gfx__
00000000111111111111111111111111eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000001000000010000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700100000001000200010003000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000100000001000200010003000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000100000001022222010333330eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700100000001000200010003000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000001000200010003000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000001000000010000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
