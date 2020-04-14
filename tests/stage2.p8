pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

stages={
 new=nil,
 update=function(self,new)
  self.new=new
 end,
 draw=function(self)
  if self.new then
   stage=self.new
   self.new=nil
   stage:init()
  end
 end
}

stage_intro={
 init=function(self)
 end,
 update=function(self)
  if btnp(4) then
   stages:update(stage_main)
  end
 end,
 draw=function(self)
  print("press \142 to start",30,61,7)
  print("\142",54,61,9)
 end
}

stage_main={
 init=function(self)
 end,
 update=function(self)
  if btnp(4) then
   stages:update(stage_outro)
  end
 end,
 draw=function(self)
  print("main",0,0,7)
 end
}

stage_outro={
 init=function(self)
 end,
 update=function(self)
  if btnp(4) then
   stages:update(stage_intro)
  end
 end,
 draw=function(self)
  print("outro",0,0,7)
 end
}

function _init()
 stage=stage_intro
 stage:init()
end

function _update60()
 stage:update()
end

function _draw()
 cls()
 stage:draw()
 stages:draw()
end
