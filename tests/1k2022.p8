pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--
-- by neil popham
--pal(0,1,1)
--pal({129},1)
_set_fps(60)
r=rectfill
b=btn
function g()return rnd(128-w)end
function lp(x)return "\^w"..sub("000"..x,-3)end
function dp(s,x,y,c)
?s,x,y+1,1
?s,x,y,c
end
w=31m=3h=0z=0
::_r::
i=1d=80e={}s=0v=0for l=1,4 do e[l]={g(),-d*l}end
::_::
cls(0)
c={3,3,3,3}
if h==1 then
if(b()&3>0)v+=((v<0 and b() or 3^^b())*((b()-1)*.4-.2))
--if(b()&3>0)v+=(b()-1)*.4-.2
v=mid(-m,v,m)
e[i][1]+=flr(v+0.5)x=e[i][1]
if(x>127)e[i][1]=0
if(x<0)e[i][1]=127
c[i]=10
if(x+w<67)c[i]=8
if(x>60)c[i]=8
for l=1,4 do
u=e[l]e[l][2]+=1
if u[2]==128 then
?"\aff.a"
e[l]={g(),127-d*4}i=1+i%4d=max(d-1,32)s+=1v=0
end
if (u[2]>120 and c[l]==8)h=2t=0q=1 ?"\aabgfedcccccc"
end
elseif h==0 then
if(s>z)z=s
dp("\^w▤gapp▤",32,48,10)
dp("❎ or 🅾️ to start",30,62,6)
if b()&48>0 then
?"\aeee.ee.aaaaaaaa"
h=1goto _r
end
end
if h~=0 then
for l=1,4 do
u=e[l]
r(0,u[2],127,u[2]+2,c[l])
r(u[1],u[2],u[1]+w,u[2]+2,0)
r(-1,u[2],u[1]-128+w,u[2]+2,0)
end
r(60,123,67,127,7)
end
if h==2 then
r(64-q,0,63+q,127,0)
for l=0,50 do
pset(63-q,rnd(127),8)
pset(64+q,rnd(127),8)
end
q*=1.1
if(q>99)h=0
end
dp(lp(s),0,0,12)dp(lp(z),106,0,9)
flip()
goto _