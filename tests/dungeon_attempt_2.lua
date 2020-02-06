local diff={{0,-1},{1,0},{0,1},{-1,0}}
local index={2,6,8,4}
local oindex={8,4,2,6}

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
 count=0
 total=mrnd({20,30})
 cells={}
 local x,y=100,100

 -- start the room-making process
 makeroom(x,y,3)

 -- convert array to start from 1,1
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

 -- create larger rooms
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   local types=get_types(x,y)
   --if #types==9 and rnd()>0.3 then
   if #types==9 then
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
 --2x2
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   local types=get_types(x,y)
   if cell.group==1 and #types>3 then
    local offset={0,1,3,4}
    local diff={{-1,-1},{0,-1},{1,-1},{-1,0},{0,0},{1,0},{-1,1},{0,1},{1,1}}
    for k,o in pairs(offset) do
     local tl,tr,bl,br=1+o,2+o,4+o,5+o
     local ctl=cells[x+diff[tl][1]][y+diff[tl][2]]
     local ctr=cells[x+diff[tr][1]][y+diff[tr][2]]
     local cbl=cells[x+diff[bl][1]][y+diff[bl][2]]
     local cbr=cells[x+diff[br][1]][y+diff[br][2]]
     if in_array(types,tl) and ctl.group==1
      and in_array(types,tr) and ctr.group==1
      and in_array(types,bl) and cbl.group==1
      and in_array(types,br) and cbr.group==1 then
      ctl.group=4
      ctr.group=4
      cbl.group=4
      cbr.group=4
      ctl.type=1
      ctr.type=3
      cbl.type=7
      cbr.type=9
     end
    end

   end
  end
 end
 -- 1x2
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   local types=get_types(x,y)
   if cell.group==1 and #types>1 then
    local diff={{0,-1},{1,0},{0,1},{-1,0}}
    local index={2,6,8,4}
    local oindex={8,4,2,6}
    local twoer={}
    for k,i in pairs(index) do
     local o=diff[k]
     if in_array(types,i) and cells[x+o[1]][y+o[2]].group==1 then
      add(twoer,k)
     end
    end
    --if #twoer>0 and rnd()>0.7 then
    if #twoer>0 then
     local si=twoer[mrnd({1,#twoer})]
     local o=diff[si]
     cell.group=2
     cell.type=oindex[si]
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

function makeroom(x,y,exit)
 printh("---")

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
 local types={}
 local door_map={nil,1,nil,4,nil,2,nil,3,nil}
 local diff_map={}
 for ty=-1,1 do
  for tx=-1,1 do
   add(diff_map,{tx,ty})
  end
 end

 for ty=-1,1 do
  for tx=-1,1 do
   local i=get_index(tx,ty)
   --local d=get_opposite_direction(door_map[i])
   local opposite=door_map[i] and get_opposite_direction(door_map[i]) or 0
   printh(tx..","..ty..":"..i..":"..(door_map[i] and door_map[i] or 0)..":"..opposite)
   if cells[x+tx] and cells[x+tx][y+ty] then
    add(types,i)
    if door_map[i] and cells[x+tx][y+ty].doors[opposite] then
     add(doors,door_map[i])
    end
   end
   --[[
   if cells[x+tx] and cells[x+tx][y+ty] and cells[x+tx][y+ty].doors[opposite] then
    if door_map[i] then
     add(doors,door_map[i])
     add(types,i)
    end
   end
   ]]
  end
 end

 printh("doors:"..#doors)
 printh("types:"..#types)

 local s=""
 for _,v in pairs(types) do
  s=s..v.."|"
 end
 printh(s)

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

 ---[[
 for k,v in pairs(doors) do
  printh(k..":"..v)
 end
 --]]

 --assert(false,"exit")

 cells[x][y].doors={}
 for _,v in pairs(doors) do
  cells[x][y].doors[v]=1
 end

 local diff={{0,-1},{1,0},{0,1},{-1,0}}
 for k,_ in pairs(cells[x][y].doors) do
  makeroom(x+diff[k][1],y+diff[k][2],k)
 end

end

function drawcells()
 pal(1,128,1)
 local s=7
 local os=flr(s/2)
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   --printh(x..","..y)
   pset(os+x*s,os+y*s,7)


   --rect(x*s,y*s,s-1+x*s,s-1+y*s,cell.group)


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
    --if cell.type==5 then drawline(s,x,y,2,cell.group) drawline(s,x,y,4,cell.group) end
    if cell.type==6 then drawline(s,x,y,6,cell.group) end
    if cell.type==7 then drawline(s,x,y,4,cell.group) drawline(s,x,y,8,cell.group) end
    if cell.type==8 then drawline(s,x,y,8,cell.group) end
    if cell.type==9 then drawline(s,x,y,6,cell.group) drawline(s,x,y,8,cell.group) end
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
 cls(0)
 printh("==================")
 generate()
 drawcells()
end

function _update60()

end

function _draw()

end
