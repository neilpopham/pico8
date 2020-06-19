pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- demo mode
-- by Neil Popham



-- btnp initial delay
poke(0x5f5c,4)
-- btnp repeat delay
poke(0x5f5d,4)

function get_btnp_delays()
 local id=peek(0x5f5c)
 local rd=peek(0x5f5d)
 if id==0 then id=15 end
 if rd==0 then rd=4 end
 local fps=stat(8)
 if fps==60 then
  id*=2
  rd*=2
 end
 return id,rd
end

function compressdata()
 local k,v,d=nil,0,{}
 for i=1,mode.ends do
   if btnd[i] then
    if btnd[i]==v then
     --repeating
    else
     if k then
      add(d,{k,i-1,v})
     end
     k=i
     v=btnd[i]
    end
   elseif k then
    add(d,{k,i-1,v})
    k,v=nil,nil
   end
 end
 return d
end

function decompressdata(compressed)
 local id,rd=get_btnp_delays()
 btnd,btnpd={},{}
 for k,v in pairs(compressed) do
  --btn
  for i=v[1],v[2] do
   btnd[i]=v[3]
  end
  --btnp
  btnpd[v[1]]=v[3]
  local n=v[1]+id
  if n<=v[2] then
   btnpd[n]=v[3]
   for i=n,v[2],rd do
    btnpd[i]=v[3]
   end
  end
 end
 -- clear btnpd values from btnd
 for k,_ in pairs(btnpd) do
  --btnd[k]=nil
 end
end

mode={
 t=0,
 current=recording,
 recording={
  btn=function(self,i)
   local b=(i==nil and btn() or btn(i))
   local m=btn()
   if m>0 then btnd[mode.t]=m end
   return b
  end,
  btnp=function(self,i)
   local b=(i==nil and btnp() or btnp(i))
   local m=btnp()
   if m>0 then btnpd[mode.t]=m end
   return b
  end,
  init=function(self)
   mode:init()
   btnd={}
   btnpd={}
   menuitem(
    1,
    "stop recording",
    function()
     mode.ends=mode.t

     local log="printh.txt"
     printh("",log,true)
     for k,v in pairs(btnd) do
      printh("btn,"..k..","..v,log)
     end
     printh("",log)
     for k,v in pairs(btnpd) do
      printh("btnp,"..k..","..v,log)
     end
     printh("",log)

     local cd=compressdata()

     for k,v in pairs(cd) do
      printh(k..","..v[1]..","..v[2]..","..v[3],log)
     end
     printh("",log)

     decompressdata(cd)

     for k,v in pairs(btnd) do
      printh("btn,"..k..","..v,log)
     end
     printh("",log)
     for k,v in pairs(btnpd) do
      printh("btnp,"..k..","..v,log)
     end
     printh("",log)

     mode:set("demo")
    end
   )
  end,
  update=function(self)
   mode:update()
   if mode.t<0 then
    mode.ends=32767
    mode:set("demo")
   end
  end
 },
 demo={
  btn=function(self,i)
   return i==nil and self.btnd or self.btnd&1<<i>0
  end,
  btnp=function(self,i)
   return i==nil and self.btnpd or self.btnpd&1<<i>0
  end,
  init=function(self)
   mode:init()
   menuitem(
    1,
    "start recording",
    function()
     mode:set("recording")
    end
   )
  end,
  update=function(self)
   mode:update()
   if mode.t>mode.ends then
    mode:init()
   end
   self.btnpd=btnpd[mode.t] and btnpd[mode.t] or 0
   self.btnd=btnd[mode.t] and btnd[mode.t] or self.btnpd
  end
 },
 game={
  btn=function(self,i)
   return i==nil and btn() or btn(i)
  end,
  btnp=function(self,i)
   return i==nil and btnp() or btnp(i)
  end,
  init=function()
   mode:init()
  end,
  update=function()
  end
 },
 set=function(self,name)
  self.current=self[name]
  self.name=name
  self.current:init()
 end,
 init=function(self)
  self.t=0
  if mode.reset then mode.reset() end
 end,
 update=function(self)
  self.t+=1
 end
}

function ptn(b)
 return mode.current:btn(b)
end

function ptnp(b)
 return mode.current:btnp(b)
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
 mode.reset=reset
 mode:set("recording")
end

function _update60()
 mode.current:update()

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
 print(mode.t,50,0,7)
 print(stat(8),110,0,8)
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
 --print(btn(),0,10,1)
end
