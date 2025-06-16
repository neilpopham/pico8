pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- oop
-- by neil popham
-- http://lua-users.org/wiki/objectorientationclosureapproach
-- http://lua-users.org/wiki/copytable
-- http://lua-users.org/wiki/objectorientedprogramming


function vec2(x,y)
 return {
  x=x,
  y=y
 }
end

function round(x)
 return flr(x+0.5)
end

function deepcopy(o)
 local ot=type(o)
 local c
 if ot=='table' then
  c={}
  for k,v in pairs(o) do
   c[deepcopy(k)]=deepcopy(v)
  end
  setmetatable(c,deepcopy(getmetatable(o)))
 else 
  c=o
 end
 return c
end

stage={}
function stage.new(ticks,loop,left,right)
 local self = {}
 self.ticks=ticks
 self.loop=loop
 self.left={frames=left}
 self.right={frames=right}
 return self
end

entity={}
function entity.new()
 local self = {}
 self.pos=vec2(0,0)
 self.acc=vec2(0.05,-1.75)
 self.diff=vec2(0,0)
 self.anim={
  stage={},
  current={
   stage="stand",
   face="right",
   frame=1,
   tick=0,
   loop=false,
   set=function(this,s,f)
    this.frame=1
    this.tick=0
    this.loop=true
    this.stage=s or this.stage
    this.face=f or this.face
   end
  }
 }
 function self.clone()
  return deepcopy(self)
 end
 function self.add_stage(name,ticks,loop,left,right)
  self.anim.stage[name]=stage.new(ticks,loop,left,right)
 end
 return self
end

function _init()

 -- set up player
 p=entity.new()
 p.add_stage("stand",1,false,{1},{1})
 p.add_stage("walk",4,true,{2,3,4},{5,6,7})
 p.add_stage("jump",4,false,{8,9},{10,11}) 
 p.anim.current:set("stand","right")

 -- set up enemies (these are all the same)
 enemies = {}
 for i=1,10 do
  enemies[i]=entity.new() 
  enemies[i].add_stage("stand",1,false,{1},{1})
  enemies[i].add_stage("walk",4,true,{12,13,14},{15,16,17})
  enemies[i].anim.current:set("walk","left")
 end

 c=entity.new() 
 c.add_stage("walk",4,true,{12,13,14},{15,16,17})
 d=c.clone() 

 --[[
 enemies = {entity.new()}
 enemies[i].add_stage("stand",1,false,{1},{1})
 enemies[1].add_stage("walk",4,true,{12,13,14},{15,16,17})
 enemies[i].anim.current:set("stand","left")
 for i=2,10 do
  enemies[i]=enemies[1].clone()
 end
 ]]

end

function _update()

end

function _draw()
 cls()
 print (p.anim.stage.walk.right.frames[2],0,0)
 print (d.anim.stage.walk.right.frames[2],0,10)
 print (enemies[6].anim.stage.walk.left.frames[2],0,20)
end
