pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham



function _init()
 p={
  still=true,
  x=16,
  y=64,
  dx=0,
  ox=0,
  ax=0.25,
  update=function(self)

   -- if we're not moving
   if self.still then

    -- left button pressed
    if btn(0) then
     if round(self.dx)==0 then self.dx=-self.ax end
     self.still=false
     self.ox=self.x
     printh("moving left")
    -- right button pressed
    elseif btn(1) then
     if round(self.dx)==0 then self.dx=self.ax end
     self.still=false
     self.ox=self.x
     printh("moving right")
    -- still and no button pressed
    else
     self.dx=self.dx*self.ax
     if abs(self.dx)==0.01 then self.dx=0 end
    end

   -- not still
   else

   end

   if not p.still then

    if self.x%8==0 and self.x~=self.ox then
     self.still=true
     self:update()
    else
     self.dx=self.dx*1.25
     self.dx=mid(-1,self.dx,1)
     self.x=self.x+round(self.dx)
     printh(self.x.." "..self.ox.." "..self.dx)
    end

    --[[
    if self.tick==8 then
     printh(self.tick.." x:"..self.x)
     self.still=true
     self:update()
    else
     self.x=self.x+self.dx
     self.tick+=1
    end
    ]]

   end

  end
 }

 b={
  still=true,
  x=64,
  y=64,
  dx=0,
  ox=0,
  ax=0.25,
  update=function(self)

   -- if we're not moving
   if self.still then
--printh("1")
    if (p.x>b.x-8) and (p.x<b.x) and p.dx>0 then
--printh("2")
     if round(self.dx)==0 then self.dx=p.dx self.x=p.x+8 end
     self.still=false
     self.ox=self.x
     printh("block moving right")
    elseif (p.x<b.x+8) and (p.x>b.x) and p.dx<0 then
--printh("3")
     if round(self.dx)==0 then self.dx=p.dx self.x=p.x-8 end
     self.still=false
     self.ox=self.x
     printh("block moving left")
    else
--printh("4")
     self.dx=self.dx*self.ax
     if abs(self.dx)==0.01 then self.dx=0 end
    end
   -- not still
   else
    if self.x%8==0 and self.x~=self.ox then
--printh("6")
     self.still=true
     self:update()
    else
--printh("7")
     self.dx=self.dx*1.25
     self.dx=mid(-1,self.dx,1)
     --self.x=self.x+round(self.dx)
     self.x=p.dx<0 and p.x-8 or p.x+8
     printh(self.x.." "..self.ox.." "..self.dx)
    end
   end

   --[[
   if not p.still then
printh("5")
    if self.x%8==0 and self.x~=self.ox then
printh("6")
     self.still=true
     self:update()
    else
printh("7")
     self.dx=self.dx*1.25
     self.dx=mid(-1,self.dx,1)
     self.x=self.x+round(self.dx)
     printh(self.x.." "..self.ox.." "..self.dx)
    end
   end
   ]]

  end
 }
end

function _update60()
 p:update()
 b:update()
end

function _draw()
 cls()
 rectfill(p.x,p.y,p.x+7,p.y+7,1)
 rectfill(b.x,b.y,b.x+7,b.y+7,2)
end

function round(x) return flr(x+0.5) end
