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
 init=function(self)
  level=2
  storeroom(level)
 end,
 update=function(self)
  self.changed=false
  if btnp(pad.btn2) then
   self.ui=not self.ui
   self.changed=true
  end
  if self.ui then
   if self.changed then

   end
  else
   if self.changed then

   end
  end
 end,
 draw=function(self)
  sspr(0,100,25,25,2,2,125,125)
  if self.ui then

   --rectfill(1,0,127,23,1)
   --rect(1,0,127,23,7)
   --line(2,24,126,24,0)

   rectfill(1,107,127,127,1)
   rect(1,107,127,127,7)
   line(2,106,126,106,0)

   rectfill(4,110,8,114,9)
   print("05C", 12,110,12)
   rect(3,109,9,115,7)

   rectfill(4,120,8,124,8)
   print("10C", 12,120,12)
   --rect(3,119,9,125,7)


  else

  end
 end
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
  --if btnp(pad.btn1) then dumptable(path) end
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
