astar={
 create=function(self,x,y,g,h,parent)
  local o=vec2:create(x,y)
  o.f=g+h
  o.g=g
  o.h=h
  o.parent=parent
  return o
 end
} setmetatable(astar,{__index=vec2})

pathfinder={
 find=function(self,start,finish)
  self.open={}
  self.closed={}
  self.path={}
  self.start=start
  self.finish=finish
  self.open[start:index()]=astar:create(start.x,start.y,0,start:distance(finish))
  if self:_check_open() then
   return self.path
  end
 end,
 _check_open=function(self)
  local current=self:_get_next()
  if current==nil then
   return false
  else
   local idx=current:index()
   if idx==self.finish:index() then
    local t={}
    local cell=current
    while cell.parent do
     add(t,vec2:create(cell.x,cell.y))
     cell=cell.parent
    end
    for i=#t,1,-1 do
     add(self.path,t[i])
    end
    return true
   end
   self.closed[idx]=current
   self:_add_neighbours(current)
   self.open[idx]=nil
   self:_check_open()
   return true
  end
 end,
 _get_next=function(self)
  local best={0,32727}
  for i,vec in pairs(self.open) do
   if vec.f<best[2] then
    best={i,vec.f}
   end
  end
  return best[1]==0 and nil or self.open[best[1]]
 end,
 _add_neighbour=function(self,current,cell)
  local idx=cell:index()
  if cell.x<0 or cell.x>24 or cell.y<0 or cell.y>24 then return end
  local tile=room[cell.y+1][cell.x+1]
  --if cell.x==11 and cell.y==11 then printh("10,11:"..tile) end
  if tile==1 or tile==5 or tile==6 then
   local exists=false
   local g=current.g+1
   if type(self.closed[idx])=="table" then
    exists=true
   elseif type(self.open[idx])=="table" then
    if g<self.open[idx].g then
     self.open[idx].g=g
     self.open[idx].f=self.open[idx].g+self.open[idx].h
     self.open[idx].parent=current
    end
    exists=true
   end
   if not exists then
    self.open[idx]=astar:create(cell.x,cell.y,g,cell:distance(self.finish),current)
   end
  end
 end,
 _add_neighbours=function(self,current)
  local offset={{0,-1},{1,0},{0,1},{-1,0}}
  for _,o in pairs(offset) do
   local cell=vec2:create(current.x+o[1],current.y+o[2])
   self:_add_neighbour(current,cell)
  end
 end
}

--[[
s=vec2:create(2,2)
f=vec2:create(12,6)
local path=pathfinder:find(s,f)
]]
