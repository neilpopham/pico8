-- local __hid__="20:0:22:2:0:01.01.01;01.16.16;01.16.0c,14:7:14:10:1:14.14.14.14;14.14.14.14;14.14.14.14;0d.14.14.14"

-- local __hid__="42:60:44:62:1:01.01.01;00.00.00;01.00.28;01.01.01"

local hidden={}

local rooms=split(__hid__)
for room in all(rooms) do
    local cells={}
    local ox,oy,tx,ty,d,s=unpack(split(room,':'))
    local md=1
    for y,row in ipairs(split(s,';')) do
        local tmp={}
        for x,s in ipairs(split(row,'.')) do
            local d=manhattan(ox+x-1,oy+y-1,tx,ty)
            add(tmp,{sprite=s,d=d})
            md=max(md,d)
        end
        add(cells,tmp)
    end
    add(hidden,{ox=ox,oy=oy,tx=tx,ty=ty,dir=d,t=0,md=md,cells=cells})
end

function get_hidden(x,y)
    for k,row in ipairs(hidden) do
        if x==row.tx and y==row.ty then
            room=row
            return
        end
    end
end

function check_room(tx,ty,dx)
    printh('room '..tostr(room))
    if room then
        printh('visible '..tostr(visible))
        if visible then
            if dx>0 then
                exiting=room.dir==1
            else
                exiting=room.dir==0
            end
        else
            show_room()
        end
    else
        get_hidden(tx,ty)
    end
    printh('exiting '..tostr(exiting))
end

function show_room()
    visible=true
    exiting=false
    room.t-=1
    room.showing=true
    room.hiding=false
    printh('SHOW ROOM')
end

function hide_room()
    visible=false
    exiting=true
    room.t+=1
    room.hiding=true
    room.showing=false
    printh('HIDE ROOM')
end

function render_room()
    local speed=1 -- if kept at 1 can just remove variable
    if room.showing then
        room.t+=1
        local hx,hy
        for y,row in ipairs(room.cells) do
            for x,tile in ipairs(row) do
                hx,hy=room.ox+x-1,room.oy+y-1
                if room.t==tile.d*speed then
                    original[y..'|'..x]=mget(hx,hy)
                    mset(hx,hy,tile.sprite)
                    for e in all(entities) do
                        if e.hide then
                            ex,ey=e.x\8,e.y\8
                            if ex==hx and ey==hy then
                                e.hide=false
                            end
                        end
                    end
                end
            end
        end
        if room.t==room.md*speed then
            room.showing=false
        end
    elseif room.hiding then
        room.t-=1
        for y,row in ipairs(room.cells) do
            for x,tile in ipairs(row) do
                hx,hy=room.ox+x-1,room.oy+y-1
                if room.t==tile.d*speed then
                    mset(hx,hy,original[y..'|'..x])
                    for e in all(entities) do
                        ex,ey=e.x\8,e.y\8
                        if ex==hx and ey==hy then
                            e.hide=true
                        end
                    end
                end
            end
        end
        if room.t==0 then
            room.hiding=false
            room=nil
        end
    end
end

-- function show_room()
--     visible=true
--     printh('SHOW ROOM')
--     local hx,hy
--     for y,row in ipairs(room.cells) do
--         for x,cell in ipairs(row) do
--             hx,hy=room.ox+x-1,room.oy+y-1
--             original[y..'|'..x]=mget(hx,hy)
--             mset(hx,hy,cell.sprite)
--         end
--     end
--     for e in all(entities) do
--         if e.hide then
--             printh('hidden entity')
--             ex=e.x\8
--             ey=e.y\8
--             printh(ex..','..ey)
--             if ex>=room.ox and ex<=hx and ey>=room.oy and ey<=hy then
--                 e.hide=false
--             end
--         end
--     end
-- end

-- function hide_room()
--     visible=false
--     printh('HIDE ROOM')
--     local hx,hy
--     for y,row in ipairs(room.cells) do
--         for x,_ in ipairs(row) do
--             hx,hy=room.ox+x-1,room.oy+y-1
--             mset(hx,hy,original[y..'|'..x])
--         end
--     end
--     for e in all(entities) do
--         ex=e.x\8
--         ey=e.x\8
--         if ex>=room.ox and ex<=hx and ey>=room.oy and ey<=hy then
--             e.hide=true
--         end
--     end
-- end
