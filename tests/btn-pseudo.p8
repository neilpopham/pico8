pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- demo mode
-- by Neil Popham

mode_demo={
 name="demo",
 t=0,
 btn=function(self,i)
  return i==nil and self.btnd or self.btnd&1<<i>0
 end,
 btnp=function(self,i)
  return i==nil and self.btnpd or self.btnpd&1<<i>0
 end,
 init=function(self)
  mode_demo.reset()
  self.t=0
  menuitem(
   1,
   "start recording",
   function()
    mode=mode_record
    mode:init()
   end
  )
 end,
 update=function(self)
  self.t+=1
  if self.t>self.ends then
   if self.reset then self.reset() end
   self.t=0
  end
  self.btnd=btnd[self.t] and btnd[self.t] or 0
  self.btnpd=btnpd[self.t] and btnpd[self.t] or 0
 end
}

mode_record={
 name="record",
 t=0,
 btn=function(self,i)
  local b=(i==nil and btn() or btn(i))
  local m=btn()
  if m>0 then btnd[self.t]=m end
  return b
 end,
 btnp=function(self,i)
  local b=(i==nil and btnp() or btnp(i))
  local m=btnp()
  if m>0 then btnpd[self.t]=m end
  return b
 end,
 init=function(self)
  mode_demo.reset()
  self.t=0
  btnd={}
  btnpd={}
  menuitem(
   1,
   "stop recording",
   function()
    mode_demo.ends=mode_record.t
    mode=mode_demo
    mode:init()
   end
  )
 end,
 update=function(self)
  self.t+=1
  local s=""
  for i,m in pairs(btnd) do
   s=s..i..","..m.."\n"
  end
  printh(s,"@clip")
 end
}

mode_game={
 name="game",
 btn=function(self,i)
  return i==nil and btn() or btn(i)
 end,
 btnp=function(self,i)
  return i==nil and btnp() or btnp(i)
 end,
 update=function()
 end
}

function ptn(b)
 return mode:btn(b)
end

function ptnp(b)
 return mode:btnp(b)
end

function reset()
 x=64
 y=64
 c1=1
 c2=8
end

function _init()
 printh("=== _init() ===")
 pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
 mode_demo.reset=reset
 mode=mode_record
 mode:init()
end

function _update60()
 mode:update()

 if ptn(pad.left) then x-=1 end
 if ptn(pad.right) then x+=1 end
 if ptn(pad.up) then y-=1 end
 if ptn(pad.down) then y+=1 end

 if ptnp(pad.btn1) then c1=(c1==1 and 2 or 1) end
 if ptnp(pad.btn2) then c2=(c2==8 and 9 or 8) end
end

function _draw()
 cls()
 rectfill(x,y,x+7,y+7,c1)
 rectfill(x+2,y+2,x+5,y+5,c2)
 print(mode.name,0,0,7)
 print("btn()",0,52,3)
 print("btnp()",100,52,3)
 for i=0,5 do
  local z=ptn() or 0
  local b=z&1<<i>0
  print(i..":"..(b and "\130" or ""),0,60+i*6,3)
  local z=ptnp() or 0
  local b=z&1<<i>0
  print(i..":"..(b and "\130" or ""),100,60+i*6,3)
 end
end
