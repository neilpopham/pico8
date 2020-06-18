pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function _init()
 a1=0
 a2=0
end

function _update60()
 if btnp(0) then a1-=0.05 end
 if btnp(1) then a1+=0.05 end
 if btnp(2) then a2-=0.05 end
 if btnp(3) then a2+=0.05 end

 a1=a1%1
 a2=a2%1

 dx1=cos(a1)*60
 dy1=-sin(a1)*60

 dx2=cos(a2)*60
 dy2=-sin(a2)*60

 da=a1-a2
 if da<0 then da=1+da end
 if da>0.5 then da=1-da end

 ds=0
 ra=(0.5-a1)%1
 dra=sgn(((a2+0.5-a1)%1)-0.5)

 if a2>a1 then ds=1 end
 if a2<a1 then ds=-1 end

end

function _draw()
 cls()
 circ(64,64,60,1)
 line(64,64,64+dx1,64+dy1,2)
 line(64,64,64+dx2,64+dy2,3)
 print(a1,0,0,2)
 print(a2,30,0,3)
 print(da,60,0,7)
 print(ra,0,10,8) print(dra,30,10,8)
end
