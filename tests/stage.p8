pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

game={
 init=function(self)

 end,
 update=function(self)
  x=1
  if btnp(4) then
   stage=intro
   stage.init()
  end
 end,
 draw=function(self)
  cls()
  print("game",0,0,10)
  print(x,0,10,10)
 end,
}

intro={
 init=function(self)

 end,
 update=function(self)
  x=2
  if btnp(4) then
   stage=game
   stage.init()
  end
 end,
 draw=function(self)
  cls()
  print("intro",0,0,10)
  print(x,0,10,10)
 end,
}

stage=intro

function _init()
 x=1
end

function _update()
 stage:update()
end

function _draw()
 stage:draw()
end
