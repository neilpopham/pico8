pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- tic-80 fset
-- by neil popham

local sprf={}

function _fget(s,i)
 if i==nil then
  return flr(sprf[s+1] or 0)
 else
  b=2^i
  return sprf[s+1] % (2*b) >= b 
 end
end

function _fset(s,i,b)
  if b==nil then
   sprf[s+1]=i
  else
   if sprf[s+1]==nil then sprf[s+1]=0 end
   e=_fget(s,i)
   if (e and not b) or (not e and b) then 
    sprf[s+1]=sprf[s+1]+(b and 2^i or -2^i)
   end
  end
end

function _fget_old(s,i)
 local v=0
 if i==nil then
  if sprf[s+1]==nil then return 0 end
  for k,b in pairs(sprf[s+1]) do
   if b==true then v=v+(2^(k-1)) end
  end
 else
  if sprf[s+1]==nil then return false end
  v=sprf[s+1][i+1]
  if v==nil then v=false end
 end
 return v
end

function _fset_old(s,i,b)
 b=b or nil
 if sprf[s+1]==nil then sprf[s+1]={} end
 if b==nil then
  for v=0,7,1 do
    vp=2^v
    if i % (2*vp) >= vp then
     sprf[s+1][v+1]=true
    end
  end  
 else
  sprf[s+1][i+1]=b
 end
end

function _init()
 _fset(0,0,true)
 _fset(0,3,true)

 _fset(0,4,true)
 _fset(0,4,false)
 --fset(0,3,false)

 _fset(1,134)
 --fset(1,1,true)
 --fset(1,2,true)
 --fset(1,7,true) 
 _fset(1,7,false)
 _fset(1,1,false)


 _fset(0,0)
 _fset(1,0)

 _fset(0,0,true)
 _fset(0,1,true)
 _fset(0,2,true)
 _fset(0,2,false)
 _fset(0,3,true)

 _fset(1,0,true)
 _fset(1,1,true)
 _fset(1,4,true)

 _fset(0, 56)
 _fset(1, 73)

 -- dump fget data to an array format that can be used in tic-80 code
 d=""
 for s=0,127 do
  d=d..fget(s)..","
 end
 printh(d,"@clip")

 for sprite,flags in pairs(sprf) do

 end
end

function _update()
 --
end

function _draw()
 cls()

 --[[
 for sprite,flags in pairs(sprf) do
  for key,value in pairs(flags) do
   print(sprite,0+((sprite-1)*50),key*10,2+sprite)
   print(key,10+((sprite-1)*50),key*10,2+sprite)
   print(value,20+((sprite-1)*50),key*10,2+sprite)
  end
 end
]]

 for s=0,1 do
  for i=0,7 do
   print(_fget(s,i),s*40,i*9,s+1)
  end
 end

 print(_fget(0),0,100,1) 
 print(_fget(1),40,100,2)
 print(_fget(2),80,100,3)

 spr(0,0,0)

end


__gff__
0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
