pico-8 cartridge // http://www.pico-8.com
version 16

__lua__
function vec2(x,y)
 return {
  x=x,
  y=y
 }
end

function round(x)
 return flr(x+0.5)
end

local drag={air=1,ground=0.8,gravity=0.15}

local p={
 -- player position
	pos=vec2(60,100),
 -- player acceleeration
	acc=vec2(0.05,-1.75),
 -- player difference in postion
	diff=vec2(0,0),
 is={
  still=true,
  walking=false,
  grounded=true,
  jumping=false,
  falling=false
 },
 max={
  diff={x=1,y=2}
 },
 -- return 
 stage=function(self)
  return self.anim.stage[self.anim.current.stage]
 end,
 frame=function(self)
  local stage=self.anim.stage[self.anim.current.stage]
  local face=stage[self.anim.current.face]
  return face.frames[self.anim.current.frame]
 end,
 ticks=function(self)
  return self.anim.stage[self.anim.current.stage].ticks
 end,
 facingleft=function()
  return self.anim.current.face=="left"
 end,
 facingright=function()
  return self.anim.current.face=="right"
 end,
	anim={
  init=function(self)
   -- record frame count for each stage face
   for sk,sv in pairs(self.stage) do
    for fk,fv in pairs({"left","right"}) do
     self.stage[sk][fv].fcount=#self.stage[sk][fv].frames
    end
   end
   -- init current values
   self.current.set(self)
  end,
  -- e.g.: anim.stage.jump.right.frames[2]
		stage={
   stand={
    ticks=4,
    loop=false,
    left={
     frames={1}
    },
    right={
     frames={1}
    }
   },
   walk={
    ticks=1,
    loop=true,
    left={
     frames={1,3}
    },
    right={
     frames={1,4,5,6}
    }
   }
		},
  current={
   stage="stand",
   face="right",
   frame=1,
   tick=0,
   loop=true, -- whether we should be progressing animation
   set=function(self,s,f)
    self.frame=1
    self.tick=0
    self.loop=true
    self.stage=s or self.stage
    self.face=f or self.face
   end
  },
  update=function(self)
   local stage=self.anim.stage[self.anim.current.stage]
   local face=stage[self.anim.current.face]
   local ticks=self.anim.stage[self.anim.current.stage].ticks
   local loop=self.anim.stage[self.anim.current.stage].loop

   if self.anim.current.loop then
    self.anim.current.tick=self.anim.current.tick+1

    if self.anim.current.tick==ticks then
     self.anim.current.tick=0
     self.anim.current.frame=self.anim.current.frame+1
     if self.anim.current.frame>face.fcount then
      if loop then
       self.anim.current.frame=1
      else
       self.anim.current.frame=face.fcount
       self.anim.current.loop=false
      end
     end
    end 
   end
   return face.frames[self.anim.current.frame]
  end 
	}
}

function _init()
 p.anim:init()
 --p.anim.current:set()
end

function _update60()

 -- horizontal movement
 if btn(0) then
  p.diff.x=p.diff.x-p.acc.x
 elseif btn(1) then
  p.diff.x=p.diff.x+p.acc.x
 else
  if p.is.grounded then
   p.diff.x=p.diff.x*drag.ground
  else
   p.diff.x=p.diff.x*drag.air
  end
 end
 p.diff.x=mid(-p.max.diff.x,p.diff.x,p.max.diff.x)
 p.pos.x=p.pos.x+round(p.diff.x)


 -- p.anim.current.stage="walk"
 -- p.anim.current.face="right"
 -- p.anim.current:set("walk")
 -- if p:facingright() ...
end

function _draw()
 cls()
 spr(p:frame(),p.pos.x,p.pos.y)
 print(p:frame(),0,0,2)
 print(p.pos.x,0,9,3)
 print(p.anim.stage.walk.right.fcount,0,18,4)
 --printh("foo")

 print(p.pos.x,0,27,5)
 print(p.acc.x,0,36,5)
 print(p.diff.x,0,43,5)
end

__gfx__
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
