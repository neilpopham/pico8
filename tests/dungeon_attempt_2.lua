local diff_dir={{0,-1},{1,0},{0,1},{-1,0}}
--local diff_index={{-1,-1},{0,-1},{1,-1},{-1,0},{0,0},{1,0},{-1,1},{0,1},{1,1}}
--[[
local diff_map={}
for ty=-1,1 do
 for tx=-1,1 do
  add(diff_map,{x=tx,y=ty})
 end
end
]]

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
 -- initiate
 count=0
 total=mrnd({5,10})
 cells={}
 local x,y=100,100
 -- start the room-making process
 makeroom(x,y,3)



 -- debugging issue with door to nowhere sometimes
 function dump(dx,dy,dd)
  printh("##################DUMP############")
  printh(dx)
  printh(dy)
  printh(dd)
  for x,rows in pairs(cells) do
   for y,cell in pairs(rows) do
    --printh(x..", "..y)
    local s=""
    for d,_ in pairs(cell.doors) do
     s=s..d.." "
    end
    printh(x..", "..y.." doors:"..s)
   end
  end
  printh("##############END DUMP############")

 end
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   for d,_ in pairs(cell.doors) do

    if d==1 and cells[x][y-1]==nil then
     dump(x,y,d)
    end
    if d==2 and cells[x+1][y]==nil then
     dump(x,y,d)
    end
    if d==3 and cells[x][y+1]==nil then
     dump(x,y,d)
    end
    if d==4 and cells[x-1][y]==nil then
     dump(x,y,d)
    end
    ---[[
    if d==1 then assert(cells[x][y-1],x..","..y..":"..d) end
    if d==2 then assert(cells[x+1][y],x..","..y..":"..d) end
    if d==3 then assert(cells[x][y+1],x..","..y..":"..d) end
    if d==4 then assert(cells[x-1][y],x..","..y..":"..d) end
    --]]
   end
  end
 end



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
    end
   end
  end
 end

 --[[
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   printh(x.."|"..y)
  end
 end
 --]]

end

--[[

1 2 3    5    2    4 6    1 3
4 5 6         8           7 9
7 8 9

]]


function makeroom(x,y,exit)
 printh("--- makeroom -- "..x..", "..y.." "..exit)

 if cells[x]==nil then cells[x]={} end

 if cells[x][y]==nil then
  cells[x][y]={doors={},type=5,group=1}
  --cells[x][y].doors[get_opposite_direction(exit)]=1
 else
  cells[x][y].doors[get_opposite_direction(exit)]=1
  return
 end

 printh(count.."/"..total)

 local exits=count<total and mrnd({count<(total/2) and 2 or 1,4}) or 1
 count=count+1
 printh("exits:"..exits)
 local doors={}
 local directions={1,2,3,4}

 ---[[
 local door_map={nil,1,nil,4,nil,2,nil,3,nil}
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

 for _,a in pairs(doors) do
  for _,b in pairs(directions) do
   if a==b then del(directions,a) end
  end
 end
 --]]

 for i=#doors,exits do
  add(doors,del(directions,mrnd({1,#directions})))
 end

 if false then
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
 end

 cells[x][y].doors={}
 for _,v in pairs(doors) do
  cells[x][y].doors[v]=1
 end

 local s="" for _,v in pairs(doors) do s=s..v.." " end printh("doors: "..s)

 for k,_ in pairs(cells[x][y].doors) do
  if x==100 and y==100 then
   printh("makeroom("..(x+diff_dir[k][1])..","..(y+diff_dir[k][2])..","..k..")")
  end
  makeroom(x+diff_dir[k][1],y+diff_dir[k][2],k)
 end

 return

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

   for d,_ in pairs(cell.doors) do
    local dc,di=0,3
    if d==1 then pset(os+x*s,y*s,dc) pset(os+x*s,os-1+y*s,di) end
    if d==2 then pset(s-1+x*s,os+y*s,dc) pset(os+1+x*s,os+y*s,di) end
    if d==3 then pset(os+x*s,s-1+y*s,dc) pset(os+x*s,os+1+y*s,di) end
    if d==4 then pset(x*s,os+y*s,dc) pset(os-1+x*s,os+y*s,di) end
   end
   --print(cell.type,x*s,y*s,15)
  end
 end
end

function _init()
 printh("==================")
 max=10
 t=max
end

function _update60()
 if t==max then
  t=0
  printh("-- generating --------------------------------------")
  generate()
 end
 t=t+1
end

function _draw()
 cls(0)
 drawcells()
end
