function mapmaker()
    local cells,rooms,offsets,mx,my,sprites,templates,rotations={},0,{{x=0,y=-1},{x=1,y=0},{x=0,y=1},{x=-1,y=0}},0,0

    local empty=2

    -- format: i1,r1,r2,r3,r4,i2,r1,r2,r3,r4,...
    sprites=keywithfixedlength(
        "01,01,01,01,01,"..
        "02,02,02,02,02,"..
        "04,04,06,08,10,"..
        "99,99,99,99,99",
        4
    )
    -- format: bitmask,i,i,...
    templates=keywithfixedlengths(
        "01,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,99,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,04,04,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,99,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,04,04,02,04,04,02;"..
        "03,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,02,02,"..
        "00,00,02,02,02,02,02,"..
        "00,00,02,02,02,02,02,"..
        "00,00,00,00,00,00,00,"..
        "00,00,00,00,00,00,00;"..
        "05,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00;"..
        "07,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,02,02,"..
        "00,00,02,02,02,02,02,"..
        "00,00,02,02,02,02,02,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00;"..
        "15,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "02,02,02,02,02,02,02,"..
        "00,00,02,02,02,00,00,"..
        "00,00,02,02,02,00,00",
        49
    )
    -- format: i1:type,rotation,i2,type,rotation,...
    rotations=keywithfixedlength(
        "1,1,1,"..
        "2,1,2,"..
        "4,1,3,"..
        "8,1,4,"..
        "3,3,1,"..
        "6,3,2,"..
        "12,3,3,"..
        "9,3,4,"..
        "5,5,1,"..
        "10,5,2,"..
        "7,7,1,"..
        "14,7,2,"..
        "13,7,3,"..
        "11,7,4,"..
        "15,15,1",
        2
    )

    -- room width and centre (size+1)/2
    local size,c=7,4
    --  functions to rotate a cell
    local rotatoes={
        [2]=function(x,y)
            return flr(-y+c),flr(x+c)
        end,
        [3]=function(x,y)
            return flr(-x+c),flr(-y+c)
        end,
        [4]=function(x,y,mx,my)
            return flr(y+c),flr(-x+c)
        end
    }
    -- for index -12.33 will have a 33/100 chance of returning 12
    function choice(n)
        printh((-n%1)..' '..(-n&0xff))
        if rnd()<-n%1 then return -n&0xff end
        return empty
    end
    -- returns the opposite direction (1-3, 2-4, 3-1, 4-2)
    function opposite(n)
        return safe(n+2)
    end
    -- ensures we have a direction between 1 and 4
    function safe(n)
        n=n%4
        return n==0 and 4 or n
    end
    -- returns new co-ordinates in the specified direction
    function coords(x,y,d)
        return x+offsets[d].x,y+offsets[d].y
    end
    -- creates a room at x,y
    function set(x,y,room)
        if not cells[x] then cells[x]={} end
        cells[x][y]=room
        rooms+=1
    end
    -- checks whether a cell has already been taken
    function taken(x,y)
        if not cells[x] or not cells[x][y] then return false end
        return true
    end
    -- checks whether we can set a cell in the specified direction
    function test(x,y,d)
        local nx,ny=coords(x,y,d)
        return not taken(nx,ny)
    end
    -- populates a cell depending on criteria
    function worker(px,py,cx,cy,exit)
        local entrance,room,exits=opposite(exit),{exits=1,exit={}},{}
        -- set this new rooms entrance from it's predecessor's exit
        room.exit[entrance]={px,py}
        -- if we are straying too far from the centre end the worker here
        if abs(20-cx)>5 or abs(20-cy)>5 then
            set(cx,cy,room)
            return
        end

        local previous=cells[px][py]

        -- if we've come from a straight corridor
        if previous.line then
            local ds={}
            -- turn anticlockwise?
            if rnd()<.2 then add(ds,-1) end
            -- turn clockwise?
            if rnd()<.2 then add(ds,1) end
            for de in all(ds) do
                local d=safe(entrance-de)
                if test(cx,cy,d) then
                    add(exits,d)
                end
            end
        end
        -- if not turned
        if #exits==0 then
            -- if we can still create rooms make this a corridor
            -- if rooms<8 and rnd()>(rooms/20) then
            if rooms<4 and rnd()>(rooms/10) then
                room.line=1
                add(exits,exit)
            end
            -- otherwise turn into a room
        end
        -- ensure we reserve this cell
        set(cx,cy,room)
        -- loop through exits, set them in our room and create a worker for each
        for d in ipairs(exits) do
            local nx,ny=coords(cx,cy,d)
            if not taken(nx,ny) then
                cells[cx][cy].exit[d]={nx,ny}
                cells[cx][cy].exits+=1
                worker(cx,cy,nx,ny,d)
            end
        end
    end

    -- convert templates data to lookup
    for t,options in pairs(templates) do
        local grids={}
        for option in all(options) do
            local gx,gy,grid=1,1,{}
            for s in all(option) do
                if gx==1 then grid[gy]={} end
                grid[gy][gx]=s
                gx+=1
                if gx>size then gy+=1 gx=1 end
            end
            add(grids,grid)
        end
        templates[t]=grids
    end

    -- start at 20,20 with a random exit and its opposite
    local d1=random(4)
    local d2=opposite(d1)
    room={exits=0,exit={}}
    set(20,20,room)
    -- loop through exits, set them in our room and create a worker for each
    for d in all({d1,d2}) do
        local nx,ny=coords(20,20,d)
        cells[20][20].exit[d]={nx,ny}
        cells[20][20].exits+=1
        worker(20,20,nx,ny,d)
    end
    -- loop through the rooms we have
    for x,cols in pairs(cells) do
        for y,room in pairs(cols) do
            -- if the room may be a corridor
            if room.exits==2 then
                for d,_ in pairs(room.exit) do
                    local o=opposite(d)
                    -- if the room is a corridor see if we can set a room clockwise to this exit
                    if room.exit[o] then
                        local cw=safe(d+1)
                        if test(x,y,cw) and rnd()<.5 then
                            local nx,ny=coords(x,y,cw)
                            local ok=true
                            -- only if there is space all around
                            for _,os in ipairs(offsets) do
                                local sx,sy=nx+os.x,ny+os.y
                                if taken(sx,sy) and (sx!=x or sy!=y) then
                                    ok=false
                                end
                            end
                            -- if the stars aligned
                            if ok then
                                -- add the exit to this room
                                cells[x][y].exit[cw]={nx,ny}
                                cells[x][y].exits+=1
                                -- create the new room
                                local o,exit=opposite(cw),{}
                                exit[o]={x,y}
                                set(nx,ny,{exits=1,exit=exit})
                            end
                        end
                    end
                end
            end
        end
    end

    -- loop through the rooms
    local options,mn,mx={},{x=99,y=99},{x=0,y=0}
    for x,cols in pairs(cells) do
        -- detirmine the min and max cells co-ordinates
        mn.x=min(mn.x,x)
        mx.x=max(mx.x,x)
        for y,room in pairs(cols) do
            mn.y=min(mn.y,y)
            mx.y=max(mx.y,y)
            -- record the exit mask for the room 1-15
            room.mask=0
            for d,_ in pairs(room.exit) do
                room.mask|=2^(d-1)
            end
            -- if it's a room add it as an option for the start and exit
            if room.exits==1 then
                add(options,{x=x,y=y})
            end
        end
    end
    -- set the start and exit rooms ensuring they are not the same
    local start=random(#options)
    local exit=random(#options)
    while exit==start do
        exit=random(#options)
    end
    start=options[start]
    exit=options[exit]

    -- create our map at 0x8000 now we know the width and empty it
    poke(0x5f56, 0x80)
    poke(0x5f57, 2*size*(mx.x-mn.x+1))
    memset(0x8000,0,0x4000)

    --
    rms={}
    rif={}
    for i=1,size*(mx.y-mn.y+1) do
        add(rif,{})
    end

    for x,cols in pairs(cells) do
        for y,room in pairs(cols) do
            local tpl,tx,ty,rotated,s,nx,ny=rotations[room.mask],x-mn.x,y-mn.y,{}
            local type,rotation=unpack(tpl)
            -- pick a random template for the room type
            local tindex=random(#templates[type])
            -- we may want to pick a specific template for the exit
            -- or not pick from the pool but pick a unique grid
            if x==exit.x and y==exit.y then tindex=1 end
            local grid=templates[type][tindex]
            for gy,_ in ipairs(grid) do rotated[gy]={} end
            -- set our grid sprites
            for gy,rows in ipairs(grid) do
                for gx,s in ipairs(rows) do
                    -- calculate our co-ordinates for the rotation of the room
                    if rotation==1 then
                        nx,ny=gx,gy
                    else
                        local dx,dy=gx-c,gy-c
                        nx,ny=rotatoes[rotation](dx,dy)
                    end
                    -- if the index is optional then roll the dice
                    if s<0 then s=choice(s) end
                    -- set the correct sprite for the rotation
                    rotated[ny][nx]=s==0 and 0 or sprites[s][rotation]
                end
            end
            --
            add(rms,{x=tx,y=ty,type=type,mask=room.mask})
            -- loop through each room cell
            for ox=0,size-1 do
                for oy=0,size-1 do

                    rif[ty*size+oy+1][tx*size+ox+1]=#rms

                    -- set the sprite
                    local s=rotated[oy+1][ox+1]

                    -- get map cell co-ordinates
                    local cx,cy=tx*size*2+ox*2,ty*size*2+oy*2

                    -- if this is a player start position
                    if s==99 then
                        s=empty
                        if x==start.x and y==start.y then
                            p.x=cx*8
                            p.y=cy*8
                        end
                    end

                    -- using same sprite?
                    local s1,s2,s3,s4
                    if s==0 then
                        s1,s2,s3,s4=s,s,s,s
                    else
                        s1,s2,s3,s4=s,s+1,s+16,s+17
                    end

                    -- add the sprites to the map
                    mset(cx,cy,s1)
                    mset(cx+1,cy,s2)
                    mset(cx,cy+1,s3)
                    mset(cx+1,cy+1,s4)
                end
            end
        end
    end
end