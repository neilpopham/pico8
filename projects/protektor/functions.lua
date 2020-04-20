function mrnd(x,f)
 if f==nil then f=true end
 local r=x[1]+rnd((f and 1 or 0)+x[2]-x[1])
 return f and flr(r) or r
end

function round(x)
 return flr(x+0.5)
end

function extend(...)
 local arg={...}
 local o=del(arg,arg[1])
 for _,a in pairs(arg) do
  for k,v in pairs(a) do
   o[k]=v
  end
 end
 return o
end

function clone(o)
 local c={}
 for k,v in pairs(o) do
  c[k]=v
 end
 return c
end

function lpad(x,n)
 n=n or 2
 return sub("0000000"..x,-n)
end

function dprint(s,x,y,c1,c2)
 c1=c1 or 7
 c2=c2 or 2
 print(s,x,y+1,c2)
 print(s,x,y,c1)
end

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
   if type(v)=="function" then v="[function]" end
   printh(p..k.. " => "..v.." ("..t..")")
  end
 end
 if i==0 then printh(p.."(empty)") end
end
