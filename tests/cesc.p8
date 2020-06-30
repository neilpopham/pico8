pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function dumptable(t,l)
 l=l or 0
 local p=""
 for i=0,l do
  p=p.."  "
 end
 local i=0
 for k,v in pairs(t) do
  i+=1
  if type(v)=="table" then
   print(p..k.. " => (table)")
   dumptable(v,l+1)
  else
   local t=type(v)
   if v==nil then v="nil" end
   if type(v)=="boolean" then v=v and "true" or "false" end
   if type(v)=="function" then v="[function]" end
   print(p..k.. " => "..v.." ("..t..")")
  end
 end
 if i==0 then print(p.."(empty)") end
end

v={1,2,3}
function test(z)
 add(z,4)
 return z
end
v=test(v)

dumptable(v)
