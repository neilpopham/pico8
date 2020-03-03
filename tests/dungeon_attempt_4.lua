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
 local r=flr(rnd(32767)) -- #########################################################
 printh("srand: "..r) -- ##################################################
 srand(r) -- ##############################################################
 count=0
 total=mrnd({20,30})
 cells={}
 room={}
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
   if room[cell.room]==nil then room[cell.room]={} end
   --add(room[cell.room],cell)
   room[cell.room][cell.type]=cell
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

function drawcells()
 pal(1,128,1)
 local s=7
 local os=flr(s/2)
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do

   pset(os+x*s,os+y*s,7)

   function drawline(s,x,y,index,col)
    if index==2 then line(x*s,y*s,s-1+x*s,y*s,col) end
    if index==6 then line(s-1+x*s,y*s,s-1+x*s,s-1+y*s,col) end
    if index==8 then line(x*s,s-1+y*s,s-1+x*s,s-1+y*s,col) end
    if index==4 then line(x*s,y*s,x*s,s-1+y*s,col) end
   end

   if cell.group==1 then
    rect(x*s,y*s,s-1+x*s,s-1+y*s,6)
   elseif cell.group==2 then
    rect(x*s,y*s,s-1+x*s,s-1+y*s,cell.group)
    if cell.type==2 then line(1+x*s,s-1+y*s,s-2+x*s,s-1+y*s,1) end
    if cell.type==6 then line(x*s,1+y*s,x*s,s-2+y*s,1) end
    if cell.type==8 then line(1+x*s,y*s,s-2+x*s,y*s,1) end
    if cell.type==4 then line(s-1+x*s,1+y*s,s-1+x*s,s-2+y*s,1) end
   elseif cell.group==4 then
    rect(x*s,y*s,s-1+x*s,s-1+y*s,1)
    if cell.type==1 then drawline(s,x,y,2,cell.group) drawline(s,x,y,4,cell.group) end
    if cell.type==3 then drawline(s,x,y,2,cell.group) drawline(s,x,y,6,cell.group) end
    if cell.type==7 then drawline(s,x,y,4,cell.group) drawline(s,x,y,8,cell.group) end
    if cell.type==9 then drawline(s,x,y,6,cell.group) drawline(s,x,y,8,cell.group) end
   elseif cell.group==9 then
    rect(x*s,y*s,s-1+x*s,s-1+y*s,1)
    if cell.type==1 then drawline(s,x,y,2,cell.group) drawline(s,x,y,4,cell.group) end
    if cell.type==2 then drawline(s,x,y,2,cell.group) end
    if cell.type==3 then drawline(s,x,y,2,cell.group) drawline(s,x,y,6,cell.group) end
    if cell.type==4 then drawline(s,x,y,4,cell.group) end
    if cell.type==6 then drawline(s,x,y,6,cell.group) end
    if cell.type==7 then drawline(s,x,y,4,cell.group) drawline(s,x,y,8,cell.group) end
    if cell.type==8 then drawline(s,x,y,8,cell.group) end
    if cell.type==9 then drawline(s,x,y,6,cell.group) drawline(s,x,y,8,cell.group) end
   else
    asert(false,cell.group)
   end

   for d,dt in pairs(cell.doors) do
    local dc,di=0,3
    if dt==2 then dc=8 di=8 end
    if d==1 then pset(os+x*s,y*s,dc) pset(os+x*s,os-1+y*s,di) end
    if d==2 then pset(s-1+x*s,os+y*s,dc) pset(os+1+x*s,os+y*s,di) end
    if d==3 then pset(os+x*s,s-1+y*s,dc) pset(os+x*s,os+1+y*s,di) end
    if d==4 then pset(x*s,os+y*s,dc) pset(os-1+x*s,os+y*s,di) end
   end
   --print(cell.type,x*s,y*s,15)
  end
 end
end

function drawroom(x,y)
 local offset={44,nil,nil,24,nil,nil,nil,nil,4}
 local cell=cells[x][y]
 local o=offset[cell.group]
 if cell.group==2 and (cell.type==2 or cell.type==8) then o=offset[1] end
 srand(cell.srand)

end

function maproom(x,y)
 printh("maproom("..x..","..y..")")
 -- clear the map
 for y=0,15 do
  for x=0,15 do
   mset(0,0,0)
  end
 end
 local cell=cells[x][y]
 printh(" type:"..cell.type)
 --local o=roomtl[cell.group][cell.type]
 --local tl=cells[x+o[1]][y+o[2]]

 local id=idx[cell.group]
 if cell.group==2 then
  if in_array({2,8},cell.type) then id=id[1] else id=id[2] end
 end
 dumptable(id)
 for _,i in pairs(id) do
  local o=roomtl[cell.group][i]
  printh("i:"..i)
  drawcell(x-o[1],y-o[2])
 end


 --[[
 for k,v in pairs(roomtl[cell.group]) do
  if type(v)=="table" then
   drawcell(v[1],v[2])
  end
 end
 ]]
end

function drawcell(x,y)
 printh("drawcell: "..x..","..y)
 local cell=cells[x][y]
 printh("drawcell: "..x..","..y.." "..cell.type)
 rectfill(x*8,y*8,x*8+6,y*8+6,2)
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

function getroom(x,y)
 local cell=cells[x][y]
 local o=roomtl[cell.group][cell.type]
-- local tl=cells[x+o[1]][y+o[2]]

end

function _init()
 printh("==================")
 generate()
 dumptable(cells)
 dumptable(room)

 rx=1
 for k,v in pairs(cells[1]) do
  ry=k
 end

 p={room={x=rx,y=ry},x=32,y=32}
 maproom(p.room.x,p.room.y)
end

function _update60()

end

function _draw()
 cls(0)
 maproom(p.room.x,p.room.y)
end

--[[

drawing rooms

from cell x,y we need to work out what cells we need to draw
the group will be used
if we store these in another array what would we need to store?





]]
