function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

function round(x)
 return flr(x+0.5)
end

--[[
function extend(t1,t2)
 for k,v in pairs(t2) do t1[k]=v end
 return t1
end
--]]

---[[
function extend(...)
 local arg={...}
 local o=del(arg,arg[1])
 for a in all(arg) do
  for k,v in pairs(a) do
   o[k]=v
  end
 end
 return o
end
--]]
