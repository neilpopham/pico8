pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- letter picker
-- by neil popham

local chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
local s2c={}
local c2s={}
for i=1,95 do
 c=i+31 s=sub(chars,i,i) c2s[c]=s s2c[s]=c
end

function chr(i) return c2s[i] end
function ord(s,i) return s2c[sub(s,i or 1,i or 1)] end

function _init()

end

function _update()

end

function _draw()
 cls()
 circfill(10,10,20,1)
 clip(2,0,8,6)
 print("abc",0,0,10)
 clip()
 circfill(80,80,20,1)

end
