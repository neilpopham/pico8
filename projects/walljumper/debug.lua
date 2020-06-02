function dumptable(t,l)
 l=l or 0
 if l==0 then printh("dumptable") end
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
   if type(v)=="function" then v="[function]" end
   printh(p..k.. " => "..v.." ("..t..")")
  end
 end
 if i==0 then printh(p.."(empty)") end
end
