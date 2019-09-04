pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by neil popham

pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
dir={left=1,right=2,neutral=3}

function round(x)
 return flr(x+0.5)
end

p={
 x=64,
 y=120,
 a=0.75,
 f=1,
 d=dir.neutral,
 dy=0,
 dx=0
}

g=0.5
btn1=0

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

 if p.a>0.75 then
  p.d=dir.right
 elseif p.a<0.75 then
  p.d=dir.left
 else
  p.d=dir.neutral
  p.dx=0
 end

 if p.d==dir.neutral then
  p.dx=p.dx*0.95
 else
  p.dx=p.dx+cos(p.a)*0.075
 end

 p.x=p.x+p.dx

 if p.x<0 then p.x=0 end
 if p.x>120 then p.x=120 end

 if btn(pad.btn1) and btn1<20 then
  local a=0.75-(0.75-p.a)/2
  --if p.d==dir.right then
  --elseif p.d==dir.left then
  --else
  --end
  p.dy=-sin(a)*3
  btn1=btn1+1
 end
 p.dy=p.dy+0.33

 p.y=p.y+p.dy

 if p.y>120 then p.y=120 btn1=0 end

end

function _draw()
 cls(1)
 local x=cos(p.a)*30
 local y=-sin(p.a)*30
 line(64,48,64+x,48+y,3)
 print(p.a,2,2,3)

 rectfill(p.x,p.y,p.x+7,p.y+7,6)


 if btn(pad.left) then
  print("\139",61,50,9)
 elseif btn(pad.right) then
  print("\145",61,50,9)
 else
  if p.a<0.75 then p.a=p.a+0.01 elseif p.a>0.75 then p.a=p.a-0.01 end
 end

end

menuitem(1,"palette",function() p8ap=bxor(p8ap,128) for i=0,15 do pal(i,i+p8ap,1) end end)
--local p8ap=false
--menuitem(1,"palette",function() p8ap = not p8ap for i=0,15 do pal(i,i+(p8ap and 128 or 0),1) end end)
