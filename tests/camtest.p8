pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

function round(x) return flr(x+0.5) end

local screen={width=128,height=128}

function create_camera(item,x,y)
 local c={
  target=item,
  x=item.x,
  y=item.y,
  buffer=16,
  min={x=8*flr(screen.width/16),y=8*flr(screen.height/16)}
 }
 c.max={x=x-c.min.x,y=y-c.min.y,shift=2}
 c.update=function(self)
  self.min_x = self.x-self.buffer
  self.max_x = self.x+self.buffer
  self.min_y = self.y-self.buffer
  self.max_y = self.y+self.buffer
  if self.min_x>self.target.x then
   self.x=self.x+min(self.target.x-self.min_x,self.max.shift)
  end
  if self.max_x<self.target.x then
   self.x=self.x+min(self.target.x-self.max_x,self.max.shift)
  end
  if self.min_y>self.target.y then
   self.y=self.y+min(self.target.y-self.min_y,self.max.shift)
  end
  if self.max_y<self.target.y then
   self.y=self.y+min(self.target.y-self.max_y,self.max.shift)
  end
  if self.x<self.min.x then
   self.x=self.min.x
  elseif self.x>self.max.x then
   self.x=self.max.x
  end
  if self.y<self.min.y then
   self.y=self.min.y
  elseif self.y>self.max.y then
   self.y=self.max.y
  end
 end
 c.update=function(self)
  self.x=mid(self.min.x,self.target.x,self.max.x)
  self.y=mid(self.min.y,self.target.y,self.max.y)
 end
 c.position=function(self)
  return self.x-self.min.x,self.y-self.min.y
 end
 c.map=function(self)
  camera(self.x-self.min.x,self.y-self.min.y)
  map(0,0)
 end
 return c
end

function create_item(x,y)
 local i={
  x=x,
  y=y
 }
 return i
end

function _init()
  p=create_item(40,40)
  p.camera=create_camera(p,320,192)
end

function _update60()
  if btn(2) then p.y=p.y-1 end
  if btn(3) then p.y=p.y+1 end
  if btn(0) then p.x=p.x-1 end
  if btn(1) then p.x=p.x+1 end
  p.camera:update()
end

function _draw()
 cls()

 --camera(p.camera:position())
 --map(0,0)
 p.camera:map()

 spr(1,p.x,p.y)

 camera(0,0)

 print ("camera x:"..p.camera.x,0,0)
 print ("y:"..p.camera.y,60,0)

 print("min x:"..p.camera.min.x,0,7)
 print("y:"..p.camera.min.y,60,7)
 print("max x:"..p.camera.max.x,0,14)
 print("y:"..p.camera.max.y,60,14)

 if type(p.camera.min_x)~="nil" then
  print("min_x:"..p.camera.min_x,0,30)
  print("max_x:"..p.camera.max_x,60,30)
  print("min_y:"..p.camera.min_y,0,37)
  print("max_y:"..p.camera.max_y,60,37)
 end

 print ("player x:"..p.x,0,110)
 print ("y:"..p.y,60,110)

end
__gfx__
00000000888888885555555533333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888885555555533333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888885555555533333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888885555555533333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888885555555533333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888885555555533333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888885555555533333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888885555555533333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303020000020202020202020200000002020202020202020202000000000000000200000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0302020002020202020200000202020202020202020202020200000000020202020202020000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000202020000020002000202000000020202020000020000000202000002020200020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020002020000020000000002020000020202020202000000020000020202000200000002020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002020202020000000000020000020000000000000000020200000002020000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002030002000000000000020200020000000002000000000202000002000200000002020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000002000002020200000200020000000200020002020200020200020200020000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000200020202020202000002020200020000000200000000020000020202000002020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200020000020200020000000000000000000202020002020000020000000200020000020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200020002020000020000000000000000000202020000020002020000000000020002000200020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200020000000000000200020202000000020202000002000202020000000200020202000200020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020000000200020200000002020000000000020002000002020000020202000202020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020002000000000202020202000002020200000000020200020202000200020000020202000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000002020200000000000002020202000002020202000202020200020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200020200000200020000000200020202000200000000000202020000000000000002000202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002020000000000000002020202000202020002000000000200020000020000020202000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002020000000002000202020000020202000202020202000202000202000200020002000202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002020000000200000000020000020200000000000202000202000002020000000202020000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002020202020000020200020000020002000000000200000202020202020002020002000200020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000002020202000002020000020000000200020200000202000202000202020202000202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000200000000000202020200020002020202020002000202020200000002020002000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002020202020000000000020202020002020000000200020202000202000200000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300020202020202000202020202020202000202000000000002020202000002020200020000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303000000000202020202020200000000020202020202020000000202020202020202000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
