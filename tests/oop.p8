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

function deepcopy(orig)
 local orig_type=type(orig)
 local copy
 if orig_type=='table' then
  copy={}
  for orig_key,orig_value in pairs(orig) do
   copy[deepcopy(orig_key)]=deepcopy(orig_value)
  end
  setmetatable(copy,deepcopy(getmetatable(orig)))
 else 
  copy=orig
 end
 return copy
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
  stage={
   stand={
    ticks=1,
    loop=false,
    left={
     frames={1}
    },
    right={
     frames={1}
    }
   }
  },
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


mariner = {}

function mariner.new ()
 local self = {}

 self.maxhp = 200
 self.hp = self.maxhp

 function self.heal (deltahp)
  self.hp = min (self.maxhp, self.hp + deltahp)
 end
 function self.sethp (newhp)
  self.hp = min (self.maxhp, newhp)
 end

 return self
end

function _init()

 p=entity.new()
 p.add_stage("walk",4,true,{2,3,4},{5,6,7})
 p.add_stage("jump",4,false,{8,9},{10,11}) 

 enemies = {}
 for i=1,10 do
  enemies[i]=entity.new() 
  enemies[i].add_stage("walk",4,true,{12,13,14},{15,16,17})
 end

 c=entity.new() 
 c.add_stage("walk",4,true,{12,13,14},{15,16,17})
 d=c.clone() 

 --[[
 enemies = {entity.new()}
 enemies[1].add_stage("walk",4,true,{12,13,14},{15,16,17})
 for i=2,10 do
  enemies[i]=enemies[1].clone()
 end
 ]]







 m1 = mariner.new()
 m2 = mariner.new()
 m1.sethp(100)
 m1.heal(13)
 m2.sethp(90)
 m2.heal(5)
end

function _update()

end

function _draw()
 cls()
 print ("mariner 1 has got "..m1.hp.." hit points",0,0)
 print ("mariner 2 has got "..m2.hp.." hit points",0,10)
 print (p.anim.stage.walk.right.frames[2],0,20)
 print (d.anim.stage.walk.right.frames[2],0,30)
 print (enemies[6].anim.stage.walk.left.frames[2],0,40)
end
