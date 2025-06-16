pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- disjointed
-- by neil popham

p={
 head={
  x=64,
  y=32,
  update=function(self)

  end,
  draw=function(self)
   local x,y=self.x,self.y
   rectfill(x,y,x+16,y+16,2)
  end,
 },
 torso={
  x=64,
  y=48,
  update=function(self)

  end,
  draw=function(self)
   local x,y=self.x,self.y
   rectfill(x,y,x+12,y+12,2)
  end,
 },
 feet={
  feet={
   {x=64,y=90},
   {x=80,y=90}
  },
  update=function(self)

  end,
  draw=function(self)
   for i=1,2 do
    local x,y=self.feet[i].x,self.feet[i].y
    rectfill(x,y,x+8,y+8,2)
   end
  end,
 },
  update=function(self)

  end,
  draw=function(self)
  self.head:draw()
  self.torso:draw()
  self.feet:draw()
 end
}

function _init()

end

function _update60()
 p:update()
end

function _draw()
 p:draw()
end
