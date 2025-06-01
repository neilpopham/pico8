pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

function _init()
 p={
  x=20,
  y=168,
  max={dx=3,dy=3},
  dx=0,
  dy=0,
  ax=0.2,
  ay=0.2,
  angle=1
 }
 p2={
  x=20,
  y=-32,
  max={dx=3,dy=3},
  dx=0,
  dy=0,
  ax=0.2,
  ay=0.2,
  angle=0
 }
 p3={
  x=110,
  y=-32,
  max={dx=3,dy=3},
  dx=0,
  dy=0,
  ax=0.2,
  ay=0.2,
  angle=0.5
 }
 t=0
 cls()
end

function _update60()

 p.angle=(p.angle-0.01)%1

 --p.angle=t%180/180

 p.dx=p.dx+(cos(p.angle)*p.ax)
 p.dx=mid(-p.max.dx,p.dx,p.max.dx)
 p.x=p.x+round(p.dx)

 p.dy=p.dy-(sin(p.angle)*p.ay)
 p.dy=mid(-p.max.dy,p.dy,p.max.dy)
 p.y=p.y+round(p.dy)


 p2.angle=(p2.angle+0.01)%1

 p2.dx=p2.dx+(cos(p2.angle)*p2.ax)
 p2.dx=mid(-p2.max.dx,p2.dx,p2.max.dx)
 p2.x=p2.x+round(p2.dx)

 p2.dy=p2.dy-(sin(p2.angle)*p2.ay)
 p2.dy=mid(-p2.max.dy,p2.dy,p2.max.dy)
 p2.y=p2.y+round(p2.dy)


 p3.angle=(p3.angle-0.01)%1

 p3.dx=p3.dx+(cos(p3.angle)*p3.ax)
 p3.dx=mid(-p3.max.dx,p3.dx,p3.max.dx)
 p3.x=p3.x+round(p3.dx)

 p3.dy=p3.dy-(sin(p3.angle)*p3.ay)
 p3.dy=mid(-p3.max.dy,p3.dy,p3.max.dy)
 p3.y=p3.y+round(p3.dy)

 t=t+1

end

function _draw()
 cls(1)
 --pset(p.x,p.y,t%16)

 --pset(p2.x,p2.y,t%16)

 pset(p3.x,p3.y,t%16)

 --[[

 print(p.dx,0,0)
 print(p.dy,0,10)

 print(p.x,40,0)
 print(p.y,40,10)

 print(cos(p.angle),0,80)
 print(-sin(p.angle),40,80)

 ]]
end

function round(x) return flr(x+0.5) end
