pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- testing rand function
-- by neil popham

--[[
function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end
--287
]]
function mrnd(x,f)
 if f==nil then f=true end
 local r=x[1]+rnd((f and 1 or 0)+x[2]-x[1])
 return f and flr(r) or r
end
--279

function rnd_int(min_val,max_val)
 max_val=max_val or 0
 if max_val==0 then max_val=min_val[2] min_val=min_val[1] end
	return flr(min_val+rnd(1+max_val-min_val))
end

function rnd_float(min_val,max_val)
 max_val=max_val or 0
 if max_val==0 then max_val=min_val[2] min_val=min_val[1] end
 return rnd_int(min_val*10000,max_val*10000)/10000
end

function _init()
 min=10000 max=0
 miny=min maxy=max
 minz=min maxz=max
end

function _update()
 --x=mrnd({1,3},true)
 --x=mrnd({0.9,1.0},false)
 --x=rnd_int(1,3)
 --x=rnd_float(0.9,1.0)
 x=mrnd({0.9,1.0},false)
 if x<min then min=x end
 if x>max then max=x end

 y=mrnd({100,200},true)
 if y<miny then miny=y end
 if y>maxy then maxy=y end

 z=rnd_int({100,200})
 if z<minz then minz=z end
 if z>maxz then maxz=z end

end

function _draw()
 cls()
 print("min:"..min,0,0)
 print("max:"..max,0,10)
 print("x:"..x,0,20)

 print("min:"..miny,48,0)
 print("max:"..maxy,48,10)
 print("y:"..y,48,20)

 print("min:"..minz,96,0)
 print("max:"..maxz,96,10)
 print("z:"..z,96,20)
end
