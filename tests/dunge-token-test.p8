pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function to_signed(n)
 return n<128 and n or n>128 and (n-256) or nil
end

function mapi(i)
 return to_signed(mget(i%128,flr(i/128)))
end

local m=0
function s2t(sub)
 local t,c={},mapi(m)
 for i=1,c do
  m+=1
  local n=mapi(m)
  if n==-127 then
   m+=1
   add(t,s2t(true))
  else
   add(t,n)
  end
 end
 if not sub then m+=1 end
 return t
end

diff_dir=s2t()
lost_doors=s2t()
roomtl=s2t()

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
   printh(p..k.. " => (table)")
   dumptable(v,l+1)
  else
   local t=type(v)
   if v==nil then v="nil" end
   if type(v)=="boolean" then v=v and "true" or "false" end
   printh(p..k.. " => "..v.." ("..t..")")
  end
 end
 if i==0 then printh(p.."(empty)") end
end

printh("-- diff_dir --")
dumptable(diff_dir)
printh("-- lost_doors --")
dumptable(lost_doors)
printh("-- roomtl --")
dumptable(roomtl)

function _init()

end

function _update60()

end

function _draw()

end

__map__
04810200ff81020100810200018102ff00098109000000008100000000008109008101030081010200810104008101010000810981020203008102030400000081020102008102010400000000810981020203810302030481020304810301020381040102030481030103048102010281030102048102010409810900000000
8102000000000000810900810200000081020000008102010000810200010000810981020000008102010000000081020001008102010100000000810981020000810201008102020081020001810201018102020181020002810201028102020200000000000000000000000000000000000000000000000000000000000000
