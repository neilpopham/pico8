pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 
-- by neil popham

local screen={width=128,height=128}

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
-- local pad={left=2,right=3,up=0,down=1,btn1=4,btn2=5,btn3=6,btn4=7}

local dir={left=1,right=2,neutral=3}

local drag=0.85

bullet_count=0
bullets={}

function create_bullet(src)
 local b={x=src.x+4,y=src.y-8,hitbox={x=4,y=0,w=2,h=5}}
 return b
end

function update_bullets()
 for _,bullet in pairs(bullets) do
  bullet.y=bullet.y-4
  if bullet.y<0 then
   del(bullets,bullet)
   bullet_count=bullet_count-1
  end
 end
end

function draw_bullets()
 for _,bullet in pairs(bullets) do
  spr(7,bullet.x,bullet.y)
 end
end

function _init()
 t=0
	p={x=56,y=112,dx=0,dy=0,ax=0.15,ay=-0.15,max={dx=3,dy=1}}
end

function _update60()
 t=t+1
 update_bullets()

 if btn(pad.btn1) then
  if bullet_count<10 then
   if t%6==0 then
    add(bullets,create_bullet(p))
    bullet_count=bullet_count+1
   end
   p.y=p.y+3
   p.dy=0
  end
 end

 if btn(pad.left) then
  p.dx=p.dx-p.ax
 elseif btn(pad.right) then
  p.dx=p.dx+p.ax
 else
  p.dx=p.dx*drag
 end
 p.dx=mid(-p.max.dx,p.dx,p.max.dx)
 p.x=p.x+round(p.dx)
 if p.x<0 then p.x=0 end
 if p.x>112 then p.x=112 end

 p.dy=p.dy+p.ay
 p.dy=mid(-p.max.dy,p.dy,p.max.dy)
 p.y=p.y+round(p.dy)
 if p.y<20 then
  p.y=p.y+4
  p.dy=p.max.dy
 end
 if p.y>112 then p.y=112 end
end

function _draw()
 cls(0)

 draw_bullets()

 spr(1,p.x,p.y)
 spr(2,p.x+8,p.y)
 spr(17,p.x,p.y+8)
 spr(18,p.x+8,p.y+8)
end

function round(x) return flr(x+0.5) end

__gfx__
00000000000000567500000011111111111111112222222222222222000770000000000000000000000000000000000000000000000000000000000000000000
00000000000005666760000011111111111111112222222222222222000660000000000000000000000000000000000000000000000000000000000000000000
00000000000055666675000011111111111111112222222222222222000550000000000000000000000000000000000000000000000000000000000000000000
00000000000055666667000011111111111111112222222222222222000770000000000000000000000000000000000000000000000000000000000000000000
00000000000055666667000011111111111111112222222222222222002772000000000000000000000000000000000000000000000000000000000000000000
00000000000055666667000011111111111111112222222222222222008aa8000000000000000000000000000000000000000000000000000000000000000000
000000005000553bbb67000711111111111111112222222222222222008998000000000000000000000000000000000000000000000000000000000000000000
000000001000533bb7b7000111111111111111112222222222222222008980000000000000000000000000000000000000000000000000000000000000000000
000000005000533bbbb7000711111111111111112222222222222222000000000000000000000000000000000000000000000000000000000000000000000000
000000005000533bbbb7000711111111111111112222222222222222000000000000000000000000000000000000000000000000000000000000000000000000
00000000506053333337060711111111111111112222222222222222000000000000000000000000000000000000000000000000000000000000000000000000
00000000556055555555066711111111111111112222222222222222000000000000000000000000000000000000000000000000000000000000000000000000
00000000556008800880066711111111111111112222222222222222000000000000000000000000000000000000000000000000000000000000000000000000
0000000055000ee00ee0006711111111111111112222222222222222000000000000000000000000000000000000000000000000000000000000000000000000
00000000500000000000000711111111111111112222222222222222000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011111111111111112222222222222222000000000000000000000000000000000000000000000000000000000000000000000000