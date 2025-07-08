pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- object oriented programming
-- made by kevin

pal(0,129,1)

-- config
star_count=50

-- game loop
function _init()
	score=0
	stars={}
	star_types={
		star,
		near_star,
		far_star
	}

	for i=1,star_count do
		local star_type=rnd(star_types)
		add(stars,star_type:new({
			x=rnd(127),
			y=rnd(127)
		}))
	end
end

function _update()
	for star in all(stars) do
		star:update()
	end
end

function _draw()
	cls()
	
	for star in all(stars) do
		star:draw()
	end
	
	print("score: "..score,8,8,7)
end
-->8
-- object oriented programming

global=_ENV

class=setmetatable(
    {
        new=function(_ENV,tbl)
            tbl=tbl or {}
            setmetatable(tbl,{__index=_ENV})
            return tbl
        end
    },
    {__index=_ENV}
)

entity=class:new({
	x=0,
	y=10,
    sum=function(_ENV)
        return x+y
    end
})
-->8
-- stars

-- assert(entity:sum()==nil,entity:sum())

star=entity:new({
    x=100,
	spd=.5,
	rad=0,
	clr=13,
	update=function(_ENV)
		y+=spd
	
		if y-rad > 137 then
			y=-rad
			global.score+=1
		end
	end,
	
	draw=function(_ENV)
		circfill(x,y,rad,clr)
	end,

    test=function(_ENV)
        return sum(_ENV)
    end
})

assert(star:test()==nil,star:test())

far_star=star:new({
	clr=1,
	spd=.25,
	rad=0
})

near_star=star:new({
	clr=7,
	spd=.75,
	rad=1,
	
	new=function(self,tbl)
		tbl=star.new(self,tbl)
		
		tbl.spd=tbl.spd+rnd(.5)
		
		return tbl
	end
})
