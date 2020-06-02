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

function hex(v)
  local s,l,r=tostr(v,true),3,11
  while sub(s,l,l)=="0" do l+=1 end
  while sub(s,r,r)=="0" do r-=1 end
  return sub(s,min(l,6),flr(v)==v and 6 or max(r,8))
end

function lpad(x,n)
 n=n or 2
 return sub("0000000"..x,-n)
end

menuitem(
 1,
 "copy mapdata",
 function()
  reload(0x2000,0x2000,0x1000) -- reload cart map data
  local a={}
  for y=0,15 do
   a[y]={}
  end
  for k,pane in pairs(tile.panes) do
   local tx=pane.x\8
   local ty=pane.y\8
   local oy=0
   for my=pane.map.y,pane.map.y+7 do
    local ox=0
    for mx=pane.map.x,pane.map.x+7 do
     a[ty+oy][tx+ox]=mget(mx,my)
     ox+=1
    end
    oy+=1
   end
  end
  local c=""
  for y=0,15 do
   for x=0,15 do
    c=c..lpad(hex(a[y][x]))
   end
   c=c.."\n"
  end
  printh(c,"@clip")
  printh("copied to clipboard")
 end
)
