pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

function _init()
 chars="abcdefghijklmnopqrstuvwxyz0123456789 _*#"
 x=0
end

function _update60()
 if btnp(0) then x=x+4 end
 if btnp(1) then x=x-4 end
 if x<-156 then x=0 end
 if x>0 then x=-156 end
end

function _draw()
 cls(1)
 clip(0,0,4,6)
 print(chars,x,0)
 clip()
 print(x,0,10)
end
