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

function set_visible(items)
 local cx=p.camera:position()
 local cx2=cx+screen.width
 for _,collection in pairs(items) do
  for _,o in pairs(collection.items) do
   o.visible=(o.complete==false and o.x>=cx-32 and o.x<=cx2+32)
  end
 end
end

function zget(tx,ty)
 local tile=mget(tx,ty)
 if fget(tx,ty,0) then return true end
 for _,d in pairs(destructables.items) do
  if d.visible then
   local dx,dy=flr(d.x/8),flr(d.y/8)
   if dx==tx and dy==ty then return true end
  end
 end
 return false
end

function lpad(x,n)
 n=n or 2
 return sub("0000000"..x,-n)
end
