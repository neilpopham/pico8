pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by neil popham

pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

function round(x)
 return flr(x+0.5)
end

p={
 x=64,
 y=120,
 a=0.75,
 f=1
}

g=0.5

function _init()

end

function _update60()

 if btn(pad.left) then
  p.a=p.a-0.01
  if p.a<0.5 then p.a=0.5 end
 elseif btn(pad.right) then
  p.a=p.a+0.01
  if p.a>1 then p.a=1 end
 else
  if p.a<0.75 then p.a=p.a+0.01 elseif p.a>0.75 then p.a=p.a-0.01 end
 end
 p.a=round(p.a*100)/100

end

function _draw()
 cls()
 local x=cos(p.a)*30
 local y=-sin(p.a)*30
 line(p.x,p.y,p.x+x,p.y+y,3)
 print(p.a,0,0,1)
end
