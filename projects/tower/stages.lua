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
  local cx,cy=get_cell(12,12)
  print(cx..","..cy,0,10,7)
  local cx,cy=get_cell(2,2)
  print(cx..","..cy,0,20,7)
  local cx,cy=get_cell(8,8)
  print(cx..","..cy,0,30,7)

 end
}

stage_main={
 init=function(self)
  level=1
  storeroom(level)
  p=vec2:create(0,11)
  p.col=7
  p.r=2
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
  mask={}
  for y,xs in pairs(range) do
   --rect(xs.x1*5+2,y*5+2,xs.x2*5+6,y*5+6,1)
   for x=xs.x1,xs.x2 do
    local tile=room[y+1][x+1]
    local tx=x*5+4
    local ty=y*5+4
    pset(tx,ty,13)
    --printh("tx,ty:"..tx..","..ty)
    local px=p.x*5+4
    local py=p.y*5+4
    --printh("px,py:"..px..","..py)
    local dx=px-tx
    local dy=ty-py
    local angle=atan2(dx,dy)
    --printh(dx..","..dy.." "..angle)
    --line(px,py,px+cos(angle)*20,py-sin(angle)*20,7)

    for i=1,20 do
     dx=cos(angle)*i
     dy=-sin(angle)*i

     pset(px+dx,py+dy,7)

     --local cx,cy=get_cell(px+dx,py+dy)
     --local tile=room[cy+1][cx+1]

    end



    --[[
    local xstep=dx<0 and -0.5 or 0.5
    local ystep=dy<0 and -0.5 or 0.5
    local v=true
    for sy=py,ty,ystep do
     for sx=px,tx,xstep do
      cx,cy=get_cell(sx,sy)
      local tile=room[cy+1][cx+1]
      local cell=vec2:create(cx,cy)
      local idx=cell:index()
      if mask[idx] then

      else
       if v==false or tile==2 then
        --v=false
       else
        mask[idx]=cell
       end
      end
     end
    end
    ]]


    --[[
    if tile==2 then
     if (x<p.x and y<p.y) or (x>p.x and y>p.y) then
      local a1=atan2((p.x*5+4)+(x*5+2),(y*5+7)-(p.y*5+2))
      local a2=atan2((p.x*5+4)+(x*5+7),(y*5+2)-(p.y*5+2))
     else
      local a1=atan2((p.x*5+4)+(x*5+2),(y*5+2)-(p.y*5+2))
      local a2=atan2((p.x*5+4)+(x*5+7),(y*5+7)-(p.y*5+2))
     end
     printh("a1: "..a1.." a2: "..a2)
    else
     local cell=vec2:create(x,y)
     local idx=cell:index()
     mask[idx]=cell
    end
    ]]


    --[[
    if room[y+1][x+1]==0 then
     add(mask,vec2:create(x,y))
    end
    ]]

   end
  end

  for k,v in pairs(mask) do
   pset(v.x*5+4,v.y*5+4,10)
   pset(v.x+100,v.y,10)
  end
  --]]

--[[
  for a=0,0.99999,0.01 do
   dx=cos(a)*p.r*3.93
   dy=-sin(a)*p.r*3.93
   pset(p.x*5+4+dx,p.y*5+4+dy,9)
  end
]]

--[[
  mask={}
  if room[p.y+1][p.x+1]==0 then
   local i,j=0,0
   for a=0,0.99999,0.01 do
    local r=0.25
    while r<p.r*3.93 do
     i+=1
     dx=cos(a)*r
     dy=-sin(a)*r
     cx,cy=get_cell(p.x*5+4+dx,p.y*5+4+dy)
     if cx==nil then
      r=100
     else
      local tile=room[cy+1][cx+1]
      if tile~=2 then
       local cell=vec2:create(cx-1,cy-1)
       local idx=cell:index()
       if mask[idx] then j+=1 end
       mask[cell:index()]=cell
      else
       r=100
      end
     end
     r+=0.5
    end
   end
  end
  printh(i)
  printh(j)
  for k,v in pairs(mask) do
   --pset(v.x*5+4,v.y*5+4,14)
   --pset(v.x+100,v.y,7)
   if v.x==p.x and v.y==p.y then
   else
    rect(v.x*5+2,v.y*5+2,v.x*5+6,v.y*5+6,9)
   end
  end
]]

  print(room[p.y+1][p.x+1],50,0,9)

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
