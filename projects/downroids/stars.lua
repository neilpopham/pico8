stars={
 items={},
 colours={15,14,13,12},
 create=function(self)
  local depths={1,0.7,0.5,0.3}
  --local colours={15,14,13,12}
  --local fades={14,13,12}
  srand(0.2074)
  for x=0,79 do
   local i=1+flr(x/20)
   add(
    self.items,
    {
     x=rnd(screen.x2),
     y=rnd(screen.y2),
     col=i,
     depth=depths[i],
    }
   )
  end
  srand()
 end,
 update=function(self)
  --move stars according to ship speed and their depth
  for _,star in pairs(self.items) do
   star.x=star.x-p.dx*star.depth
   if star.x<0 then
    star.x=screen.x2+star.x
   end
   if star.x>screen.x2 then
    star.x=star.x-screen.x2
   end
   star.y=star.y-p.dy*star.depth
   if star.y<0 then
    star.y=screen.y2+star.y
   end
   if star.y>screen.y2 then
    star.y=star.y-screen.y2
   end
  end
 end,
 draw=function(self)
  -- if we're going fast draw a trail
  if abs(p.force)>3 then
   local i=1
   local l={14,6,3}
   while self.items[i].depth>0.5 do
    for j=3,self.items[i].col,-1 do
     local f=abs(p.force)/l[j]
     line(
      self.items[i].x,
      self.items[i].y,
      self.items[i].x+p.dx*f*self.items[i].depth,
      self.items[i].y+p.dy*f*self.items[i].depth,
      self.colours[j]
     )
    end
    i=i+1
   end
  end
  -- draw the stars
  for _,star in pairs(self.items) do
   pset(star.x,star.y,self.colours[star.col])
  end
 end
}
