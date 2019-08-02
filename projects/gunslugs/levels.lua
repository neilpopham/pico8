function fillmap(level)
 local data,levels,floors,m={},{15,11,7},120

 -- init
 for x=0,127 do
  data[x]={}
  data[x][15]=1
 end
 -- init

 -- floors
 for x=0,127 do
  if x>7 and x<120 then
   if x%4==0 then
    if rnd()<0.5 then
     for i=x,x+3 do
      if not data[i] then data[i]={} end
      data[i][levels[2]]=1
     end
     floors+=4
    end
    if data[x-3][levels[2]]==1 then
     if rnd()<0.5 then
      for i=x,x+3 do
       if not data[i] then data[i]={} end
       data[i][levels[3]]=1
      end
      floors+=4
     end
    end
   end
  end
 end
 -- floors

 -- destructables
 local pool={}
 local green_barrels=4+2*level
 for i=1,green_barrels do
  add(pool,4)
 end
 local red_barrels=12+2*level
 for i=1,red_barrels do
  add(pool,3)
 end
 local count=#pool+1
 local max=70+level*2
 if count<max then -- fill up with crates
  for i=count,max do
   add(pool,2)
  end
 end
 for x=7,124 do
  local pcount=#pool
  local l1=2/3*pcount/floors
  local l2=1/3*pcount/floors
  for i,l in pairs(levels) do
   if data[x][l]==1 then
    local m=l1
    if data[x-1][l-1] then m*=1.5 end
    if rnd()<m and #pool>0 then
     local d=del(pool,pool[mrnd{1,#pool}])
     data[x][l-1]=d
     if rnd()<l2 and #pool>0 then
      d=del(pool,pool[mrnd{1,#pool}])
      data[x][l-2]=d
     end
    end
    floors-=1
   end
  end
 end
 -- destructables

 -- enemies
 local pool={}
 local cautious=1+level
 for i=1,cautious do
  add(pool,2)
 end
 local spider=1+level
 for i=1,spider do
  add(pool,3)
 end
 local count=#pool+1
 local max=5+level
 if count<max then -- fill up with grunts
  for i=count,max do
   add(pool,1)
  end
 end
 -- enemies

local e=0
 for x=0,127 do

   --enemies [48]
   if x>31 and x%8==0 then

    --enemies [48]
    for i,l in pairs(levels) do
     if data[x] and data[x][l]==1 then
      if rnd()<0.9/i then
       local p=l
       repeat
        p-=1
       until data[x][p]==nil
       data[x][p]=48
      end
     end
    end
    --enemies [48]

    --medikit [40]
    if x%16==0 then
     for i,l in pairs(levels) do
      if data[x] and data[x][l]==1 then
       if rnd()<0.25 then
        data[x][l-3]=40
        break
       end
      end
     end
    end
    --medikit

   end

  -- bricks
  if x>0 then
   for y=2,9 do
    if not data[x][y] or (data[x][y]>=9 and data[x][y]<=13) then
     r=rnd()
     m=0.5/y
     if data[x][y-1] and data[x][y-1]>=9 and data[x][y-1]<=14 then m=0.8/y end
     if data[x-1][y] and data[x-1][y]>=9 and data[x-1][y]<=13 then m=1.4/y end
     if r<m then
      data[x][y]=13
      r=rnd()
      if r<0.2 then data[x][y]=mrnd({9,13}) end
      if not data[x-1][y] then data[x-1][y]=9 end
      if x<127 and not data[x+1] then
       data[x+1]={}
       if not data[x+1][y] then data[x+1][y]=10 end
      end
      if not data[x][y-1] then data[x][y-1]=11 end
      if not data[x][y+1] then data[x][y+1]=12 end
     end
    end
   end
  end
  -- bricks

 end

 -- create map from data
 for x=0,127 do
  for y=0,15 do
   if not data[x][y] then data[x][y]=0 end
   if data[x][y]>=2 and data[x][y]<=4 then
    destructables:add(destructable:create(x*8,y*8,data[x][y]))
   elseif data[x][y]==48 then
    -- this will need changing
    -- types used should depend on level
    -- see TODO for methodology
    local type=mrnd({1,3})
    enemies:add(enemy:create(x*8,y*8,type))
   elseif data[x][y]==40 then
    pickups:add(medikit:create(x*8,y*8))
   else
    mset(x,y,data[x][y])
   end
  end
 end

end
