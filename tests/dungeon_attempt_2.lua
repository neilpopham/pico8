function get_opposite_direction(dir)
 local opposite=dir+2
 if opposite>4 then opposite=opposite-4 end
 return opposite
end

function generate()
 count=0
 total=mrnd({10,15})
 cells={}
 local x,y=100,100
 makeroom(x,y,3)

 local mx,my=500,500
 for x,rows in pairs(cells) do
  if x<mx then mx=x end
  for y,cell in pairs(rows) do
   if y<my then my=y end
  end
 end

 printh(mx.." and "..my)

 local data={}
 for x,rows in pairs(cells) do
  local ox=x-mx+1
  if data[ox]==nil then data[ox]={} end
  for y,cell in pairs(rows) do
   local oy=y-my+1
   data[ox][oy]=cell
  end
 end
 cells=data
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   printh(x.."|"..y)
  end
 end
end

function makeroom(x,y,exit)

 --[[

 1 2 3    5    2    4 6
 4 5 6         8
 7 8 9

 ]]

 if cells[x]==nil then cells[x]={} end

 if cells[x][y]==nil then
  cells[x][y]={doors={},type=5,group=1}
 else
  printh(x..","..y.." already exists")
  cells[x][y].doors[get_opposite_direction(exit)]=1
  return
 end

 printh(count.."/"..total)

 local exits=count<total and mrnd({count<(total/2) and 2 or 1,4}) or 1
 count=count+1
 printh("exits:"..exits)
 local doors={}

 ---[[
 local types={5}

 local dc={nil,1,nil,4,nil,2,nil,3,nil}

 for tx=-1,1 do
  for ty=-1,1 do
   local i=tx+2+((ty+1)*3)
   --local d=get_opposite_direction(dc[i])
   local d=dc[i] and get_opposite_direction(dc[i]) or 0
   printh(tx..","..ty..":"..i..":"..(dc[i] and dc[i] or 0)..":"..d)
   if cells[x+tx] and cells[x+tx][y+ty] and cells[x+tx][y+ty].doors[d] then
    if dc[i] then printh("adding "..dc[i]) add(doors,dc[i]) end
   end
  end
 end
 --]]



 --[[
 if cells[x][y-1] and cells[x][y-1].doors[3] then
  add(doors,1)
  add(types,2)
 end
 if cells[x][y+1] and cells[x][y+1].doors[1] then
  add(doors,3)
  add(types,8)
 end
 if cells[x-1] and cells[x-1][y] and cells[x-1][y].doors[2] then
  add(doors,4)
  add(types,4)
 end
 if cells[x+1] and cells[x+1][y] and cells[x+1][y].doors[4] then
  add(doors,2)
  add(types,6)
 end
--]]

 printh("doors:"..#doors)

 while #doors<exits do
  -- start off with a 1/4 chance of picking a direction
  local directions={1,2,3,4}
  -- add another chance to create an opposing door
  for _,v in pairs(doors) do
   add(directions,get_opposite_direction(v))
  end
  -- remove any directions we already have
  for _,a in pairs(doors) do
   for _,b in pairs(directions) do
    if a==b then del(directions,a) end
   end
  end
  -- pick a direction from our remaining pot
  add(doors,directions[mrnd({1,#directions})])
 end

 for k,v in pairs(doors) do
  printh(k..":"..v)
 end

 --assert(false,"exit")

 cells[x][y].doors={}
 for _,v in pairs(doors) do
  cells[x][y].doors[v]=1
 end

 for k,_ in pairs(cells[x][y].doors) do
  if k==1 then makeroom(x,y-1,1) end
  if k==2 then makeroom(x+1,y,2) end
  if k==3 then makeroom(x,y+1,3) end
  if k==4 then makeroom(x-1,y,4) end
 end

end

function drawcells()

 --[[
 rectfill(64,64,70,70,1)

 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   --printh(x..","..y)
   local lx,ly=x-100,y-100
   local rc=9 --7+y%4+x%4
   pset(67+lx*7,67+ly*7,7)
   rect(64+lx*7,64+ly*7,70+lx*7,70+ly*7,rc)
   for d,_ in pairs(cell.doors) do
    local dc,di=0,3
    if d==1 then pset(67+lx*7,64+ly*7,dc) pset(67+lx*7,66+ly*7,di) end
    if d==2 then pset(70+lx*7,67+ly*7,dc) pset(68+lx*7,67+ly*7,di) end
    if d==3 then pset(67+lx*7,70+ly*7,dc) pset(67+lx*7,68+ly*7,di) end
    if d==4 then pset(64+lx*7,67+ly*7,dc) pset(66+lx*7,67+ly*7,di) end
    --printh(" "..d)
   end
  end
 end
 ]]

 local s=7
 local os=flr(s/2)
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   --printh(x..","..y)

   pset(os+x*s,os+y*s,7)
   rect(x*s,y*s,s-1+x*s,s-1+y*s,9)
   for d,_ in pairs(cell.doors) do
    local dc,di=0,3
    if d==1 then pset(os+x*s,y*s,dc) pset(os+x*s,os-1+y*s,di) end
    if d==2 then pset(s-1+x*s,os+y*s,dc) pset(os+1+x*s,os+y*s,di) end
    if d==3 then pset(os+x*s,s-1+y*s,dc) pset(os+x*s,os+1+y*s,di) end
    if d==4 then pset(x*s,os+y*s,dc) pset(os-1+x*s,os+y*s,di) end
   end

   --[[
   local lx,ly=x-100,y-100
   local rc=9 --7+y%4+x%4
   pset(67+lx*7,67+ly*7,7)
   rect(64+lx*7,64+ly*7,70+lx*7,70+ly*7,rc)
   for d,_ in pairs(cell.doors) do
    local dc,di=0,3
    if d==1 then pset(67+lx*7,64+ly*7,dc) pset(67+lx*7,66+ly*7,di) end
    if d==2 then pset(70+lx*7,67+ly*7,dc) pset(68+lx*7,67+ly*7,di) end
    if d==3 then pset(67+lx*7,70+ly*7,dc) pset(67+lx*7,68+ly*7,di) end
    if d==4 then pset(64+lx*7,67+ly*7,dc) pset(66+lx*7,67+ly*7,di) end
    --printh(" "..d)
   end
   ]]
  end
 end

end

function _init()
 cls(0)
 printh("==================")
 generate()
 drawcells()


end


function _update60()

end

function _draw()

end
