pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- roguelike
-- by neil popham

screen={width=128,height=128,x2=127,y2=127}
canvas={width=64,height=32,x2=63,y2=31}
spritemap={width=128,height=64,x2=127,y2=63}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
ap={move90=4,move45=6,turn=1}

--screen={width=240,height=136,x2=239,y2=135}
--canvas={width=64,height=32,x2=63,y2=31}
--pad={left=2,right=3,up=0,down=1,btn1=4,btn2=5,btn3=6,btn4=7}

dir={left=1,right=2,up=3,down=4}

vec2={
 create=function(self,x,y)
  local o={x=x,y=y}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 distance=function(self,cell)
  local dx=cell.x-self.x
  local dy=cell.y-self.y
  return sqrt(dx^2+dy^2)
 end,
 manhattan=function(self,cell)
  return abs(cell.x-self.x)+abs(cell.y-self.y)
 end,
 index=function(self)
  return self.y*canvas.width+self.x
 end
}

tile={
 create=function(self,x,y)
  local o=vec2.create(self,x,y)
  o.px=vec2:create(o.x*16+8,o.y*16+8)
  return o
 end,
 from_px=function(self,x,y)
  return self:create(flr((x-8)/16),flr((y-8)/16))
 end,
 diff=function(self,cell)
  local dx=cell.px.x-self.px.x
  local dy=cell.px.y-self.px.y
  return vec2:create(dx,dy)
 end,
 mget=function(self)
  return mget(self.x*2,self.y*2)
 end,
 fget=function(self,flag)
  return fget(self:mget(),flag)
 end
} setmetatable(tile,{__index=vec2})

astar={
 create=function(self,x,y,g,h,parent)
  local o=vec2.create(self,x,y)
  o.f=g+h
  o.g=g
  o.h=h
  o.parent=parent
  return o
 end
} setmetatable(astar,{__index=vec2})

pathfinder={
 find=function(self,start,finish,max)
  max=max or 32727
  self.open={}
  self.closed={}
  self.path={}
  self.start=start
  self.finish=finish
  self.max=max
  add(self.open,astar:create(start.x,start.y,0,start:distance(finish)))
  if self:_check_open() then
   return self.path
  end
 end,
 _check_open=function(self)
  local current=self:_get_next()
  if current==nil then
   return false
  else
   if current.x==self.finish.x and current.y==self.finish.y then
    local t={}
    local cell=current
    while cell.parent do
     add(t,vec2:create(cell.x,cell.y))
     cell=cell.parent
    end
    --add(t,vec2:create(cell.x,cell.y))
    for i=#t,1,-1 do
     add(self.path,t[i])
    end
    return true
   end
   add(self.closed,current)
   self:_add_neighbours(current)
   del(self.open,current)
   self:_check_open()
   return true
  end
 end,
 _get_next=function(self)
  local best={0,32727}
  for i,vec in pairs(self.open) do
   if vec.f<best[2] and vec.g<self.max then
    best={i,vec.f}
   end
  end
  return best[1]==0 and nil or self.open[best[1]]
 end,
 _add_neighbour=function(self,current,x,y)
  local cell=vec2:create(current.x+x,current.y+y)
  if type(cells[cell:index()])=="table" then
   local exists=false
   --local g=current.g+(x*y==0 and ap.move90 or ap.move45)
   local g=current.g+(x*y==0 and 1 or 1.5)
   --local g=current.g+sqrt(x^2+y^2)
   for _,closed in pairs(self.closed) do
    if closed.x==cell.x and closed.y==cell.y then
     exists=true
     break
    end
   end
   if not exists then
    for _,open in pairs(self.open) do
     if open.x==cell.x and open.y==cell.y then
      if g<open.g then
       open.g=g
       open.f=open.g+open.h
       open.parent=current
      end
      exists=true
      break
     end
    end
   end
   if not exists then
    add(
     self.open,
     astar:create(cell.x,cell.y,g,cell:distance(self.finish),current)
    )
   end
  end
 end,
 _add_neighbours=function(self,current)
  for x=-1,1 do
   for y=-1,1 do
    if not (x==0 and y==0) then
     self:_add_neighbour(current,x,y)
    end
   end
  end
 end
}

cells={}

function create_cells_slow()
 printh("===")
 map()
 local t1=time()
 for y=0,spritemap.y2,2 do
  for x=0,spritemap.x2,2 do
   local sprite=mget(x,y)
   if not fget(sprite,0) then
    local tile=tile:create(x/2,y/2)
    cells[tile:index()]={tile=tile,visibility={}}
   end
  end
 end
 for i,cell in pairs(cells) do
  local closed={}
  for idx=1,8 do cell.visibility[idx]=0 end
  for x=-4,4 do
   for y=-4,4 do
    if not (x==0 and y==0) then
     local c2=tile:create(cell.tile.x+x,cell.tile.y+y)
     local j=c2:index()
     local blocked=false
     local diff=cell.tile:diff(c2)
     local angle=atan2(diff.x,-diff.y)
     local ai=flr(angle/0.125)+1
     local distance=sqrt(diff.x^2+diff.y^2)
     local dd=8
     local d=dd
     repeat
      local x=cell.tile.px.x+cos(angle)*d
      local y=cell.tile.px.y-sin(angle)*d
      pset(x,y,i%14+1) -- ##################
      local c3=tile:from_px(x,y)
      local idx=c3:index()
      if cells[idx]==nil then
       blocked=true
      end
      closed[idx]=true
      if not blocked then
       cell.visibility[ai]=cell.visibility[ai]+1
      end
      d=d+dd
     until c3.x<0 or c3.x>canvas.x2 or c3.y<0 or c3.y>canvas.y2
    end
   end
  end
 end
 printh("total:"..#cells)
 printh("memory:"..stat(0)) -- 576.4297 (29% of available)
 printh(time()-t1)
end

function create_cells()
 printh("===")
 map()
 local t1=time()
 for y=0,spritemap.y2,2 do
  for x=0,spritemap.x2,2 do
   local sprite=mget(x,y)
   if not fget(sprite,0) then
    local tile=tile:create(x/2,y/2)
    cells[tile:index()]={tile=tile,visibility={}}
   end
  end
 end
 for i,cell in pairs(cells) do
  for idx=1,8 do cell.visibility[idx]=0 end
  for x=-8,8 do
   for y=-8,8 do
    if not (x==0 and y==0) then
     local c2=tile:create(cell.tile.x+x,cell.tile.y+y)
     local j=c2:index()
     if cells[j]~=nil then
      local blocked=false
      local diff=cell.tile:diff(c2)
      local angle=atan2(diff.x,-diff.y)
      local distance=sqrt(diff.x^2+diff.y^2)
      local dd=4
      local d=dd
      while d<distance do
       local x=cell.tile.px.x+cos(angle)*d
       local y=cell.tile.px.y-sin(angle)*d
       pset(x,y,i%15) -- ###################################
       local sprite=mget(flr(x/8),flr(y/8))
       if fget(sprite,0) then
        blocked=true
        break
       end
       d=d+dd
      end
      if not blocked then
       local idx=flr(angle/0.125)+1
       cell.visibility[idx]=cell.visibility[idx]+1
      end
     end
    end
   end
  end
  --break
 end
--[[
 for x=0,canvas.x2 do
  for y=0,canvas.y2 do
   local i=y*canvas.width+x
   if not cells[i]==nil then
    printh("here")
    for key,value in pairs(cells[i].visibility) do
     s=s..key.."="..value.." "
    en
    printh(i..":"..
   en
  end
 end
]]
 printh("total:"..#cells)
 printh("memory:"..stat(0)) -- 576.4297 (29% of available)
 printh(time()-t1)

--[[
 for i,cell in pairs(cells) do
  local s=""
  for v=1,8 do
   if cell.visibility[v]==nil then
    s=s.."0,"
   else
    s=s..cell.visibility[v]..","
   end
  end
  printh("visibility["..i.."]={"..s.."}")
 end
]]

end

function create_cells_old()

 -- create an array of floor tiles
 for y=0,spritemap.y2 do
  for x=0,spritemap.x2 do
   local sprite=mget(x,y)
   if not fget(sprite,0) then
    local tile=tile:create(x/2,y/2)
    cells[tile:index()]={tile=tile,visibility={}}
   end
  end
 end

 -- loop through each tile and record the visibily of all other tiles
 for i,cell1 in pairs(cells) do
  --printh(i..":"..cell1.tile.x..","..cell1.tile.y)
  for j,cell2 in pairs(cells) do

   if i~=j then

    local blocked=false
    local diff=cell1.tile:diff(cell2.tile)
    local angle=atan2(diff.x,-diff.y)
    local distance=sqrt(diff.x^2+diff.y^2)

    local idx=flr(((angle+0.5)%1)/0.125)+1
    if cells[j].visibility[idx]==nil or cells[j].visibility[idx][i]==nil then
     local d=10
     while d<distance do
      local x=cell1.tile.px.x+cos(angle)*d
      local y=cell1.tile.px.y-sin(angle)*d
      --line(cell1.tile.px.x,cell1.tile.px.y,x,y,i%15) -- ###################################
      pset(x,y,i%15) -- ###################################
      local sprite=mget(flr(x/8),flr(y/8))
      if fget(sprite,0) then
       blocked=true
       break
      end
      d=d+10
     end

     if not blocked then
      local idx=flr(angle/0.125)+1
      if cell1.visibility[idx]==nil then cell1.visibility[idx]={} end
      cell1.visibility[idx][j]=cell2.tile
     end
    else
     printh("we know this one")
     if cell1.visibility[idx]==nil then cell1.visibility[idx]={} end
     cell1.visibility[idx][j]=cell2.tile
    end

   end

  end
  break -- ###############
 end
 printh("done")
end

function _init()
 cls()
 create_cells_orig()
end

function _update()

end

function _draw()

end




--[[

laser squad

weapon  accuracy
        clip size
        damage

shield
        front/back/side
        strength

terrain
        more ap to go over rough ground (make cost according to tile type)

starting tiles
        when game starts can only place on certain tiles


overlay to show tiles you can move to and still be on watch
        to show tiles you can move to

use a* for ai to get to an objective quickly
others may not use a* but prefer to stick to rooms/corners*
some ai stay on watch, others don't
differing bravery/stupidity
*   look for furthest they can go without ending in plain site
    maybe check further ahead - if they have a long corridor wait around corner first and then go for it after.
    (stay in corridor as short as possible)
    need to analyse each square to see how visible it is by how many squares and from what angles
    if stood in a doorway in vertical corridor would only be visible by three cells (above,opposite,below) etc.
    exclude cells visible by peers
    count peers as solid blocking cell
    maybe calculate and store visibility data for each cell at game start
        and add in data from peers etc in realtime
            draw line from centre of cell to every other cell.
            draw point along line and check cell underneath that point for visibility
            start from cell being checked outward. only check cells that are floor (or doors?).
            calculate score using number of visible cells and range of directions
                maybe distance? distance could negate use of direction.

    what about doors that can open?
    stupid bots would get seen first and can communicate position of user.
    bots hold map of user positions and can a* accordingly
    can avoid or approach
    bots could guard other bots by staying in front and on guard (ants work? nah...)


    visibilty of bot for each direction (how much they can see)
        can see 90 degree angle (45 each side of facing)
        n can see nw,n,ne - ne can see n,ne,e - etc
    cost of moving to a square taking into consideration turning as well as moving
        "how much to move here and be facing this way?" (turn, move, turn)

    functions to deal with tile->px and px->tile conversion

    tile={
        create=function(self,x,y)
            local o={x=x,y=y}
            setmetatable(o,self)
            self.__index=self
            return o
        end,
        pixels=function(self)
            return vec2:create(self.x*8+4,self.y*8+4)
        end,
        diff=function(self,cell)
            local c1=self:pixels()
            local c2=cell:pixels()
            local dx=c2.x-c1.x
            local dy=c2.y-c1.y
            return vec2:create(dx,dy)
        end
    }


cell={
    create=function(self,x,y)
        local o=vec2:create(x,y)
        o.px=self:pixels()
        return o
    end,
    pixels=function(self)
        return vec2:create(self.x*8+4,self.y*8+4)
    end,
    diff=function(self,c2)
        local dx=c2.px.x-self.px.x
        local dy=c2.px.y-self.px.y
        return vec2:create(dx,dy)
    end
} setmetatable(cell,{__index=vec2})


    local pos=mytile:pixels()
    printh(pos.x..","..pos.y)



    tiles={}


    c1.tx=c1.x*8+4
    c1.ty=c1.y*8+4
    c2.tx=c2.x*8+4
    c2.ty=c2.y*8+4

    local dx=c2.tx-c1.tx
    local dy=c2.ty-c1.ty

    local a=atan2(dx,-dy)
    local px,py=c1.tx,c1.ty
    while px<c2.tx or py<c2.ty do
        px=px+=cos(a)*4
        py=py-sin(a)*4
        local tx=flr(px/8)
        local ty=flr(py/8)
        local tile=mget(tx,ty)
        if fget(tile,0) then
            local found=false
            for k,v in pairs(tiles) do
                if v.x==tx and v.y==ty then
                    found=true
                    break
                end
            end
            if not found then
                add(tiles,vec2:create(tx,ty))
            end
        end
    end




1.  analyse map for floor/door (standable) tiles, and store in array
2.  for each cell in the array check its visibility against every other cell in the array
    probably just treat doors like floor (rather than store alternative data, too many permutations)
3. store a score for that cell based on the number of cells that can see it and from how many directions

]]



__gfx__
66666666222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000101000000000101010101010000010101010101000000000101010101010000010101010101000000000101000000000000000000000000000000000
00001010000000001010000000000000000000001010000000001010000000000000101000000000000000001010000000000000101000000000101000000000
00000000101000000000101010101010000010101010101000000000101010101010000010101010101000000000101000000000000000000000000000000000
00001010000000001010000000000000000000001010000000001010000000000000101000000000000000001010000000000000101000000000101000000000
00000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000101010100000101010100000000000000000
00001010000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000101000000000
00000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000101010100000101010100000000000000000
00001010000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000101000000000
00000000101000000000000000000000000000000000101000000000000000000000000000000000101000000000101000000000000010100000000000000000
00001010000000001010000000000000000000001010000000001010000000000000101000000000000000001010000000000000101000000000101000000000
00000000101000000000000000000000000000000000101000000000000000000000000000000000101000000000101000000000000010100000000000000000
00001010000000001010000000000000000000001010000000001010000000000000101000000000000000001010000000000000101000000000101000000000
00000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000101000000000000010100000000000000000
00001010000000001010000000000000000000001010000000001010000000000000101000000000000000001010000000000000101000000000101000000000
00000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000101000000000000010100000000000000000
00001010000000001010000000000000000000001010000000001010000000000000101000000000000000001010000000000000101000000000101000000000
00000000101000000000101010101010101010101010101000000000101010101010101010101010101000000000101010101010101010101010101000001010
10101010000000001010101010101010101010101010000000001010101010101010101010101010101010101010101010101010101000000000101000000000
00000000101000000000101010101010101010101010101000000000101010101010101010101010101000000000101010101010101010101010101000001010
10101010000000001010101010101010101010101010000000001010101010101010101010101010101010101010101010101010101000000000101000000000
00000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000
00001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000
00000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000
00001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000
00000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000
00001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000
00000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000
00001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000
00000000101010101010101000001010101010101010101000001010101010100000000010101010101000001010101010100000000010100000000000000000
00001010000000001010101010100000101010101010000000001010101010101010000010101010101010101010101010100000101010101010101000000000
00000000101010101010101000001010101010101010101000001010101010100000000010101010101000001010101010100000000010100000000000000000
00001010000000001010101010100000101010101010000000001010101010101010000010101010101010101010101010100000101010101010101000000000
00000000101000000000000000000000000010100000000000000000000010100000000010100000000000000000000010100000000010100000000000000000
00001010000000001010000000000000000000001010000000001010000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000010100000000000000000000010100000000010100000000000000000000010100000000010100000000000000000
00001010000000001010000000000000000000001010000000001010000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000010100000000000000000000010100000000010100000000000000000000010100000000010100000000000000000
00001010000000001010000000000000000000001010000000001010000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000010100000000000000000000010100000000010100000000000000000000010100000000010100000000000000000
00001010000000001010000000000000000000001010000000001010000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000000000000000000000000000010100000000010101010101010101010101010100000000010101010101000001010
10101010000000001010101010101010101010101010000000000000000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000000000000000000000000000010100000000010101010101010101010101010100000000010101010101000001010
10101010000000001010101010101010101010101010000000000000000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000010100000000000000000000010100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000010100000000000000000000010100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000010100000000000000000000010100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000
00000000101000000000000000000000000010100000000000000000000010100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000
00000000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000
00000000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000
0000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000
0000000001010000000000000000000001010000000000000000000000000000010100000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000101000000000000010100000000000000000000010100000000
0000000001010000000000000000000001010000000000000000000000000000010100000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000101000000000000010100000000000000000000010100000000
0000000001010000000000000000000001010000000000000000000000000000010100000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000101000000000000010100000000000000000000010100000000
0000000001010000000000000000000001010000000000000000000000000000010100000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000101000000000000010100000000000000000000010100000000
0000000001010000000000000000000001010000000000000000000000000000010100000000000001010000000001010101010101010101010101010000010101010101000000000101010101010101010101010101000000000101000000000000000000000101000000000000010100000000000000000000010100000000
0000000001010000000000000000000001010000000000000000000000000000010100000000000001010000000001010101010101010101010101010000010101010101000000000101010101010101010101010101000000000101000000000000000000000101000000000000010100000000000000000000010100000000
0000000001010000000000000000000001010000000000000000000000000000010100000000000001010000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000000010101010101000001010101010100000000
0000000001010000000000000000000001010000000000000000000000000000010100000000000001010000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000000010101010101000001010101010100000000
0000000001010101010100000101010101010101010101010000010101010101010101010000010101010000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000000000000000000000000000000000000000000000000000010100000000
0000000001010101010100000101010101010101010101010000010101010101010101010000010101010000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000000000000000000000000000000000000000000000000000010100000000
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000101000000000000000000000000000000000101000000000101000000000000000000000101000000000000000000000000000000000000010100000000
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000101000000000000000000000000000000000101000000000101000000000000000000000101000000000000000000000000000000000000010100000000
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000000000000000000000000000000010100000000
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000000000000000000000000000000010100000000
0000000001010000000001010101010100000101010101010000000001010101010101010101010101010000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000000000000000000000000000000010100000000
0000000001010000000001010101010100000101010101010000000001010101010101010101010101010000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000000000000101000000000000000000000000000000000000010100000000
0000000001010000000001010000000000000000000001010000000001010000000000000000000001010000000001010000000000000000000000000000000000000101000000000101010101010101010101010101000000000101010101010000010101010101010101010101010100000101010101010101010100000000
0000000001010000000001010000000000000000000001010000000001010000000000000000000001010000000001010000000000000000000000000000000000000101000000000101010101010101010101010101000000000101010101010000010101010101010101010101010100000101010101010101010100000000
0000000001010000000001010000000000000000000001010000000001010000000000000000000001010000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000
0000000001010000000001010000000000000000000001010000000001010000000000000000000001010000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000
0000000001010000000001010101010101010101010101010000000001010101010100000101010101010000000001010000000000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000
0000000001010000000001010101010101010101010101010000000001010101010100000101010101010000000001010000000000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000101000000000101010101010101010101010101000000000101010101010101010101010101010101010101010101010101010100000000010100000000
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000101000000000101010101010101010101010101000000000101010101010101010101010101010101010101010101010101010100000000010100000000
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000010100000000000000000101000000000000010100000000010100000000
0000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000101000000000101000000000000000000000101000000000101000000000000010100000000000000000101000000000000010100000000010100000000
