local mapdata={
 data={},
 decompress=function(self)
  local total,level=0,{}
  for y=0,31 do
   for x=0,127 do
    local raw=mget(x,y)
    local sprite=raw%16
    local count=(raw-sprite)/16
    if count==0 then count=16 end
    add(level,{count,sprite})
    total+=count
    if total==256 then
     add(self.data,level)
     total,level=0,{}
    end
   end
  end
 end,
 load=function(self,level)
  local t=0
  for _,block in pairs(self.data[level]) do
   for i=1,block[1] do
    mset(t%16,flr(t/16),block[2])
    t+=1
   end
  end
 end
}
