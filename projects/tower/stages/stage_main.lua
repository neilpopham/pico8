stage_main={
 state=stage_main_ui,
 init=function(self)
  level=2
  storeroom(level)
  p=extend(
   vec2:create(12,12),
   {
    credits=800,
    gun=guns[1],
    arsenal={},
    cache=function(self)
     self.tile=room[self.y+1][self.x+1]
     self.px=2+self.x*5
     self.py=2+self.y*5
    end,
    move=function(self)
     -- move player selector
     if btnp(pad.left) then self.x-=1 end
     if btnp(pad.right) then self.x+=1 end
     if btnp(pad.up) then self.y-=1 end
     if btnp(pad.down) then self.y+=1 end
     self.x=self.x%25
     self.y=self.y%25
     self:cache()
     -- check current tile
     if self.tile==0 then
       self.col=7
       self.valid=true
     else
      self.col=8
      self.valid=false
     end
    end,
    draw=function(self)
     rect(self.px-1,self.py-1,self.px+5,self.py+5,self.col)
    end
   }
  )
  self.x=0
  self.y=0
  p:cache()
 end,
 update=function(self)
  -- do state update
  self.state:update()
 end,
 draw=function(self)
  -- drap map
  sspr(0,100,25,25,2,2,125,125)
  -- do state draw
  self.state:draw()
  --draw placed turrets
  for k,g in pairs(p.arsenal) do
   rectfill(g.px,g.py,4+g.px,4+g.py,g.col)
  end
  -- player credits
  local c=lpad(p.credits,3)
  for y=-1,1 do
   for x=-1,1 do
    print(c,114+x,120+y,1)
   end
  end
  print(c,114,120,10)
 end,
 set_state=function(self,state)
  self.state=state
  self.state:init()
 end
}
