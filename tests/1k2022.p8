pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--
-- by neil popham

_set_fps(60)

r=rectfill
b=btn

function g()
 return rnd(128-w)
end

s=0
v=0
w=31
m=3
c=7
t=0
i=1
d=100
e={}
for l=1,4 do
 e[l]={g(),-d*l}
 printh(-d*l)
end

::_::

 --if(b()&3>0)v+=((v<0 and b() or 3^^b())*((b()-1)*.4-.2))

 vdl=1
 vdr=1
 if v<0 then vdr=2 end
 if v>0 then vdl=2 end
 if b(0) then v-=.2*vdl end
 if b(1) then v+=.2*vdr end

 v=mid(-m,v,m)
 --if t%4==0 then x+=v end

 e[i][1]+=flr(v+0.5)
 x=e[i][1]
 if x>127 then e[i][1]=0 end
 if x<0 then e[i][1]=127 end

 --if y>122 and (x+w<67 or x>60) then c=8 end

 c={3,3,3,3}
 c[i]=10
 if(x+w<67)c[i]=8
 if(x>60)c[i]=8

 cls()

 for l=1,4 do
  e[l][2]+=1
  if e[l][2]==128 then
   e[l]={g(),127-d*4}
   i=({2,3,4,1})[i]
   d=max(d-1,32)
   s+=1
   v=0
   --i+=1
   --if(i>4)i=1
  end

  r(0,e[l][2],127,e[l][2]+2,c[l])
  r(e[l][1],e[l][2],e[l][1]+w,e[l][2]+2,0)
  r(-1,e[l][2],e[l][1]-128+w,e[l][2]+2,0)

 end

 r(60,123,67,127,12)

 --print(x,0,0,3)
 --print(v,0,10,3)

 -- print(vdl,0,20,3)
 -- print(vdr,110,20,3)

 -- print(btn(),50,50,2)
 -- print(v<0 and b() or 3^^b(),60,60,2)
 -- printh(((v<0 and b() or 3^^b())*((b()-1)*.4-.2)))

 print(s,0,0,7)

 t+=1
 flip()
 goto _