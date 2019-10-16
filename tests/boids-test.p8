pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function distance(x1,y1,x2,y2)
 return abs(x1-x2)+abs(y1-y2)
end

range=40
strength=10

as={
 {20,20,0.5},
 {65,30,0.85},
 {90,75,0.75},
 {30,35,0.75},
}

as={
 {20,40,0.5},
 {45,30,0.3},
 {25,60,0.65},
 {35,70,0.8},

}

b={50,50,0.5}

cls()

printh("===")

function adiff(a1,a2)
 --0.5-MOD(A26+0.5-$B$25,1)
 return 0.5-(a1+0.5-a2)%1
end

-- cohesion

function cohesion()
 local dx,dy=0,0
 local bdx,bdy=0,0

 for i,a in pairs(as) do
  dx=dx+a[1]
  dy=dy+a[2]
  circfill(a[1],a[2],2,2)
 end

 bdx=dx/#as
 bdy=dy/#as
 c={bdx,bdy}

 printh(c[1]..","..c[2])
 circfill(c[1],c[2],2,7)
end

-- align

function align()
 local da=0
 for i,a in pairs(as) do
  printh("adiff:"..adiff(b[3],a[3]))
  da=da+adiff(b[3],a[3])
  circfill(a[1],a[2],2,2)
  line(a[1],a[2],a[1]+cos(a[3])*5,a[2]-sin(a[3])*5,12)
 end
 printh(da.." - "..(#as))
 da=da/#as
 b[3]=(b[3]+da)%1
 printh("b[3]:"..b[3])
end

-- avoid

function avoid()
 local dx,dy=0,0
 local bdx,bdy=0,0

 for i,a in pairs(as) do
  printh((a[1]-b[1])..","..(a[2]-b[2]))
  circfill(a[1],a[2],2,2)
  dx=a[1]-b[1]
  dy=a[2]-b[2]
  printh(atan2(dx,-dy))
  printh(distance(b[1],b[2],a[1],a[2]))
  local d=distance(b[1],b[2],a[1],a[2])
  printh("distance:"..d)
  local power=(range/d)*strength
  printh("cos:"..(cos(atan2(dx,-dy))*power))
  printh("sin:"..(-sin(atan2(dx,-dy))*power))
  bdx=bdx-cos(atan2(dx,-dy))*power
  bdy=bdy+sin(atan2(dx,-dy))*power
 end

 c={b[1]+bdx,b[2]+bdy}
 printh(c[1]..","..c[2])
 circfill(c[1],c[2],2,7)
end

--avoid()
align()
--cohesion()

circfill(b[1],b[2],2,3)
line(b[1],b[2],b[1]+cos(b[3])*5,b[2]-sin(b[3])*5,12)
