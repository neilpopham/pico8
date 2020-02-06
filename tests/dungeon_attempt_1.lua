room={
 index=1,
 create=function(self,o)
  o=o or {}
  o.index=room.index
  room.index=room.index+1
  o.x=5+mrnd({0,8})
  o.y=5+mrnd({0,8})
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 foo=function(self)
  return "foo "..self.x
 end,
 bar=function(self)
  return "bar"
 end
}

function get_opposite_direction(dir)
 local opposite=dir+2
 if opposite>4 then opposite=opposite-4 end
 return opposite
end

room_index=0
area=0

function makeroom(exit,parent)
 room_index=room_index+1
 local x=5+2*mrnd({0,4})
 local y=5+2*mrnd({0,4})
 x,y=5,5
 local total_doors
 if area<1000 then
  total_doors=mrnd({area<70 and 2 or 1,4})
 else
  total_doors=1
 end
 assert(area<3000,"area too big")
 area=area+x*y
 printh("area:"..area)
 --printh(area)
 --printh("total_doors:"..total_doors)
 -- start door array with an entrance to match the exit
 local doors={get_opposite_direction(exit)}
 -- while we need to add more doors
 while #doors<total_doors do
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
  --for i,v in pairs(doors) do
   --printh(#doors.." existing "..i..":"..v)
  --end
  --for i,v in pairs(directions) do
   --printh(#doors.." option "..i..":"..v)
  --end
  -- pick a direction from our remaining pot
  add(doors,directions[mrnd({1,#directions})])
 end
 local d={}--{32727,32727,32727,32727}
 for i,v in pairs(doors) do
  --printh("doors"..i..":"..v)
  d[v]=0
 end
 if parent then
  d[get_opposite_direction(exit)]=parent.index
 end
 return {
  index=room_index,
  width=x,
  height=y,
  doors=d,
  corridor=((total_doors>1) and (mrnd{1,10})<4)
 }
end

function makechildren(room)
 for i,d in pairs(room.doors) do
  if d==nil then
   printh("no door")
  elseif d>0 then
   printh("room already created")
   if rooms[d].doors[get_opposite_direction(i)]==nil then
    printh("no matching door")
   end

   rooms[d].doors[get_opposite_direction(i)]=room.index
  else
   local r=makeroom(i,room)
   room.doors[i]=r.index
   debugroom(r)
   rooms[r.index]=r -- add(rooms,r)
   makechildren(r)
  end
 end
end

function debugroom(room)
 printh("index:"..room.index)
 --printh("width:"..room.width)
 --printh("height:"..room.height)
 printh(room.width.." x "..room.height)
 printh("corridor:"..(room.corridor and "yes" or "no"))
 --printh(room.doors[1]..","..room.doors[2]..","..room.doors[3]..","..room.doors[4])
 for i=1,4 do
  printh(room.doors[i])
 end
end

function in_array(a,i)
 for k,v in pairs(a) do
  if v==i then return true end
 end
 return false
end

drawn={}

function drawroom(x,y,room)
 printh(x..","..y)

 if pget(x,y) > 0 then printh("room cell already used") end

 rect(
  x-ceil(room.width/2),
  y-ceil(room.height/2),
  x+ceil(room.width/2),
  y+ceil(room.height/2),
  room.index%8+8
 )
 pset(x,y,7)

 add(drawn,room.index)
 for k,v in pairs(room.doors) do
  if in_array(drawn,v)==false then
   if k==1 then
    drawroom(x,y-ceil(room.height/2)-ceil(rooms[v].height/2)-1,rooms[v])
   end
   if k==2 then
    drawroom(x+ceil(room.width/2)+ceil(rooms[v].width/2)+1,y,rooms[v])
   end
   if k==3 then
    drawroom(x,y+ceil(room.height/2)+ceil(rooms[v].height/2)+1,rooms[v])
   end
   if k==4 then
    drawroom(x-ceil(room.width/2)-ceil(rooms[v].width/2)-1,y,rooms[v])
   end
  end
  if k==1 then
   pset(x,y-ceil(room.height/2),1)
   pset(x,y-1,2)
  end
  if k==2 then
   pset(x+ceil(room.width/2),y,1)
   pset(x+1,y,2)
  end
  if k==3 then
   pset(x,y+ceil(room.height/2),1)
   pset(x,y+1,2)
  end
  if k==4 then
   pset(x-ceil(room.width/2),y,1)
   pset(x-1,y,2)
  end
 end
end

function _init()
 cls()
 printh("==================")
 rooms={}
 local r=makeroom(3,nil)
 rooms[r.index]=r -- add(rooms,r)

 debugroom(r)

 makechildren(r)

 printh("count:"..#rooms)

 for r,room in pairs(rooms) do
  for d,door in pairs(room.doors) do
   local o=get_opposite_direction(d)
   if door then
    local child=rooms[door]
    if child.doors[o]==nil then printh("no matching door") end
   end
  end
 end

 drawroom(64,64,rooms[1])

end

function _update60()

end

function _draw()

end
