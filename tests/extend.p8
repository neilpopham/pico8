pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

d=nil

function extend(...)
 local arg={...}
 local o={}
 for _,a in pairs(arg) do
  for k,v in pairs(a) do o[k]=v end
 end
 return o
end

function _init()
 local a={a=1,b=2,c=3,d=4,e=5}
 local b={a=10,b=20,d=40,e=50}
 local c={d=400,e=500}
 d=extend(a,b,c)
 cls()
end

function _update()

end

function _draw()
 cls()
 for k,v in pairs(d) do
  print(k.."="..v)
 end
end
