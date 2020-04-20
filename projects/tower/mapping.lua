function decompress()
 local collection,room,row={},{},{}
 local mx,my=0,0
 local s=mget(mx,my)
 while s>0 do
  local t=band(s,7)  -- last 3 bytes used to store tile number (0-7)
  local c=shr(s-t,3) --- first 5 bytes used to store count (1-31)
  for i=1,c do add(row,t) end
  if #row==25 then
   add(room,row)
   row={}
   if #room==25 then
    add(collection,room)
    room={}
   end
  end
  mx+=1
  if mx==128 then mx=0 my+=1 end
  s=mget(mx,my)
 end
 return collection
end

function storeroom(level)
 local cols={3,4,11,12,9,10}
 for y=1,25 do
  for x=1,25 do
   sset(x-1,y+99,cols[rooms[level][y][x]+1])
  end
 end
 room=rooms[level]
end
