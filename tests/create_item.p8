pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 
-- by neil popham

local dir={left=1,right=2}
local drag={air=1,ground=0.8,gravity=0.15}

function create_item(x,y)
 local i={
  x=x,
  y=y
 }
 return i
end

function create_moveable_item(x,y,a)
 local i=create_item(x,y)
 i.dx=0
 i.dy=0
 i.ax=a[1]
 i.ay=a[2]
 i.anim={
  init=function(self,stage,face)
   -- record frame count for each stage face
   for s in pairs(self.stage) do
    for f=1,2 do
     self.stage[s].face[f].fcount=#self.stage[s].face[f].frames
    end
   end
   -- init current values
   self.current:init(stage,face)
  end,  
  stage={},
  current={
   init=function(self,stage,face)
    self.set(self,stage,face)
   end,
   reset=function(self)
    self.frame=1
    self.tick=0
    self.loop=true
   end,
   set=function(self,stage,face)
    self.reset(self)
    self.stage=stage
    self.face=face or self.face
   end
  },
  add_stage=function(self,name,ticks,loop,left,right)
   self.stage[name]=create_stage(ticks,loop,left,right)
  end
 }
 return i
end

function create_controllable_item(x,y,a)
 local i=create_moveable_item(x,y,a)
 i.update=function(self)
  -- check buttons
  -- update animation

  -- if btn(0) then self.anim.current.face=dir.left
  -- if btn(1) then self.anim.current.face=dir.right
 end
 return i
end

function create_stage(ticks,loop,left,right)
 local s={
  ticks=ticks,
  loop=loop,
  face={{frames=left},{frames=right}}
 }
 return s
end

function _init()
 p=create_controllable_item(60,120,{1,1})
 p.anim:add_stage("still",4,false,{1,2,3},{4,5,6})
 p.anim:add_stage("walk",4,true,{7,8,9},{10,11,12})
 p.anim:init("still",dir.right)
end

function _update()

end

function _draw()
 cls()
 print(p.anim.stage.still.face[2].frames[2],0,0)
 print(p.x,0,10)
 print(p.ax,0,20) 
 print(p.anim.current.frame,0,30)
end
