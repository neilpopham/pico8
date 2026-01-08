pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
printh"==="i={set=function(n)e=n end,check=function()if(e)n=e n:init()e=nil
end,shared=function()?"⁶w⁶tshared",0,20,2
end}i.intro={init=function(n)printh"init intro"end,update=function(n)if(btnp(🅾️)or btnp(❎))i.set(i.game)
end,draw=function(n)i.shared()?"⁶w⁶tintro",0,0,7
end}i.game={init=function(n)printh"init game"end,update=function(n)if(btnp(🅾️)or btnp(❎))i.set(i.outro)
end,draw=function(n)?"⁶w⁶tgame",0,0,8
end}i.outro={init=function(n)printh"init outro"end,update=function(n)if(btnp(🅾️)or btnp(❎))i.set(i.intro)
end,draw=function(n)i.shared()?"⁶w⁶toutro",0,0,9
end}function _init()n=i.intro n:init()end function _update60()n:update()end function _draw()cls()n:draw()i:check()end
