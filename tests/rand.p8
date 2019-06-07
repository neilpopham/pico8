pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- testing rand function
-- by neil popham

function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

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
end

function _update()
 --x=mrnd({1,3},true)
 --x=mrnd({0.9,1.0},false)
 --x=rnd_int(1,3)
 --x=rnd_float(0.9,1.0)
 x=rnd_float({0.9,1.0})
 if x<min then min=x end
 if x>max then max=x end
end

function _draw()
 cls()
 print("min:"..min,0,0)
 print("max:"..max,0,10)
 print("x:"..x,0,20)
end
