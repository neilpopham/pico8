pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function mrnd(x,f)
 if f==nil then f=true end
 local r=x[1]+rnd((f and 1 or 0)+x[2]-x[1])
 return f and flr(r) or r
end

function generate()
 printh("generate")
 count=0
 cells={}
 makeroom(100,100)
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   for _,d in pairs(cell) do
    assert(x+diff_dir[d][1],y+diff_dir[d][2]~=nil,x..","..y..":"..d)
   end
  end
 end
end

function makeroom(x,y)
 if cells[x]==nil then cells[x]={} end
 if cells[x][y]~=nil then return end
 cells[x][y]={}
 local exits=count<total and mrnd({count<(total/2) and 2 or 1,4}) or 1
 count=count+1
 local choice={1,2,3,4}
 for i=1,exits do
  local d=del(choice,choice[mrnd({1,#choice})])
  add(cells[x][y],d)
 end
 for _,d in pairs(cells[x][y]) do
  makeroom(x+diff_dir[d][1],y+diff_dir[d][2])
 end
end

function _init()
 diff_dir={{0,-1},{1,0},{0,1},{-1,0}}
 total=50
 mt=30
 t=mt
end

function _update60()
 if t==mt then
  generate()
  t=0
 end
 t=t+1
end

function _draw()
 cls()
 for x,rows in pairs(cells) do
  for y,cell in pairs(rows) do
   pset(x-40,y-40,7)
  end
 end
end
