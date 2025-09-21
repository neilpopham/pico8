grid={
	{'a','b','c','d'},
	{'e','f','g','h'},
	{'i','j','k','l'},
	{'m','n','o','p'},
}

grid={
	{'a','b','c','d','0'},
	{'e','f','g','h','1'},
	{'i','j','k','l','2'},
	{'m','n','o','p','3'},
	{'q','r','s','t','4'},
}

for y,row in ipairs(grid) do 
	s=""
	for x,n in ipairs(row) do
		s=s..n
	end
	print(s)
end

h=#grid
w=#grid[1]

print(w)
print(h)

mx=(w+1)/2
my=(h+1)/2

print(mx)
print(my)

--rotated = grid


rotatoes={
	[2]=function(self,x,y)
		return math.floor(-dy+mx),math.floor(dx+my)
	end,
	[3]=function(self,x,y)
		return math.floor(-dx+mx),math.floor(-dy+my)
	end,
	[4]=function(self,x,y)
		return math.floor(dy+mx),math.floor(-dx+my)
	end,
}



rotated={}
for y=1,#grid do 
	rotated[y]={}
	--for x=1,#grid[1] do
	--	rotated[y][x]=0
	--end
end

for y,row in ipairs(grid) do
	for x,n in ipairs(row) do
--~ 		ox=x<mx and math.ceil(mx) or math.floor(mx)
--~ 		oy=y<my and math.ceil(my) or math.floor(my)
                --print('===')
		--print('x '..x)
		--print('y '..y)
		--print('ox '..ox)
		--print('oy '..oy)
		
		dx=x-mx
		dy=y-my
		--print('dx '..dx)
		--print('dy '..dy)
		
		
		
		--gx=x-dx
		--gy=y-dy
		--print(-gx+dx)
		--print(y+dy)
		
		--print(dy)
		--print(-dx)
		
		--print(-dy)
		--print(dx)
		
		--print(-dy+mx)
		--print(dx+my)
		
		-- 90
		--rotated[math.floor(dx+my)][math.floor(-dy+mx)]=n
		-- 180
		--rotated[math.floor(-dy+my)][math.floor(-dx+mx)]=n
		-- 270
		--rotated[math.floor(-dx+my)][math.floor(dy+mx)]=n
		nx,ny=rotatoes[2](dx,dy)
		--print(nx..' '..ny)
		rotated[ny][nx]=n
	end
end

for y,row in ipairs(rotated) do 
	s=""
	for x,n in ipairs(row) do
		s=s..n
	end
	print(s)
end

