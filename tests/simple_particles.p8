pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

local screen={width=128,height=128}
local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

local particles={}

function create_particle(x,y,colour,life)
 local p={
  x=x,
  y=y,
  colour=colour,
  life=life,
  ttl=life
 }
 return p
end

function update_particles()
 printh("#particles:"..#particles)
 for _,p in pairs(particles) do
  if p.life>0 then
   p.life=p.life-1
  else
   del(particles,p)
  end
 end
end

function draw_particles()
 for _,p in pairs(particles) do
  pset(p.x,p.y,7)
 end
end

function _init()
 u={x=64,y=64}
end

function _update60()
 if btn(pad.up) then u.y=u.y-1 end
 if btn(pad.down) then u.y=u.y+1 end
 if btn(pad.left) then u.x=u.x-1 end
 if btn(pad.right) then u.x=u.x+1 end
 add(particles,create_particle(u.x+rnd(3),u.y+rnd(3),rnd(14)+1,rnd(20)+10))
 update_particles()
end

function _draw()
 cls()
 draw_particles()
end
