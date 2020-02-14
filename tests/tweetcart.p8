pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

d=2
c={7,6,13,13,5,5,5}
for i=8,24 do c[i]=1 end
::_::
cls()
for a=0,10,0.33 do
for x=0,1,0.01 do
h=flr(rnd(a*3)*x)
if(h<24) pset(h+64-cos(a+x+d-1)*90*x,h+64+sin(a+x+d-1)*90*x,c[h+1])
end
end
d=d%2-0.01
flip()
goto _
