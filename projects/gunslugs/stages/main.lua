stage_main={

 init=function(self)
  level=0
  self:next(true)
 end,

 next=function(self,full)
  level+=1
  enemies:reset()
  bullets:reset()
  destructables:reset()
  pickups:reset()
  particles:reset()
  p:reset(full)
  fillmap(level)
 end,

 update=function(self)
  p:update()
  p.camera:update()
  bullets:update()

  local cx=p.camera:position()
  local cx2=cx+screen.width
  for _,o in pairs(destructables.items) do
   o.visible=(o.complete==false and o.x>=cx and o.x<=cx2)
  end
  for _,o in pairs(enemies.items) do
   o.visible=(o.complete==false and o.x>=cx and o.x<=cx2)
  end
  for _,o in pairs(pickups.items) do
   o.visible=(o.complete==false and o.x>=cx and o.x<=cx2)
  end

  enemies:update()
  destructables:update()
  pickups:update()
  particles:update()
 end,

 draw=function(self)
  p.camera:map()
  enemies:draw()
  pal()
  bullets:draw()
  destructables:draw()
  pickups:draw()
  particles:draw()
  p:draw()

  -- draw hud
  camera(0,0)

  print("level",1,1,6)
  print(lpad(level),24,1,9)

  -- health
  for i=1,p.max.health/100 do
   spr(p.health>=i*100 and 47 or 46,87+(8*(i-1)),0)
  end

 --[[
  for x=0,127 do
   for y=0,15 do
    if data[x][y] then
     if data[x][y]==1 then pset(x,y,7) end
     if data[x][y]==2 then pset(x,y,9) end
     if data[x][y]==3 then pset(x,y,8) end
     if data[x][y]==4 then pset(x,y,12) end
    end
   end
  end
 --]]

 ---[[
  local cx=p.camera:position()
  --print("\142:"..cx.." \152:"..(flr(stat(0))).." \150:"..(flr(stat(1)*100)),0,12,3)
 --]]
 end
}
