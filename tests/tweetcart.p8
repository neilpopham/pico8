pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

r=rnd
d=0
--pal(1,128,1)
c={7,6,13,13,5,5}
for i=7,24 do c[i]=1 end
::_::
cls()
for a=10,0,-0.33 do
for x=1,0,-0.01 do
h=flr(r(a*4)*x)
if(h<25) pset(h+64+cos(a+x+d-1)*80*x,h+64+sin(a+x+d-1)*80*x,c[h])
end
end
d=d%2+0.01
flip()
goto _
