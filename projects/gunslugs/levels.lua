function fillmap(level)

 local levels,r,m={15,11,7}

 for x=0,127 do

  if not data[x] then data[x]={} end
  data[x][15]=1

  if x>7 then

   -- levels [1]
   if x%4==0 then
    r=rnd()
    m=0.5
    if r<m then
     for i=x,x+3 do
      if not data[i] then data[i]={} end
      data[i][levels[2]]=1
     end
    end
    if data[x-3][levels[2]]==1 then
     r=rnd()
     m=0.5
     if r<m then
      for i=x,x+3 do
       if not data[i] then data[i]={} end
       data[i][levels[3]]=1
      end
     end
    end
   end
   -- levels

   -- crates [2]
   for i,l in pairs(levels) do
    if data[x][l] and data[x][l]==1 then
     r=rnd()
     m=data[x][l-1]==2 and 0.75/i or 0.25/i
     if r<m then
      data[x][l-1]=2
      r=rnd()
      m=data[x][l-2]==2 and 0.6/i or 0.2/i
      if r<m then
       data[x][l-2]=2
      end
     end
    end
   end
   -- crates

   -- barrels
   local k={
    nil,
    {0.6,0.2,0.4,0.1},
    {0.4,0.1,0.2,0.05},
    {0.2,0.05,0.1,0.02}
   }
   for i,l in pairs(levels) do
    if data[x][l]==1 then
     for n=0,1 do
      for j=2,4 do
       if not data[x][l-1-n] and data[x][l-n] then
        r=rnd()
        m=data[x][l-1-n]==j and k[j][1+n*2]/i or k[j][2+n*2]/i
        if (x<16) printh("m:"..m.." r:"..r)
        if r<m then
         data[x][l-1-n]=j
         if (x<16) printh("j:"..j.." x:"..x.." y:"..(l-1-n))
        end
       end
      end
     end
    end
   end
   -- barrels

   --enemies [48]
   if x>31 and x%8==0 then
    for i,l in pairs(levels) do
     if data[x] and data[x][l]==1 then
      r=rnd()
      m=0.9/i
      if r<m then
       local p=l
       repeat
        p-=1
       until data[x][p]==nil
       data[x][p]=48
      end
     end
    end
   end
   --enemies

   --medikit [40]
   if x>31 and x%16==0 then
    for i,l in pairs(levels) do
     if data[x] and data[x][l]==1 then
      r=rnd()
      m=0.25
      if r<m then
       data[x][l-3]=40
       break
      end
     end
    end
   end
   --medikit

  end

  -- ropes
  --[[
  if x%4==0 then
   r=rnd()
   if r<0.25 then
    r=mrnd({1,5})
    for i=0,r do data[x][i]=14 end
    data[x][r]=15
   end
  end
  ]]
  -- ropes

  -- bricks
  ---[[
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
      if x<127 and not data[x+1] then data[x+1]={} end
      if not data[x-1][y] then data[x-1][y]=9 end
      if data[x+1] and not data[x+1][y] then data[x+1][y]=10 end
      if not data[x][y-1] then data[x][y-1]=11 end
      if not data[x][y+1] then data[x][y+1]=12 end
     end
    end
   end
  end
  --]]
  -- bricks

 end

 for x=0,127 do
  for y=0,15 do
   if not data[x][y] then data[x][y]=0 end
   if data[x][y]==2 then
    destructables:add(destructable:create(x*8,y*8,2))
   elseif data[x][y]==3 then
    destructables:add(destructable:create(x*8,y*8,3))
   elseif data[x][y]==4 then
    destructables:add(destructable:create(x*8,y*8,4))
   elseif data[x][y]==48 then
    local r=rnd()
    local type=r<0.25 and 2 or 1
    enemies:add(enemy:create(x*8,y*8,type))
   elseif data[x][y]==40 then
    pickups:add(medikit:create(x*8,y*8))
   else
    mset(x,y,data[x][y])
   end
  end
 end

end
