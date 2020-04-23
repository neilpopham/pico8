stage_main_viewing = {
 init=function(self)

 end,
 update=function(self)
  if btnp(pad.btn2) then
   stage:set_state(stage_main_ui)
   return
  end
  local btnpbm=btnp()
  if btnpbm and btnpbm>0 then
   local md,cg=1000,nil
   local angles={
    {0.25,0.75,0.5},
    {0.75,0.25,0},
    {},
    {0.5,1,0.75},
    {0.5,0.75,0.625},
    {0.75,1,0.875},
    {},
    {0,0.5,0.25},
    {0.25,0.5,0.375},
    {0,0.25,0.125},
   }
   if angles[btnpbm] then
    local r=angles[btnpbm]
    function f1(a) return a>r[1] and a<r[2] end
    function f2(a) return a>r[1] or a<r[2] end
    check_angle=r[2]>r[1] and f1 or f2
    for i,g in pairs(p.arsenal) do
      local d=p:distance(g)
      local dx=g.x-p.x
      local dy=g.y-p.y
      local angle=atan2(dx,-dy)
      -- an attempt to bias guns closer to the direction moved
      -- make it easier to find the difference in angle
      -- between the direction pressed and the angle of the gun
      local da=angle-r[3]
      if da<0 then da=1+da end
      if da>0.5 then da=1-da end
      if da==0 then da=0.0001 end
      -- amend distance according to angle difference (smaller difference=smaller distance)
      local nd=d*da
      -- end: an attempt to bias guns closer to the direction moved
      -- if this gun is closer use it
      if nd>0 and nd<md and check_angle(angle) then
       cg,md=i,nd
      end
    end
    if cg then
     p.gun=p.arsenal[cg]
     p.x=p.gun.x
     p.y=p.gun.y
     p:cache()
    end
   end
  end
 end,
 draw=function(self)
  -- draw mask for active gun
  for k,v in pairs(p.gun.mask) do
   rect(3+v.x*5,3+v.y*5,5+v.x*5,5+v.y*5,1)
  end
  -- draw player selector
  p:draw()
 end
}
