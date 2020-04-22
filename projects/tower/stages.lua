stages={
 new=nil,
 update=function(self,new)
  self.new=new
 end,
 draw=function(self)
  if self.new then
   stage=self.new
   self.new=nil
   stage:init()
  end
 end
}

stage_intro={
 init=function(self)
  rooms=decompress()
 end,
 update=function(self)
  if btnp(4) then
   stages:update(stage_main)
  end
 end,
 draw=function(self)
  print("press \142 to start",30,61,7)
  print("\142",54,61,9)
 end
}

stage_main={
 ui=true,
 changed=false,
 placing=false,
 ui_reset=function(self)
  uix=0
  uiy=0
  p.gun=guns[1]
 end,
 init=function(self)
  level=2
  storeroom(level)
  guns={
   {col=9,credits=5,range=3,power=2,speed=1,name="mechead",x=0,y=0},
   {col=8,credits=10,range=5,power=4,speed=3,name="laser",x=0,y=1},
   {col=10,credits=15,range=4,power=1,speed=2,name="glue gun",x=1,y=0},
   {col=14,credits=20,range=5,power=3,speed=4,name="supermech",x=1,y=1},
  }
  p=extend(
   vec2:create(12,12),
   {credits=800,arsenal={}}
  )
  self:ui_reset()
 end, -- draw
 update=function(self)
  self.changed=false
  if btnp(pad.btn2) and not self.placing then
   self.ui=not self.ui
   self.changed=true
  end
  if self.ui then
   if self.changed then
    --self:ui_reset()
   end
   if btnp(pad.left) and uix==1 then uix-=1 end
   if btnp(pad.right) and uix==0 then uix+=1 end
   if btnp(pad.up) and uiy==1 then uiy-=1 end
   if btnp(pad.down) and uiy==0 then uiy+=1 end
   for i,g in pairs(guns) do
    g.selected=(g.x==uix and g.y==uiy)
    if g.selected then p.gun=g end
   end
   if btnp(pad.btn1) and p.gun.credits<=p.credits then
    self.ui=false
    p.credits-=p.gun.credits
    self.placing=true
   end

  -- not self.ui
  else
   if self.changed then

   end

   if self.placing then

    if btnp(pad.left) then p.x-=1 end
    if btnp(pad.right) then p.x+=1 end
    if btnp(pad.up) then p.y-=1 end
    if btnp(pad.down) then p.y+=1 end
    p.x=p.x%25
    p.y=p.y%25

    -- calculate range
    local range=minsky(p.x,p.y,p.gun.range)
    mask={}
    for y,xs in pairs(range) do
     for x=xs.x1,xs.x2 do
      local tx=x*5+4
      local ty=y*5+4
      local px=p.x*5+4
      local py=p.y*5+4
      local cx,cy
      if los(px,py,tx,ty,function(x,y)
       cx,cy=get_cell(x,y)
       local tile=get_tile(cx,cy)
       return tile~=2
      end
      ) then
       local cell=vec2:create(cx,cy)
       local idx=cell:index()
       mask[idx]=cell
      end
     end
    end

    if btnp(pad.btn1) and p.valid then
     local gun=vec2:create(p.x,p.y)
     gun.type=p.gun
     gun.mask=clone(mask)
     gun.health=gun.type.health
     add(p.arsenal,gun)
     self.placing=false
    end

   -- not self.placing
   else

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
      printh("----")
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
        -- bwtween the direction pressed and the angle of the gun
        local a1=angle
        local a2=r[3]
        local da=0
        if angle<0.25 then da=0.5 end
        if angle>0.75 then da=-0.5 end
        a1+=da
        a2+=da
        local da=abs(a1%1-a2%1)
        -- amend distance according to angle (smaller angle, smaller distance)
        local nd=d*da
        -- an attempt to bias guns closer to the direction moved

        if nd>0 and nd<md and check_angle(angle) then
         cg,md=i,nd
        end
      end
      if cg then
       p.x=p.arsenal[cg].x
       p.y=p.arsenal[cg].y
      end
     end
    end
   end -- if self.placing

   p.tile=room[p.y+1][p.x+1]
   if p.tile==0 then
     p.col=7
     p.valid=true
   else
    p.col=8
    p.valid=false
   end

  end -- if self.ui
 end, -- update
 draw=function(self)

  sspr(0,100,25,25,2,2,125,125)

  for k,g in pairs(p.arsenal) do
   rectfill(2+g.x*5,2+g.y*5,6+g.x*5,6+g.y*5,g.type.col)
  end

  if self.ui then

   -- draw ui panel
   rectfill(1,107,127,127,1)
   rect(1,107,127,127,7)
   line(2,106,126,106,0)

   local gg=28

   -- draw gun options
   for _,g in pairs(guns) do
    rectfill(4+g.x*gg,110+g.y*10,8+g.x*gg,114+g.y*10,g.col)
    print(lpad(g.credits,2), 12+g.x*gg,110+g.y*10,g.credits>p.credits and 0 or 12)
   end

   function draw_bars(v,y,c)
    c=12
    for i=1,5 do
     line(65+2*i,y,65+2*i,y+2,i>v and 0 or c)
    end
   end

   -- current gun attributes
   spr(16,60,109)
   spr(17,60,115)
   spr(18,60,121)

   draw_bars(p.gun.range,110,2)
   draw_bars(p.gun.power,116,3)
   draw_bars(p.gun.speed,122,6)

   print(p.gun.name,126-(#p.gun.name*4),110,6)

   -- player selector
   rect(3+uix*gg,109+uiy*10,9+uix*gg,115+uiy*10,7)

   --[[
   rectfill(4,110,8,114,9)
   print("05C", 12,110,12)
   rect(3,109,9,115,7)

   rectfill(4,120,8,124,8)
   print("10C", 12,120,12)
   --rect(3,119,9,125,7)
   ]]


  -- not self.ui
  else



   if self.placing then

    -- draw range
    if p.valid then
     fillp(0b0101101001011010.1)
     --fillp(0b1001001101101100.1)



     for k,v in pairs(mask) do
      rectfill(2+v.x*5,2+v.y*5,6+v.x*5,6+v.y*5,1)
     end
     fillp()
    end

    -- draw gun marker
    rectfill(2+p.x*5,2+p.y*5,5+p.x*5,5+p.y*5,p.gun.col)

   -- not self.placing
   else

   end -- if self.placing

   -- player selector
   rect(1+p.x*5,1+p.y*5,6+p.x*5,6+p.y*5,p.valid and 7 or 8)

  end -- if self.ui

  -- player credits
  local c=lpad(p.credits,3)
  for y=-1,1 do
   for x=-1,1 do
    print(c,114+x,120+y,1)
   end
  end
  print(c,114,120,10)

 end -- draw
}

stage_main_old={
 init=function(self)
  level=2
  storeroom(level)
  p=vec2:create(0,11)
  p.col=7
  p.r=3
  f=vec2:create(15,24)
 end,
 update=function(self)
  if btnp(pad.left) then p.x=p.x-1 end
  if btnp(pad.right) then p.x=p.x+1 end
  if btnp(pad.up) then p.y=p.y-1 end
  if btnp(pad.down) then p.y=p.y+1 end
  p.x=p.x%25
  p.y=p.y%25
  local tile=room[p.y+1][p.x+1]
  if tile==0 then
    p.col=7
    p.valid=true
  else
   p.col=8
   p.valid=false
  end
  if btnp(pad.btn2) then level+=1 storeroom(level) end
  if btnp(pad.btn1) then level-=1 storeroom(level) end
  path=pathfinder:find(p,f)
 end,
 draw=function(self)
  --sspr(0,0,128,128,0,0)
  sspr(0,100,25,25,2,2,125,125)
  rect(p.x*5+1,p.y*5+1,p.x*5+7,p.y*5+7,p.col)
  rect(f.x*5+1,f.y*5+1,f.x*5+7,f.y*5+7,12)
  print(p.x..","..p.y,7)

  for _,v in pairs(path) do
   pset(v.x*5+4,v.y*5+4,15)
  end
  print(#path,0,10,8)

  local range=minsky(p.x,p.y,p.r)
  local mask={}
  for y,xs in pairs(range) do
   for x=xs.x1,xs.x2 do
    local tx=x*5+4
    local ty=y*5+4
    local px=p.x*5+4
    local py=p.y*5+4
    local cx,cy
    if los(px,py,tx,ty,function(x,y)
     cx,cy=get_cell(x,y)
     local tile=get_tile(cx,cy)
     return tile~=2
    end
    ) then
     local cell=vec2:create(cx,cy)
     local idx=cell:index()
     mask[idx]=cell
    end
   end
  end

  if p.valid then
   for k,v in pairs(mask) do
    --pset(v.x*5+4,v.y*5+4,10)
    rect(v.x*5+3,v.y*5+3,v.x*5+5,v.y*5+5,2)
    pset(v.x+100,v.y,10)
   end
  end

 end
}

stage_outro={
 init=function(self)
 end,
 update=function(self)
  if btnp(4) then
   stages:update(stage_intro)
  end
 end,
 draw=function(self)
  print("outro",0,0,7)
 end
}
