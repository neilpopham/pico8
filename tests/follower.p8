pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

screen={width=128,height=128}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
drag=0.75

function _init()
 p={
  x=64,
  y=64,
  max={dx=2,dy=2},
  dx=0,
  dy=0,
  ax=0.2,
  ay=0.2,
  angle=0
 }
 f={
  x=64,
  y=64,
  max={dx=2,dy=2},
  dx=0,
  dy=0,
  ax=0.25,
  ay=0.25,
 }
end

--[[
function _update60()
 if btn(pad.left) then
  p.dx=p.dx-p.ax
 elseif btn(pad.right) then
  p.dx=p.dx+p.ax
 else
  p.dx=p.dx*drag
 end

 p.dx=mid(-p.max.dx,p.dx,p.max.dx)
 p.x=p.x+round(p.dx)

 if btn(pad.up) then
  p.dy=p.dy-p.ay
 elseif btn(pad.down) then
  p.dy=p.dy+p.ay
 else
  p.dy=p.dy*drag
 end

 p.dy=mid(-p.max.dy,p.dy,p.max.dy)
 p.y=p.y+round(p.dy)

 local dx=p.x-f.x
 local dy=p.y-f.y
 local angle=atan2(dx,-dy)

 f.dx=f.dx+(cos(angle)*f.ax)
 f.dy=f.dy-(sin(angle)*f.ay)

 f.dx=mid(-f.max.dx,f.dx,f.max.dx)
 f.x=f.x+round(f.dx)

 f.dy=mid(-f.max.dy,f.dy,f.max.dy)
 f.y=f.y+round(f.dy)
end
--]]

---[[
function _update60()
 if btn(pad.left) then
  p.dx=p.dx-p.ax
 elseif btn(pad.right) then
  p.dx=p.dx+p.ax
 else
  p.dx=p.dx*drag
 end

 p.dx=mid(-p.max.dx,p.dx,p.max.dx)
 p.x=p.x+round(p.dx)

 if btn(pad.up) then
  p.dy=p.dy-p.ay
 elseif btn(pad.down) then
  p.dy=p.dy+p.ay
 else
  p.dy=p.dy*drag
 end

 p.dy=mid(-p.max.dy,p.dy,p.max.dy)
 p.y=p.y+round(p.dy)

 local dx=abs(p.x-f.x)
 local dy=abs(p.y-f.y)
 local d=sqrt(dx^2+dy^2)
 local n=20

 if p.x>f.x then
  f.dx=f.dx+f.ax
 else
  f.dx=f.dx-f.ax
 end

 f.dx=mid(-f.max.dx,f.dx,f.max.dx)
 f.x=f.x+round(f.dx)

 if p.y>f.y then
  f.dy=f.dy+f.ay
 else
  f.dy=f.dy-f.ay
 end

 f.dy=mid(-f.max.dy,f.dy,f.max.dy)
 f.y=f.y+round(f.dy)

end
--]]

function _draw()
 cls()
 pset(p.x,p.y,7)
 pset(f.x,f.y,3)
end

function round(x) return flr(x+0.5) end