pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- analyse a sprite and create an array of size x
-- containing a proportionate number of each colour used
-- for use with particle explosion
-- by neil popham

function round(x) return flr(x+0.5) end

-- returns the position of the specified sprite in the sprite sheet
-- s is the sprite index
function get_sprite_origin(s)
 local x=(s*8) % 128
 local y=flr(s/16)*8
 return {x,y}
end

-- returns a multi-dimensional array
-- with the colour for each pixel in the sprite
-- cols[x][y]=colour
-- s is the sprite index
function get_sprite_cols(s)
 local pos=get_sprite_origin(s)
 cols={}
 for dx=0,7 do
   cols[dx+1]={}
  for dy=0,7 do
   cols[dx+1][dy+1]=sget(pos[1]+dx,pos[2]+dy)
  end
 end
 return cols
end

-- retuns an array with the pixel count and overall percentage
-- for each colour in the sprite
-- s is the sprite index
-- ignore is the colour index to ignore (e.g.: 0) when calculating values
function get_sprite_col_spread(s,ignore)
 ignore=ignore or 16
 local data=get_sprite_cols(s)
 local cols={}
 local total=0
 for dx=1,8 do
  for dy=1,8 do
   col=data[dx][dy]
   if col~=ignore then
    col=col+1
    if cols[col]==nil then cols[col]={count=0,percent=0} end
    cols[col].count=cols[col].count+1
    total=total+1
   end
  end
 end
 for i,_ in pairs(cols) do
  cols[i].percent=cols[i].count/total
 end
 return cols
end

-- as above, but we don't really need the count
-- so let's just return a simple array with the ratio value
function get_sprite_col_ratio(s,ignore)
 ignore=ignore or 16
 local data=get_sprite_cols(s)
 local cols={}
 local total=0
 for dx=1,8 do
  for dy=1,8 do
   col=data[dx][dy]
   if col~=ignore then
    col=col+1
    cols[col]=(cols[col] or 0)+1
    total=total+1
   end
  end
 end
 for i,_ in pairs(cols) do
  cols[i]=cols[i]/total
 end
 return cols
end

-- see get_colour_array() below
-- this one will return the exact number
-- it adjust the percentages as it goes relative to the amount already added
function get_colour_array_new(s,count,ignore)
 local cols=get_sprite_col_spread(s,ignore)
 local array={}
 local j=1
 local t=0
 for i,col in pairs(cols) do t=t+1 end
 for i,col in pairs(cols) do
  local remv=count-#array -- number left to add
  local remp=remv/count   -- percentage left to add
  local p=j==t and remv or round((col.percent/remp)*remp)
  for c=1,p do add(array,i-1) end
  j=j+1
 end
 return array
end

-- returns an array of colours in the correct proportion
-- s is the sprite index
-- count is the number of values to return*
-- ignore is the colour index to ignore (e.g.: 0) when calculating values
-- * may return more than asked for
--   but as long as we loop through this array to add the particles
--   we don't care if we have a few too many
function get_colour_array(s,count,ignore)
 local cols=get_sprite_col_spread(s,ignore)
 local array={}
 for i,col in pairs(cols) do
  local p=round(count*col.percent)
  for c=1,p do
   add(array,i-1)
  end
 end
 return array
end

-- don't want to use get_sprite_origin(), get_sprite_cols() or get_sprite_col_spread() elsewhere?
-- this function does the same as get_sprite_colour_array() but is self-contained
-- so you can just delete all the others
-- same disclaimer applies
function get_colour_array_simple(s,count,ignore)
 local x=(s*8) % 128
 local y=flr((s*8)/128)*8
 local col={}
 local list={}
 local total=0
 for dx=0,7 do
  for dy=0,7 do
   local c=sget(x+dx,y+dy)
   if c~=ignore then
    col[c+1]=(col[c+1] or 0)+1
    total=total+1
   end
  end
 end
 local r=count/total
 for c,t in pairs(col) do
  for i=1,round(r*t) do
   add(list,c-1)
  end
 end
 return list
end

function _init()
 s=1
 x=get_sprite_cols(s)
 y=get_sprite_col_spread(s)
 yy=get_sprite_col_ratio(s)
 z=get_colour_array(s,100)
 zz=get_colour_array_simple(s,100)

 a=get_colour_array(s,50)
 a=get_colour_array_new(s,50)
end

function _update()

end

function _draw()
 cls(1)

 for dx=1,8 do
  for dy=1,8 do
   col=x[dx][dy]
   rectfill(dx*4,dy*4,(dx*4)+3,(dy*4)+3,col)
  end
 end

 -- get_sprite_col_spread
 for c,col in pairs(y) do
  print(col.count,c*8,100,c-1)
  print(flr(col.percent*100),c*8,108,c-1)
 end

 -- get_sprite_col_ratio
 for c,col in pairs(yy) do
  print(flr(col*100),c*8,115,c-1)
 end

 m=#z
 --print(m,120,120,1)
 for i=1,m do
  pset(i,127,z[i])
 end

 m=#zz
 for i=1,m do
  pset(i,125,z[i])
 end

end
__gfx__
000000000000bb770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008bbb88770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700bbb888a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000b08aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000b88aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700bb80bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b088b0bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
