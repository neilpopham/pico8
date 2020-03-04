diff_dir={{0,-1},{1,0},{0,1},{-1,0}}
lost_doors = {
 {0,0,0,0,{},0,0,0,0},
 {0,{3},0,{2},0,{4},0,{1},0},
 0,
 {{2,3},0,{3,4},0,0,0,{1,2},0,{1,4}},
 0,
 0,
 0,
 0,
 {{2,3},{2,3,4},{3,4},{1,2,3},{1,2,3,4},{1,3,4},{1,2},{1,2,4},{1,4}}
}
roomtl={
 {0,0,0,0,{0,0},0,0,0,0},
 {0,{0,0},0,{0,0},0,{1,0},0,{0,1},0},
 0,
 {{0,0},0,{1,0},0,0,0,{0,1},0,{1,1}},
 0,
 0,
 0,
 0,
 {{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}},
}
--[[
idx={
 {5},
 {{2,8},{4,6}},
 0,
 {1,3,7,9},
 0,
 0,
 0,
 0,
 {1,2,3,4,5,6,7,8,9}
}
]]

function array_diff(a1,a2)
 local t={}
 for k,v in pairs(a1) do t[k]=v end
 for _,v in pairs(a2) do
  del(t,v)
 end
 return t
end

function sizeof(t)
 local i=0
 for k,_ in pairs(t) do i=i+1 end
 return i
end

function get_opposite_direction(dir)
 local opposite=dir+2
 if opposite>4 then opposite=opposite-4 end
 return opposite
end

function get_index(x,y)
 return x+2+((y+1)*3)
end

function get_types(x,y)
 local types={}
 for ty=-1,1 do
  for tx=-1,1 do
   local i=get_index(tx,ty)
   if cells[x+tx] and cells[x+tx][y+ty] and cells[x+tx][y+ty].group==1 then
    add(types,i)
   end
  end
 end
 return types
end

function generate()
 --local r=flr(rnd(32767)) -- #########################################################
 --printh("srand: "..r) -- ##################################################
 --srand(r) -- ##############################################################
 count=0
 total=mrnd({20,30})
 cells={}
 --room={}
 local x,y=100,100
 makeroom(x,y,3)
 -- convert array to start from 1,1
 local mx,my=500,500
 for x,rows in pairs(cells) do
  if x<mx then mx=x end
  for y,cell in pairs(rows) do
   if y<my then my=y end
  end
 end
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
 -- create larger rooms
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   local types=get_types(x,y)
   -- 3x3
   if #types==9 and rnd()>0.3 then
    for ty=-1,1 do
     for tx=-1,1 do
      local i=get_index(tx,ty)
      cells[x+tx][y+ty].type=i
      cells[x+tx][y+ty].group=9
      cells[x+tx][y+ty].room=cells[x][y].room
     end
    end
   end
  end
 end
 -- 2x2
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   local types=get_types(x,y)
   if cell.group==1 and #types>3 then
    local offset={0,1,3,4}
    local diff={{-1,-1},{0,-1},{1,-1},{-1,0},{0,0},{1,0},{-1,1},{0,1},{1,1}}
    for k,o in pairs(offset) do
     local sq={
      {i=1+o,c=1,x=x+diff[1+o][1],y=y+diff[1+o][2]},
      {i=2+o,c=3,x=x+diff[2+o][1],y=y+diff[2+o][2]},
      {i=4+o,c=7,x=x+diff[4+o][1],y=y+diff[4+o][2]},
      {i=5+o,c=9,x=x+diff[5+o][1],y=y+diff[5+o][2]},
     }
     local valid=true
     for _,v in pairs(sq) do
      local cellcol=cells[v.x]
      if cellcol and cellcol[v.y] and cellcol[v.y].group==1 and in_array(types,v.i) then
      else
       valid=false
      end
     end
     if valid and rnd()>0.4 then
      for _,v in pairs(sq) do
       cells[v.x][v.y].group=4
       cells[v.x][v.y].type=v.c
       cells[v.x][v.y].room=cells[x][y].room
      end
     end
    end
   end
  end
 end
 -- 1x2 and 2x1
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   local types=get_types(x,y)
   if cell.group==1 and #types>1 then
    local index={2,6,8,4}
    local duos={}
    for k,i in pairs(index) do
     local o=diff_dir[k]
     if in_array(types,i) and cells[x+o[1]][y+o[2]].group==1 then
      add(duos,k)
     end
    end
    if #duos>0 and rnd()>0.5 then
     local si=duos[mrnd({1,#duos})]
     local o=diff_dir[si]
     cell.group=2
     cell.type=10-index[si]
     cells[x+o[1]][y+o[2]].group=2
     cells[x+o[1]][y+o[2]].type=index[si]
     cells[x+o[1]][y+o[2]].room=cell.room
    end
   end
  end
 end
 -- post-processing
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   -- remove doors with no walls (due to cell merging)
   for i,d in pairs(lost_doors[cell.group][cell.type]) do
    cell.doors[d]=nil
   end
   -- turn some doors into secret doors
   if cell.group==1 and rnd()>0.5 then
    if sizeof(cell.doors)==1 then
     for k,_ in pairs(cell.doors) do
      cells[x+diff_dir[k][1]][y+diff_dir[k][2]].doors[get_opposite_direction(k)]=2
      --cell.doors[k]=2 -- no, but leave for now
      cell.secret=true
     end
    end
   end
   -- create room array
   -- if room[cell.room]==nil then room[cell.room]={} end
   -- room[cell.room][cell.type]=cell
  end
 end
end

function makeroom(x,y,exit)
 if cells[x]==nil then cells[x]={} end
 -- if this room has already been created then just make sure we have an exit
 if cells[x][y]~=nil then
  cells[x][y].doors[get_opposite_direction(exit)]=1
  return
 end
 -- attempt to restrict the number of rooms generated
 if count>total*2 then
  cells[x-diff_dir[exit][1]][y-diff_dir[exit][2]].doors[exit]=nil
  return
 end
 -- initiate room
 cells[x][y]={doors={},type=5,group=1,room=count+1,srand=rnd()}
 -- initiate locals
 local exits=count<total and mrnd({count<(total/3) and 2 or 1,4}) or 1
 count=count+1
 local doors,directions,door_map={},{1,2,3,4},{nil,1,nil,4,nil,2,nil,3,nil}
 -- if adjacent rooms exist create doors to link to them
 for ty=-1,1 do
  for tx=-1,1 do
   local i=get_index(tx,ty)
   if door_map[i] then
    local opposite=door_map[i] and get_opposite_direction(door_map[i]) or 0
    if cells[x+tx] and cells[x+tx][y+ty] and cells[x+tx][y+ty].doors[opposite] then
     add(doors,door_map[i])
    end
   end
  end
 end
 -- remove these from our pool
 for _,a in pairs(doors) do
  for _,b in pairs(directions) do
   if a==b then del(directions,a) end
  end
 end
 -- randomly select doors from our random pool
 for i=#doors+1,exits do
  add(doors,del(directions,directions[mrnd({1,#directions})]))
 end
 -- set door array in global cells variable
 cells[x][y].doors={}
 for _,v in pairs(doors) do
  cells[x][y].doors[v]=1
 end
 -- make rooms for all our doors, use local doors var as it's more randomly sorted
 for _,k in pairs(doors) do
  makeroom(x+diff_dir[k][1],y+diff_dir[k][2],k)
 end
end

function maproom(x,y)
 printh("maproom("..x..","..y..")")
 dumptable(cells[x][y])
 -- clear the whole map
 memset(0x2000,0,0x1000)

 local cell=cells[x][y]
 local o=roomtl[cell.group][cell.type]
 local tlx,tly=x-o[1],y-o[2]
 local alldoors={1,2,3,4}

 if cell.group==1 then
  printh("draw single cell")
  mapfloor(0,0)
  mapwalls(0,0,alldoors)
  mapdoors(0,0,cells[tlx][tly].doors)
 elseif cell.group==2 then
  if in_array({2,8},cell.type) then
   printh("draw vertical 2 cell room")
   for dy=0,1 do
    --local cx,cy=tlx,tly+dy
    --local c=cells[cx][cy]
    local c=cells[tlx][tly+dy]
    local walls=array_diff(alldoors,lost_doors[c.group][c.type])
    local mx,my=0,dy*10
    mapfloor(mx,my)
    mapwalls(mx,my,walls)
    mapdoors(mx,my,c.doors)
   end
  else
   printh("draw horizontal 2 cell room")
   for dx=0,1 do
    --local cx,cy=tlx+dx,tly
    --local c=cells[cx][cy]
    local c=cells[lx+dx][tly]
    local walls=array_diff(alldoors,lost_doors[c.group][c.type])
    local mx,my=dx*10,0
    mapfloor(mx,my)
    mapwalls(mx,my,walls)
    mapdoors(mx,my,c.doors)
   end
  end
 elseif cell.group==4 then
  printh("draw 4 cell room")
  for dy=0,1 do
   for dx=0,1 do
    --local cx,cy=tlx+dx,tly+dy
    --local c=cells[cx][cy]
    local c=cells[tlx+dx][tly+dy]
    local walls=array_diff(alldoors,lost_doors[c.group][c.type])
    local mx,my=dx*10,dy*10
    mapfloor(mx,my)
    mapwalls(mx,my,walls)
    mapdoors(mx,my,c.doors)
   end
  end
 else
  printh("draw 9 cell room")
  for dy=0,2 do
   for dx=0,2 do
    --local cx,cy=tlx+dx,tly+dy
    --local c=cells[cx][cy]
    local c=cells[tlx+dx][tly+dy]
    local walls=array_diff(alldoors,lost_doors[c.group][c.type])
    local mx,my=dx*10,dy*10
    mapfloor(mx,my)
    mapwalls(mx,my,walls)
    mapdoors(mx,my,c.doors)
   end
  end
 end

end

function mapfloor(tx,ty)
 for x=0,13 do
  for y=0,13 do
   mset(tx+x,ty+y,1)
  end
 end
end

function mapwalls(tx,ty,walls)
 for _,w in pairs(walls) do
  if w==1 then
   for x=0,13 do
    mset(tx+x,ty+0,2)
    mset(tx+x,ty+1,2)
   end
  elseif w==2 then
   for y=0,13 do
    mset(tx+12,ty+y,2)
    mset(tx+13,ty+y,2)
   end
  elseif w==3 then
   for x=0,13 do
    mset(tx+x,ty+12,2)
    mset(tx+x,ty+13,2)
   end
  elseif w==4 then
   for y=0,13 do
    mset(tx+0,ty+y,2)
    mset(tx+1,ty+y,2)
   end
  end
 end
end

function mapdoors(tx,ty,doors)
 for d,_ in pairs(doors) do
  if d==1 then
   mset(tx+6,ty+0,1)
   mset(tx+7,ty+0,1)
   mset(tx+6,ty+1,1)
   mset(tx+7,ty+1,1)
  elseif d==2 then
   mset(tx+12,ty+6,1)
   mset(tx+13,ty+6,1)
   mset(tx+12,ty+7,1)
   mset(tx+13,ty+7,1)
  elseif d==3 then
   mset(tx+6,ty+12,1)
   mset(tx+7,ty+12,1)
   mset(tx+6,ty+13,1)
   mset(tx+7,ty+13,1)
  elseif d==4 then
   mset(tx+0,ty+6,1)
   mset(tx+0,ty+7,1)
   mset(tx+1,ty+6,1)
   mset(tx+1,ty+7,1)
  end
 end
end

function dumptable(t,l)
 l=l or 0
 local p=""
 for i=0,l do
  p=p.."  "
 end
 local i=0
 for k,v in pairs(t) do
  i+=1
  if type(v)=="table" then
   printh(p..k.. " => (table)")
   dumptable(v,l+1)
  else
   local t=type(v)
   if v==nil then v="nil" end
   if type(v)=="boolean" then v=v and "true" or "false" end
   printh(p..k.. " => "..v.." ("..t..")")
  end
 end
 if i==0 then printh(p.."(empty)") end
end

function _init()
 printh("==================")
 generate()
 --dumptable(cells)
 --dumptable(room)

 rx,ry=1,0

 for x,a in pairs(cells) do
  for y,c in pairs(a) do
   if c.group==9 and ry==0 then rx=x ry=y end
  end
 end
 if ry==0 then
  for y,c in pairs(cells[1]) do
   ry=y
  end
 end
 printh("rx,ry: "..rx..","..ry)
 assert(cells[rx]~=nil, "cells[rx] does not exist")
 assert(cells[rx][ry]~=nil, "cells[rx][ry] does not exist")
 --[[
 rx,ry=1,0
 for k,v in pairs(cells[1]) do
  ry=k
 end
 ]]




 p={room={x=rx,y=ry},x=32,y=32}
 maproom(p.room.x,p.room.y)
 --cstore(0x2000,0x2000,0x1000)
 cstore(0x1000,0x1000,0x2000)
 map_x=0
 map_y=0
end

function _update60()
 if btn(0) then map_x-=1 end
 if btn(1) then map_x+=1 end
 if btn(2) then map_y-=1 end
 if btn(3) then map_y+=1 end
end

function _draw()
 cls(0)
 map(map_x,map_y)
end

--[[

drawing rooms

from cell x,y we need to work out what cells we need to draw
the group will be used
if we store these in another array what would we need to store?





]]
