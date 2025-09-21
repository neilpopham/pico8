pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

-- fog stuff
poke(0x5F34, 0x2)
poke(0x5F34, 0x3)

printh("=======")

local floormaker={
    cells={},
    rooms=0,
    idx=0,
    offsets={{x=0,y=-1},{x=1,y=0},{x=0,y=1},{x=-1,y=0}},
    mx=0,
    my=0,
    sprites="1,1,1,1,1,2,16,17,18,19,3,17,18,19,16,4,18,19,16,17,5,19,16,17,18",
    templates={
        -- room
        [1]={"1,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1"},
        -- l-shape
        [3]={"1,2,2,2,1,1,1,1,1,3,1,1,1,1,3,1,1,1,1,3,1,1,1,1,1"},
        -- straight
        [5]={"1,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,4,4,1"},
        -- t-junction
        [7]={"1,2,2,2,1,5,1,1,1,3,5,1,1,1,3,5,1,1,1,3,1,1,1,1,1"},
        -- crossroads
        [15]={"1,2,2,2,1,5,1,1,1,3,5,1,1,1,3,5,1,1,1,3,1,4,4,4,1"},
    },
    rotations={
        -- room
        [1]={type=1,rotation=1},
        [2]={type=1,rotation=2},
        [4]={type=1,rotation=3},
        [8]={type=1,rotation=4},
        -- l-shape
        [3]={type=3,rotation=1},
        [6]={type=3,rotation=2},
        [12]={type=3,rotation=3},
        [9]={type=3,rotation=4},
        -- straight
        [5]={type=5,rotation=1},
        [10]={type=5,rotation=2},
        -- t-junction
        [7]={type=7,rotation=1},
        [14]={type=7,rotation=2},
        [13]={type=7,rotation=3},
        [11]={type=7,rotation=4},
        -- crossroads
        [15]={type=15,rotation=1},
    },
    rotatoes={
        [2]=function(x,y,mx,my)
            return flr(-y+mx),flr(x+my)
        end,
        [3]=function(x,y,mx,my)
            return flr(-x+mx),flr(-y+my)
        end,
        [4]=function(x,y,mx,my)
            return flr(y+mx),flr(-x+my)
        end,
    },
    random=function(self)
        return flr(rnd(4))+1
    end,
    opposite=function(self,n)
        return self:safe(n+2)
    end,
    safe=function(safe,n)
        n=n%4
        return n==0 and 4 or n
    end,
    coords=function(self,x,y,d)
        return x+self.offsets[d].x,y+self.offsets[d].y
    end,
    set=function(self,x,y,room)
        if not self.cells[x] then self.cells[x]={} end
        self.cells[x][y]=room
        self.rooms+=1
    end,
    taken=function(self,x,y)
        if not self.cells[x] then return false end
        if not self.cells[x][y] then return false end
        return true
    end,
    test=function(self,x,y,d)
        local nx,ny=self:coords(x,y,d)
        return not self:taken(nx,ny)
    end,
    run=function(self)
        myrnd=flr(rnd(32000))+1
        -- myrnd=13438 -- troublesome
        -- myrnd=13152
        srand(myrnd)
        printh('myrnd='..myrnd)

        -- convert sprites data to lookup
        local sprites=split(self.sprites)
        self.sprites={}
        for s=1,#sprites,5 do
            self.sprites[sprites[s]]={sprites[s+1],sprites[s+2],sprites[s+3],sprites[s+4]}
        end

        for k1,v1 in pairs(self.sprites) do
            printh('sprite index '..k1)
            for k2,v2 in pairs(v1) do
                printh(k2..'='..v2)
            end
        end
        -- assert(false)

        -- convert templates data to lookup
        local size=5
        self.mx=5/2
        self.my=5/2
        for t,templates in pairs(self.templates) do
            local grids={}
            for template in all(templates) do
                local gx,gy,grid,sprites=1,1,{},split(template)
                for s in all(sprites) do
                    if gx==1 then grid[gy]={} end
                    grid[gy][gx]=s
                    gx+=1
                    if gx>size then gy+=1  gx=1 end
                end
                add(grids,grid)
            end
            self.templates[t]=grids
        end

        for k,v in pairs(self.templates) do
            printh('t='..k)
            for j,g in ipairs(v) do
                printh('j='..j)
                printh(g)
                for y, row in ipairs(g) do
                    for x,s in ipairs(row) do
                        printh('x='..x..' y='..y..' s='..s)
                    end
                end
            end
        end

        d1=self:random()
        d2=self:opposite(d1)
        room={idx=0,linexxxxx=1,exits=0,exit={}}
        self:set(20,20,room)
        for d in all({d1,d2}) do
            local nx,ny=self:coords(20,20,d)
            self.cells[20][20].exit[d]={nx,ny}
            self.cells[20][20].exits+=1
            self:worker(20,20,nx,ny,d)
        end

        for x,cols in pairs(self.cells) do
            for y,room in pairs(cols) do
                if room.exits==1 then
                    -- add(options,{x=x,y=y})
                elseif room.exits==2 then
                    for d,_ in pairs(room.exit) do
                        local o=self:opposite(d)
                        if room.exit[o] then
                            local cw=self:safe(d+1)
                            if self:test(x,y,cw) and rnd()<.5 then
                                local nx,ny=self:coords(x,y,cw)
                                local ok=true
                                for _,os in ipairs(self.offsets) do
                                    local sx,sy=nx+os.x,ny+os.y
                                    if self:taken(sx,sy) and (sx!=x or sy!=y) then
                                        -- printh(sx..','..sy..' is taken')
                                        ok=false
                                    end
                                end
                                if ok then
                                    local o=self:opposite(cw)
                                    -- printh('CREATE ROOM')
                                    -- printh('nx='..nx..' ny='..ny.. ' cw='..cw)
                                    self.cells[x][y].exit[cw]={nx,ny}
                                    self.cells[x][y].exits+=1
                                    local exit={}
                                    exit[o]={x,y}
                                    self.idx+=1
                                    self:set(nx,ny,{exits=1,exit=exit,idx=self.idx,cr=1})
                                end
                            end
                        end
                    end
                end
            end
        end

        local options={}
        local mn,mx={x=99,y=99},{x=0,y=0}
        for x,cols in pairs(self.cells) do
            mn.x=min(mn.x,x)
            mx.x=max(mx.x,x)
            for y,room in pairs(cols) do
                mn.y=min(mn.y,y)
                mx.y=max(mx.y,y)
                room.mask=0
                for d,_ in pairs(room.exit) do
                    room.mask|=2^(d-1)
                    printh('exit='..d)
                end
                printh('mask='..room.mask..' exits='..room.exits)
                local tpl = self.rotations[room.mask]
                printh('type='..tpl.type..' rotation='..tpl.rotation)
                room.tpl=self.rotations[room.mask]
                if room.exits==1 then
                    add(options,{x=x,y=y})
                end
            end
        end

        printh(mn.x..'-'..mx.x)
        printh(mn.y..'-'..mx.y)

        printh(#options)

        local start=flr(rnd(#options))+1
        local exit=flr(rnd(#options))+1
        while exit==start do
            exit=flr(rnd(#options))+1
        end
        start=options[start]
        exit=options[exit]

        printh('start x='..start.x..' y='..start.y)
        printh('exit  x='..exit.x..' y='..exit.y)

        -- room width and height in sprites
        local size=5

        poke(0x5f56, 0x80)
        poke(0x5f57, size*(mx.x-mn.x+1))
        memset(0x8000,0,0x4000)

        for x,cols in pairs(self.cells) do
            for y,room in pairs(cols) do
                local tx,ty=x-mn.x,y-mn.y

                local s=1
                printh(room.tpl.type)
                local tpl = self.rotations[room.mask]
                printh('type='..tpl.type..' rotation='..tpl.rotation)

                -- local template=self.templates[tpl.type][1]
                -- local sprites=split(template)
                -- local gx,gy,grid,rotated=1,1,{},{{}}
                -- for s in all(sprites) do
                --     grid[gy][gx]=s
                --     gx+=1
                --     if gx>size then gy+=1 gx=1 rotated[gy]={} end
                -- end

                -- 1 can be flr(rnd(n) + 1)
                local grid=self.templates[tpl.type][1]

                -- for gy,row in ipairs(grid) do
                --     w=""
                --     for gx,s in ipairs(row) do
                --         w=w..s
                --     end
                --     printh(w)
                -- end

                local rotated={}
                for gy,_ in ipairs(grid) do rotated[gy]={} end
                local h,w=#grid,#grid[1]
                local mx,my=(w+1)/2,(h+1)/2

                printh('h='..h..' w='..w..' mx='..mx..' my='..my)

                for gy,rows in ipairs(grid) do
                    for gx,s in ipairs(rows) do
                        local nx,ny
                        if tpl.rotation==1 then
                            nx,ny=gx,gy
                            printh('tx='..tx..' ty='..ty..' nx='..nx..' ny='..ny)
                        else
                            local dx,dy=gx-mx,gy-my
                            nx,ny=self.rotatoes[tpl.rotation](dx,dy,mx,my)
                            printh('tx='..tx..' ty='..ty..' dx='..dx..' dy='..dy..' nx='..nx..' ny='..ny)
                        end
                        rotated[ny][nx]=self.sprites[s][tpl.rotation]
                    end
                end

                for gy,row in ipairs(rotated) do
                    w=""
                    for gx,s in ipairs(row) do
                        w=w..s
                    end
                    printh('row'..w)
                end

                -- if x==start.x and y==start.y then
                --     s=4
                -- elseif x==exit.x and y==exit.y then
                --     s=5
                -- elseif tpl.type==1 then
                --     s=6
                -- elseif tpl.type==3 then
                --     s=7
                -- elseif tpl.type==5 then
                --     s=10
                -- elseif tpl.type==7 then
                --     s=8
                -- elseif tpl.type==15 then
                --     s=9
                -- end

                for ox=0,size-1 do
                    for oy=0,size-1 do
                        -- local c=1
                        -- if room.exits==3 then c=2 end
                        -- if room.exits==2 then
                        --     if room.line then c=3 else c=4 end
                        -- end
                        -- local s=(ox+oy)%2+c

                        -- if ox==0 or ox==17 or oy==0 or oy==17 then
                        --     if room.exit[4] and ox==0 and oy>=6 and oy<=11 then
                        --         s=s
                        --     elseif room.exit[2] and ox==17 and oy>=6 and oy<=11 then
                        --         s=s
                        --     elseif room.exit[1] and oy==0 and ox>=6 and ox<=11 then
                        --         s=s
                        --     elseif room.exit[3] and oy==17 and ox>=6 and ox<=11 then
                        --         s=s
                        --     else
                        --         s=3
                        --     end
                        -- end

                        s=rotated[oy+1][ox+1]

                        -- mset(tx*18+ox-tx,ty*18+oy-ty,s)
                        mset(tx*size+ox,ty*size+oy,s)
                    end
                end
            end
        end

        cls()
        for x,cols in pairs(self.cells) do
            for y,room in pairs(cols) do
                -- printh('idx='..room.idx..' x='..x..' y='..y..' n='..(room.exit[1] and 'Y' or 'N')..' e='..(room.exit[2] and 'Y' or 'N')..' s='..(room.exit[3] and 'Y' or 'N')..' w='..(room.exit[4] and 'Y' or 'N'))
                -- printh(room.idx)
                local colour=3
                if room.exits==1 then colour=6 end
                if room.cr then colour=4 end
                rectfill(x*4,y*4,x*4+2,y*4+2,colour)
            end
        end
        pset(80,80,0)
        -- stop()
    end,
    worker=function(self,px,py,cx,cy,exit)
        self.idx+=1
        local entrance=self:opposite(exit)
        local room,exits={exits=1,exit={},idx=self.idx},{}
        room.exit[entrance]={px,py}

        printh('px='..px..' py='..py..' cx='..cx..' cy='..cy)

        if abs(20-cx)>5 or abs(20-cy)>5 then
            -- printh('out of bounds')
            self:set(cx,cy,room)
            return
        end

        local previous=self.cells[px][py]

        printh('1. cx='..cx..' cy='..cy)

        -- if we've come from a straight corridor
        if previous.line then
            -- turn anticlockwise?
            if rnd()<.2 then
                local d=self:safe(entrance-1)
                if self:test(cx,cy,d) then
                    add(exits,d)
                end
            end
            -- turn clockwise?
            if rnd()<.2 then
                local d=self:safe(entrance+1)
                if self:test(cx,cy,d) then
                    add(exits,d)
                end
            end
        end
        -- if not turned
        if #exits==0 then
            -- printh('chance of '..(self.rooms/20))
            -- turn into a room?
            if self.rooms>7 and rnd()<(self.rooms/20) then
                -- stop here
                -- printh('terminate with room count of '..self.rooms)
            -- continue straight
            else
                room.line=1
                add(exits,exit)
            end
        else
            printh('we have '..(#exits)..' EXITS')
        end
        self:set(cx,cy,room)
        printh("-")
        printh('x='..cx..' y='..cy..' e='..entrance)
        for d in ipairs(exits) do
            printh('x='..cx..' y='..cy..' d='..d)
            local nx,ny=self:coords(cx,cy,d)
            if not self:taken(nx,ny) then
                self.cells[cx][cy].exit[d]={nx,ny}
                self.cells[cx][cy].exits+=1
                self:worker(cx,cy,nx,ny,d)
            end
        end
        printh("--")
    end,
}

floormaker:run()

-- print(#floormaker.cells)

-- function floorworker()


-- end

-- function floorbuilder()


-- end

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

    -- camera(0,0)
    -- circfill(64,64,48,0b0001100100000000.0111111111011111)
    -- circfill(64,64,52,0b0001100100000000.0101111101011111)
    -- circfill(64,64,56,0b0001100100000000.0101101001011010)
    -- circfill(64,64,58,0b0001100100000000.0100101000011010)
    -- circfill(64,64,60,0b0001100100000000.0000000000000000)
end

__gfx__
0000000011111111dddddddd77777776333333332222222244444444666666669999999988888888555555550000000000000000000000000000000000000000
0000000011111111dddddddd7666666d330000032200002240400004660666669990999980888088550000550000000000000000000000000000000000000000
0000000011111111dddddddd7666666d303333332022220240044444660666669900099988080888505555550000000000000000000000000000000000000000
0000000011111111dddddddd7666666d330000332000000240444444660666669990999988808888505555550000000000000000000000000000000000000000
0000000011111111dddddddd7666666d333333032022222240444444660666669990999988080888505555550000000000000000000000000000000000000000
0000000011111111dddddddd7666666d300000332200002240444444660666669990999980888088550000550000000000000000000000000000000000000000
0000000011111111dddddddd7666666d333333332222222244444444666006669990099988888888555555550000000000000000000000000000000000000000
0000000011111111dddddddd6ddddddd333333332222222244444444666666669999999988888888555555550000000000000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd6666666d666666dd666666d6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66dddd666666dd66666dd66666dd6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6dddddd66dddddd6666dd6666dddddd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd6666dddddd66dddddd66dddddd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd6666666dd6666dddd6666dd6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666dd6666666d666666dd666666d6666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
