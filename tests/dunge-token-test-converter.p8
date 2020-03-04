pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

diff_dir={{0,-1},{1,0},{0,1},{-1,0}}
lost_doors = {
 {0,0,0,0,{},0,0,0,0},
 {0,{3},0,{2},0,{4},0,{1},0},
 0,
 {{2,3},0,{3,4},0,0,0,{1,2},0,{1,4}},
 0,
 0,
 0,
 0,
 {{2,3},{2,3,4},{3,4},{1,2,3},{1,2,3,4},{1,3,4},{1,2},{1,2,4},{1,4}}
}
roomtl={
 {0,0,0,0,{0,0},0,0,0,0},
 {0,{0,0},0,{0,0},0,{1,0},0,{0,1},0},
 0,
 {{0,0},0,{1,0},0,0,0,{0,1},0,{1,1}},
 0,
 0,
 0,
 0,
 {{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}},
}

--[[

function to_unsigned(n)
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
 return r
end

]]

local n=0
function t2m(t,sub)
 mset(n%128,flr(n/128),#t)
 for i=1,#t do
  n+=1
  if type(t[i])=="table" then
   mset(n%128,flr(n/128),129)
   n+=1
   t2m(t[i],true)
  else
   mset(n%128,flr(n/128),t[i])
  end
 end
 if not sub then n+=1 end
end

--[[
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

function mapi(i)
 return to_signed(mget(i%128,flr(i/128)))
end
]]

--[[
printh(t2s(diff_dir))
printh(t2s(lost_doors))
printh(t2s(roomtl))
]]

memset(0x2000,0,0x1000)
t2m(diff_dir)
t2m(lost_doors)
t2m(roomtl)
cstore(0x2000,0x2000,0x1000)
--
