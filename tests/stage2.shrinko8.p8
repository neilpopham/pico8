pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
e={new=nil,update=function(n,t)n.new=t end,draw=function(n)if(n.new)i=n.new n.new=nil i:init()
end}o={init=function(n)printh"intro"end,update=function(n)if(btnp(4))e:update(f)
end,draw=function(n)?"press 🅾️ to start",30,61,7
?"🅾️",54,61,9
end}f={init=function(n)printh"main"end,update=function(n)if(btnp(4))e:update(d)
end,draw=function(n)?"main",0,0,7
end}d={init=function(n)printh"outro"end,update=function(n)if(btnp(4))e:update(o)
end,draw=function(n)?"outro",0,0,7
end}function _init()i=o i:init()end function _update60()i:update()end function _draw()cls()i:draw()e:draw()end
__meta:title__

by Neil Popham
