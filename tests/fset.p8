pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- tic-80 fset
-- by neil popham

local spr_f={}



function _fget(s,i)
 if i==nil then
  if spr_f[s+1]==nil then
   return 0
  else
   return spr_f[s+1]
  end
 else
  b=2^i
  return spr_f[s+1] % (2*b) >= b 
 end
end

function _fset(s,i,b)
  if b==nil then
   spr_f[s+1]=i
  else
   if spr_f[s+1]==nil then spr_f[s+1]=0 end
   if b then p=2 else p=-2 end
   spr_f[s+1]=spr_f[s+1]+(p^i)
  end
end

function _fget_old(s,i)
 local v=0
 if i==nil then
  if spr_f[s+1]==nil then return 0 end
  for k,b in pairs(spr_f[s+1]) do
   if b==true then v=v+(2^(k-1)) end
  end
 else
  if spr_f[s+1]==nil then return false end
  v=spr_f[s+1][i+1]
  if v==nil then v=false end
 end
 return v
end

function _fset_old(s,i,b)
 b=b or nil
 if spr_f[s+1]==nil then spr_f[s+1]={} end
 if b==nil then
  for v=0,7,1 do
    vp=2^v
    if i % (2*vp) >= vp then
     spr_f[s+1][v+1]=true
    end
  end  
 else
  spr_f[s+1][i+1]=b
 end
end

function _init()
 _fset(0,0,true)
 _fset(0,3,true)
 --_fset(0,9)
 _fset(1,134)
 --_fset(1,1,true)
 --_fset(1,2,true)
 --_fset(1,7,true)
end

function _update()
 --
end

function _draw()
 cls()

 --[[
 for sprite,flags in pairs(spr_f) do
  for key,value in pairs(flags) do
   print(sprite,0+((sprite-1)*50),key*10,2+sprite)
   print(key,10+((sprite-1)*50),key*10,2+sprite)
   print(value,20+((sprite-1)*50),key*10,2+sprite)
  end
 end
]]

 print(_fget(0,0),0,0,1)
 print(_fget(0,3),0,10,1)
 print(_fget(0,5),0,20,1)
 print(_fget(1),0,40,2)
 print(_fget(0),0,50,3)

 print(_fget(1,1),30,0,4)
 print(_fget(1,2),30,10,4)
 print(_fget(1,3),30,20,4)
 print(_fget(1,7),30,30,4)

end


