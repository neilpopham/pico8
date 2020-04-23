stage_main_placing={
 init=function(self)

 end,
 update=function(self)
  -- move player selector
  p:move()
  -- calculate range
  self.mask={}
  local range=minsky(p.x,p.y,p.gun.range)
  for y,xs in pairs(range) do
   for x=xs.x1,xs.x2 do
    local tx=x*5+4
    local ty=y*5+4
    local cx,cy
    if los(p.px+2,p.py+2,tx,ty,function(x,y)
     cx,cy=get_cell(x,y)
     local tile=get_tile(cx,cy)
     return tile~=2
    end
    ) then
     local cell=vec2:create(cx,cy)
     local idx=cell:index()
     self.mask[idx]=cell
    end
   end
  end
  -- place gun
  if btnp(pad.btn1) and p.valid then
   local gun=vec2:create(p.x,p.y)
   gun=extend(clone(p.gun),gun)
   gun.mask=clone(self.mask)
   gun.px=p.px
   gun.py=p.py
   gun.level=1
   p.gun=gun
   add(p.arsenal,gun)
   room[p.y+1][p.x+1]=2
   stage:set_state(stage_main_viewing)
  end
 end,
 draw=function(self)
  -- draw range
  if p.valid then
   --fillp(0b0101101001011010.1)
   --fillp(0b1001001101101100.1)
   for k,v in pairs(self.mask) do
    --rectfill(2+v.x*5,2+v.y*5,6+v.x*5,6+v.y*5,1)
    --circ(4+v.x*5,4+v.y*5,1,2)
    rect(3+v.x*5,3+v.y*5,5+v.x*5,5+v.y*5,2)
   end
   --fillp()
  end
  -- draw gun marker
  rectfill(p.px,p.py,4+p.px,4+p.py,p.gun.col)
  -- draw player selector
  p:draw()
  --print(room[p.y+1][p.x+1],0,0,7)
 end
}
