function mintsky(x,y,r)
 local circs={
  {1},
  {1,3},
  {1,3,5},
  {3,5,7,7},
  {3,7,7,9,9},
  {5,7,9,11,11,11}
 }
 local cell={}
 local circ=circs[r]
 local o=0
 for row=#circ,1,-1 do
  --local width=cc[row]
  local radius=math.floor(circ[row]/2)
  cell[y-o]={x1=math.max(0,x-radius),x2=math.min(24,x+radius)}
  cell[y+o]=cell[y-o]
  o=o+1
 end
 return cell
end

function mintsky_old(x,y,r)
 local c={
  {1},
  {1,3},
  {1,3,5},
  {3,5,7,7},
  {3,7,7,9,9},
  {5,7,9,11,11,11}
 }
 local cell={}
 local cc=c[r]

 j=1
 for cy=y-#cc+1,y do
  local width=cc[j]
  local r=math.floor(width/2)
  cell[cy]={}
  for cx=x-r,x+r do
   cell[cy][cx]=1
  end
  j=j+1
 end

 j=#cc-1
 for cy=y+1,y+#cc-1 do
  local width=cc[j]
  local r=math.floor(width/2)
  cell[cy]={}
  for cx=x-r,x+r do
   cell[cy][cx]=1
  end
  j=j-1
 end
 
 --[[
 for y,c in pairs(cell) do
  for x,_ in pairs(c) do print(x.." => "..y) end
 end
 ]]

local ret={}
for y,c in pairs(cell) do
 ret[y]={}
 for x,_ in pairs(c) do
  table.insert(ret[y],x)
 end
end

return ret

end

d=mintsky(5,5,4)
for y,c in pairs(d) do
 print(c.x1.."-"..c.x2..", "..y)
end


d=mintsky_old(5,5,4)
for y,c in pairs(d) do
 for _,x in pairs(c) do
  print(x..","..y)
 end
end