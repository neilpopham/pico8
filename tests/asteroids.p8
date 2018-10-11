pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- asteroids
-- by neil popham

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

stars={}
p={}
drag=0.95


function _init()

 for x=1,20 do
  o={x=rnd(127),y=rnd(127),col=7,depth=1,col2=13} --10}
  add(stars,o)
 end
 for x=1,20 do
  o={x=rnd(127),y=rnd(127),col=13,depth=0.7,col2=1} --9}
  add(stars,o)
 end
 for x=1,20 do
  o={x=rnd(127),y=rnd(127),col=5,depth=0.5}
  add(stars,o)
 end
 for x=1,20 do
  o={x=rnd(127),y=rnd(127),col=1,depth=0.3}
  add(stars,o)
 end

 p={x=64,y=64,angle=0,force=0,dx=0,dy=0,da=0,aa=0.01,df=0,af=0.01}

end

function _update60()

 if btn(pad.left) then
  p.angle=p.angle-p.aa
 elseif btn(pad.right) then
  p.angle=p.angle+p.aa
 end
 p.angle=p.angle%1

 if btn(pad.btn1) or btn(pad.up) then
   p.df=p.df+p.af
 elseif btn(pad.btn2) or btn(pad.down) then
   p.df=p.df-p.af
 else
  p.df=p.df*drag
  p.force=p.force*drag
 end

 --if abs(p.df)<0.001 then p.df=0 end
 p.df=mid(-2,p.df,2)

 p.force=p.force+p.df

 if abs(p.force)<0.04 then p.force=0 end
 p.force=mid(-6,p.force,6)

 p.dx=cos(p.angle)*p.force
 p.dy=-sin(p.angle)*p.force

 for _,star in pairs(stars) do
  local x=star.x
  local y=star.y
  star.x=star.x-p.dx*star.depth
  star.y=star.y-p.dy*star.depth
  if star.x<0 then
   star.x=screen.x2+star.x
  end
  if star.x>screen.x2 then
   star.x=star.x-screen.x2
  end
  if star.y<0 then
   star.y=screen.y2+star.y
  end
  if star.y>screen.y2 then
   star.y=star.y-screen.y2
  end
 end
end

function _draw()
 cls()

 if abs(p.force)>3 then
  for _,star in pairs(stars) do
   if star.depth>0.5 then
    line(star.x,star.y,star.x+p.dx*p.force/3*star.depth,star.y+p.dy*p.force/3*star.depth,star.col2)
   end
  end
 end

 for _,star in pairs(stars) do
  pset(star.x,star.y,star.col)
 end

 line(p.x,p.y,p.x-p.dx,p.y-p.dy,9)
 pset(p.x,p.y,8)

 local len=5
 local ang=0.37
 local ship=2

 local tx=p.x+cos(p.angle)*len
 local ty=p.y-sin(p.angle)*len

 local lx=p.x+cos(p.angle-ang)*len
 local ly=p.y-sin(p.angle-ang)*len

 local rx=p.x+cos(p.angle+ang)*len
 local ry=p.y-sin(p.angle+ang)*len

 line(tx,ty,lx,ly,ship)
 line(tx,ty,rx,ry,ship)

 --line(p.x,p.y,rx,ry,ship)
 --line(p.x,p.y,lx,ly,ship)
 line(rx,ry,lx,ly,ship)

 --print(p.force,0,0,10)
end
