pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--[[
m={2,8,9,10,11,3}c,s=cos,sin
function g(x,y,a,d,p)local v,k=x+c(a)*d,y+d*s(a)line(x,y,v,k,m[p+1])
if(p>0)g(v,k,a-u,d/1.5,p-1)g(v,k,a+u,d/1.5,p-1)
end
::_::flip()z=t()cls()u=c(z*0.01)d=48+24*c(z*0.15)for i=1,4 do
a=i/4+z*0.05g(c(a)*70+64,s(a)*70+64,a-0.5,d,5)end
goto _
--]]

m={2,8,9,10,11,3}c,s=cos,sin
function g(x,y,a,d,p)local v,k=x+c(a)*d,y+d*s(a)line(x,y,v,k,m[p+1])
if(p>0)g(v,k,a-u,d/1.5,p-1)g(v,k,a+u,d/1.5,p-1)
end
function _draw()z=t()cls()u=c(z*0.01)d=48+24*c(z*0.15)for i=1,4 do
a=i/4+z*0.05g(c(a)*70+64,s(a)*70+64,a-0.5,d,5)end
end
function _update60()end

