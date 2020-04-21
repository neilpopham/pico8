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
 init=function(self)
  level=1
  storeroom(level)
  p=vec2:create(0,11)
  p.col=7
  p.r=4
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
  if tile==0 then p.col=7 else p.col=8 end
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
  --local path=pathfinder:find(p,f)
  for _,v in pairs(path) do
   pset(v.x*5+4,v.y*5+4,15)
   --rect(v.x*5+2,v.y*5+2,v.x*5+5,v.y*5+5,15)
  end
  print(#path,0,10,8)

  range=minsky(p.x,p.y,p.r)
  dumptable(range)
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

  for k,v in pairs(mask) do
   --pset(v.x*5+4,v.y*5+4,10)
   rect(v.x*5+3,v.y*5+3,v.x*5+5,v.y*5+5,2)
   pset(v.x+100,v.y,10)
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
