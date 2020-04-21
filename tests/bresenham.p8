pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
-- bresenham's line algorithm implementation in pico8
-- by laurent victorino

-- list of points to draw lines
points={}
-- position of the cursor
pos={}

function _init()
	-- initialize position
	-- at the center of the screen
	pos.x=64
	pos.y=64
end

function _update()
	-- move the position
	if btn(0) then pos.x-=1 end
	if btn(1) then pos.x+=1 end
	if btn(2) then pos.y-=1 end
	if btn(3) then pos.y+=1 end

	-- if btn 5 has been pressed
	if btn(5) and btnp(5) then
			addpoint()
	end
end

function _draw()
	-- draw background
	rectfill(0,0,127,127,6)
	-- if there are points in the list
	if #points > 0 then
		-- for every point
		-- draw a line between point and point+1
		for i=1,#points-1 do
			drawline(points[i],points[i+1],5)
		end
		-- draw a line between last point in list
		-- and cursor position
		p={}
		p.x=pos.x
		p.y=pos.y
		drawline(points[#points],p,7)
	end
	-- draw the cursor
	rect(pos.x-1,pos.y-1,pos.x+1,pos.y+1,5)
	-- help text
	print("arrows:move",1,1,0)
	print("x:add a line",1,7,0)
end

-- basic brenseham algorithm
function drawline(p1,p2,c)
	dx=abs(p2.x-p1.x)
	dy=abs(p2.y-p1.y)
	x=p1.x
	y=p1.y
	if p1.x<=p2.x then sx=1 else sx=-1 end
	if p1.y<=p2.y then sy=1 else sy=-1 end
	if dx > dy then
		err=dx/2.0
		while x != p2.x do
			pset(x,y,c)
			err-=dy
			if err < 0 then
				y+=sy
				err+=dx
			end
			x+=sx
		end
	else
		err=dy/2.0
		while y != p2.y do
			pset(x,y,c)
			err-=dx
			if err < 0 then
				x+=sx
				err+=dy
			end
			y+=sy
		end
	end
end

function addpoint()
	-- copy the cursor position
	-- add it to the point list
 p={}
	p.x=pos.x
	p.y=pos.y
	add(points,p)
end
