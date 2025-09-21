pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

extcmd('rec')

function keywithfixedlengths(data,l)
    local items,r=split(data,";"),{}
    for item in all(items) do
        local b,d=split(item),{}
        local k=b[1]
        r[k]={}
        for i=2,#b do
            add(d,b[i])
            if #d==l then add(r[k],d) d={} end
        end
    end
    return r
end

function keywithfixedlength(data,l)
    local b,m,r,d=split(data),l+1,{},{}
    for i=1,#b do
        if i%m==1 then k=b[i] else add(d,b[i]) end
        if i%m==0 then r[k]=d d={} end
    end
    return r
end

function fixedlength(data,l)
    local b,r,d=split(data),{},{}
    for i=1,#b do
        add(d,b[i])
        if #d==l then add(r,d) d={} end
    end
    return r
end

function random(n) return flr(rnd(n))+1 end

function mapmaker()
    local cells,rooms,offsets,mx,my,sprites,templates,rotations={},0,{{x=0,y=-1},{x=1,y=0},{x=0,y=1},{x=-1,y=0}},0,0

    sprites=keywithfixedlength("1,16,17,18,19,2,17,18,19,16,3,18,19,16,17,4,19,16,17,18,11,1,1,1,1",4)
    templates=keywithfixedlengths("1,11,1,1,1,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11;3,11,1,1,1,11,11,11,11,11,2,11,11,11,11,2,11,11,11,11,2,11,11,11,11,11;5,11,1,1,1,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,3,3,3,11;7,11,1,1,1,11,11,11,11,11,2,11,11,11,11,2,11,11,11,11,2,11,3,3,3,11;15,11,1,1,1,11,4,11,11,11,2,4,11,11,11,2,4,11,11,11,2,11,3,3,3,11",25)
    rotations=keywithfixedlength("1,1,1,2,1,2,4,1,3,8,1,4,3,3,1,6,3,2,12,3,3,9,3,4,5,5,1,10,5,2,7,7,1,14,7,2,13,7,3,11,7,4,15,15,1",2)

    local size,c=5,3

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

    function opposite(n)
        return safe(n+2)
    end
    function safe(n)
        n=n%4
        return n==0 and 4 or n
    end
    function coords(x,y,d)
        return x+offsets[d].x,y+offsets[d].y
    end
    function set(x,y,room)
        if not cells[x] then cells[x]={} end
        cells[x][y]=room
        rooms+=1
    end
    function taken(x,y)
        if not cells[x] or not cells[x][y] then return false end
        return true
    end
    function test(x,y,d)
        local nx,ny=coords(x,y,d)
        return not taken(nx,ny)
    end
    function worker(px,py,cx,cy,exit)
        local entrance=opposite(exit)
        local room,exits={exits=1,exit={}},{}
        room.exit[entrance]={px,py}

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
            -- turn into a room?
            if rooms<8 and rnd()>(rooms/20) then
                room.line=1
                add(exits,exit)
            end
        end
        set(cx,cy,room)
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
                if gx>size then gy+=1  gx=1 end
            end
            add(grids,grid)
        end
        templates[t]=grids
    end

    local d1=random(4)
    local d2=opposite(d1)
    room={exits=0,exit={}}
    set(20,20,room)
    for d in all({d1,d2}) do
        local nx,ny=coords(20,20,d)
        cells[20][20].exit[d]={nx,ny}
        cells[20][20].exits+=1
        worker(20,20,nx,ny,d)
    end

    for x,cols in pairs(cells) do
        for y,room in pairs(cols) do
            if room.exits==2 then
                for d,_ in pairs(room.exit) do
                    local o=opposite(d)
                    if room.exit[o] then
                        local cw=safe(d+1)
                        if test(x,y,cw) and rnd()<.5 then
                            local nx,ny=coords(x,y,cw)
                            local ok=true
                            for _,os in ipairs(offsets) do
                                local sx,sy=nx+os.x,ny+os.y
                                if taken(sx,sy) and (sx!=x or sy!=y) then
                                    ok=false
                                end
                            end
                            if ok then
                                local o=opposite(cw)
                                cells[x][y].exit[cw]={nx,ny}
                                cells[x][y].exits+=1
                                local exit={}
                                exit[o]={x,y}
                                set(nx,ny,{exits=1,exit=exit})
                            end
                        end
                    end
                end
            end
        end
    end

    local options,mn,mx={},{x=99,y=99},{x=0,y=0}
    for x,cols in pairs(cells) do
        mn.x=min(mn.x,x)
        mx.x=max(mx.x,x)
        for y,room in pairs(cols) do
            mn.y=min(mn.y,y)
            mx.y=max(mx.y,y)
            room.mask=0
            for d,_ in pairs(room.exit) do
                room.mask|=2^(d-1)
            end
            if room.exits==1 then
                add(options,{x=x,y=y})
            end
        end
    end

    local start=random(#options)
    local exit=random(#options)
    while exit==start do
        exit=random(#options)
    end
    start=options[start]
    exit=options[exit]

    poke(0x5f56, 0x80)
    poke(0x5f57, size*(mx.x-mn.x+1))
    memset(0x8000,0,0x4000)

    for x,cols in pairs(cells) do
        for y,room in pairs(cols) do
            local tpl,tx,ty,rotated,s,nx,ny=rotations[room.mask],x-mn.x,y-mn.y,{}
            local type,rotation=unpack(tpl)
            local grid=templates[type][1]
            for gy,_ in ipairs(grid) do rotated[gy]={} end
            for gy,rows in ipairs(grid) do
                for gx,s in ipairs(rows) do
                    if rotation==1 then
                        nx,ny=gx,gy
                    else
                        local dx,dy=gx-c,gy-c
                        nx,ny=rotatoes[rotation](dx,dy)
                    end
                    rotated[ny][nx]=sprites[s][rotation]
                end
            end

            for ox=0,size-1 do
                for oy=0,size-1 do
                    s=rotated[oy+1][ox+1]
                    if s==1 then
                        if ox==2 and oy==2 then
                            s=2
                            if type==1 then s=6 end
                            if type==3 then s=7 end
                            if type==5 then s=10 end
                            if type==7 then s=8 end
                            if type==15 then s=9 end
                            if x==start.x and y==start.y then s=4 end
                            if x==exit.x and y==exit.y then s=5 end
                        end
                    end
                    mset(tx*size+ox,ty*size+oy,s)
                end
            end
        end
    end
end

printh("_____________")

mapmaker()

x=128
y=128

function _update60()
    if btn(0) then x-=1 end
    if btn(1) then x+=1 end
    if btn(2) then y-=1 end
    if btn(3) then y+=1 end
end

function _draw()
    cls()
    camera(x,y)
    map(0,0)
end

__gfx__
0000000011111111dddddddd77777776333333338888888811111111111111111111111111111111111111110000000000000000000000000000000000000000
0000000011111111dddddddd7666666d330000338800008811000011110111111000001110111011110000110000000000000000000000000000000000000000
0000000011111111dddddddd7666666d330333338808888811011011110111111110111111010111110111110000000000000000000000000000000000000000
0000000011111111dddddddd7666666d330000338800088811000011110111111110111111101111110111110000000000000000000000000000000000000000
0000000011111111dddddddd7666666d333330338808888811010111110111111110111111010111110111110000000000000000000000000000000000000000
0000000011111111dddddddd7666666d330000338800008811011011110000111110111110111011110000110000000000000000000000000000000000000000
0000000011111111dddddddd7666666d333333338888888811111111111111111111111111111111111111110000000000000000000000000000000000000000
0000000011111111dddddddd6ddddddd333333338888888811111111111111111111111111111111111111110000000000000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd6666666d666666dd666666d6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66dddd666666dd66666dd66666dd6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6dddddd66dddddd6666dd6666dddddd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd6666dddddd66dddddd66dddddd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd6666666dd6666dddd6666dd6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd6666666d666666dd666666d6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
