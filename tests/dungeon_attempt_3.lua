local diff_dir={{0,-1},{1,0},{0,1},{-1,0}}
--local diff_index={{-1,-1},{0,-1},{1,-1},{-1,0},{0,0},{1,0},{-1,1},{0,1},{1,1}}
--[[
local diff_map={}
for ty=-1,1 do
 for tx=-1,1 do
  add(diff_map,{x=tx,y=ty})
 end
end
]]

printh("+++")

lost_doors = {
 {nil,nil,nil,nil,{},nil,nil,nil,nil},
 {nil,{3},nil,{2},nil,{4},nil,{1},nil},
 nil,
 {{2,3},nil,{3,4},nil,nil,nil,{1,2},nil,{1,4}},
 nil,
 nil,
 nil,
 nil,
 {{2,3},{2,3,4},{3,4},{1,2,3},{1,2,3,4},{1,3,4},{1,2},{1,2,4},{1,4}}
}

function to_unsigned(n)
 printh("n: "..n)
 return n==nil and 128 or (n<0 and (n+256) or n)
end

function to_signed(n)
 return n<128 and n or n>128 and (n-256) or nil
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

function unsignedhex(n)
 return lpad(hex(to_unsigned(n)),2)
end

function t2s(t)
 local r=unsignedhex(#t)
 for i=1,#t do
  if type(t[i])=="table" then
   r=r..unsignedhex(-127)..t2s(t[i])
  else
   r=r..unsignedhex(t[i])
  end
 end
 printh("r: "..r)
 return r
end


local m=0
function s2t()
 local t,i,c={},0,mapi(m)
 while i<c do
  m+=1
  i+=1
  local n=mapi(m)
  if n==-127 then
   m+=1
   add(t,s2t())
  else
   add(t,n)
  end
 end
 return t
end

function mapi(i)
 return myget(i,0)
end

function myget(x,y)
 --local s="02020a"
 --local s="040a8103010203810264781e"
 local s="04810200ff81020100810200018102ff00"
 local n=to_signed(tonum('0x'..sub(s,2*x+1,2*x+2)))
 printh("n: "..n.. " x: "..x.." y: "..y)
 --printh(2*x+1)
 return n
end

function mapi2(i)
 return to_signed(mget(i%128,flr(i/128)))
end

printh(t2s(diff_dir))

--assert(false)

--[[
x=t2s({10,20,30})
printh(x)


x=t2s({10,{100,120},30})
printh(x)

x=t2s(lost_doors)
printh(x)
]]

--x=t2s({10,20,30})
--y=s2t(x)

--x=t2s({10,20,30})
x=t2s({10,{1,2,3},{100,120},30})
printh(x)

y=s2t()
for k,v in pairs(y) do
 if type(v)=="table" then
  printh(k.." => table #"..#v)
  for k2,v2 in pairs(v) do
   printh(" - "..k2.." => "..v2)
  end
 else
  printh(k.." => "..v)
 end
end

printh(y[3][2])


assert(false)


for i=-128,127 do
 local j=to_unsigned(i)
 local i2=to_signed(j)
 printh(i.." -> "..j.." => "..(i2==nil and "nil" or i2))
end

local j=to_unsigned(nil)
local i2=to_signed(j)
printh("nil -> "..j.." => "..(i2==nil and "nil" or i2))
