pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- ⬅️➡️⬆️⬇️🅾️❎

function circle_circle_collision(c1, c2)
    local dx, dy, rsum = c2.x - c1.x, c2.y - c1.y, c1.r + c2.r
    return dx * dx + dy * dy <= rsum * rsum
end

function round(v) return flr(v + .5) end

class = setmetatable(
    {
        new = function(_ENV, tbl)
            return setmetatable(tbl or {}, { __index = _ENV })
        end
    },
    { __index = _ENV }
)

ball = class:new({
    reset = function(_ENV)
        x, y, a, da, s, trail, l = 62, 62, rnd(), 0, .8, {}, 0
    end,
    update = function(_ENV)
        dx = cos(a) * s
        dy = sin(a) * s

        if l == 0 then
            local b = { x = x + dx, y = y + dy, r = 2 }
            for c in all(p.parts) do
                if circle_circle_collision(b, c) then
                    local ai = p.a - a + .5
                    a = p.a + ai
                    -- a+=.5
                    dx = cos(a) * s
                    dy = sin(a) * s
                    l = 16
                    break
                end
            end
        else
            l -= 1
        end
        x += dx
        y -= dy
    end,
    draw = function(_ENV)
        circfill(x, y, 2, 12)
    end
})

player = class:new({
    reset = function(_ENV)
        a, da, s, trail, parts = 0, 0, 1, {}, {}
    end,
    update = function(_ENV)
        if btn(🅾️) or btn(❎) then s = 2 else s = 1 end
        local d = .0005
        parts = {}
        if btn(⬅️) or btn(⬇️) then
            da -= d
        elseif btn(➡️) or btn(⬆️) then
            da += d
        else
            da *= .92
            deli(trail, 1)
        end
        if abs(da) < .0002 then da = 0 end

        da = mid(-.0125 * s, da, .0125 * s)
        a = a + da
        a = a % 1
        x = 64 + cos(a) * 62
        y = 64 - sin(a) * 62
        if da != 0 then add(trail, { x, y }) end
        langle = (a - .03)
        rangle = (a + .03)
        for i = langle, rangle, .004 do
            add(parts, { x = 64 + cos(i) * 62, y = 64 - sin(i) * 62, r = 2 })
        end
        -- if da<0 then add(trail,{64+cos(langle)*62,64-sin(a)*62}) end
        -- if da>0 then add(trail,{64+cos(rangle)*62,64-sin(a)*62}) end
    end,
    draw = function(_ENV)
        local lx, ly = x, y
        for i, t in ipairs(trail) do
            if i < 2 then
                circfill(t[1], t[2], 2, 2)
            else
                circfill(t[1], t[2], 2, 9)
            end
            lx, ly = t[1], t[2]
        end
        if #trail > 5 then
            deli(trail, 1)
        end

        for c in all(parts) do
            circfill(c.x, c.y, 2, 9)
        end

        -- line(parts[1].x,parts[1].y,parts[#parts].x,parts[#parts].y,12)

        -- for i=langle,rangle,.004 do
        --     printh(i)
        --     local rdx,rdy=64+cos(i)*62,64-sin(i)*62
        --     circfill(rdx,rdy,2,9)
        -- end
    end
})

p = player:new()
p:reset()

b = ball:new()
b:reset()

function _update60()
    p:update()
    b:update()
end

function _draw()
    cls()
    p:draw()
    b:draw()

    -- circfill(20,20,2,6)
    -- print(p.a,0,0,1)
    -- print(b.a,0,10,1)

    -- -- parts[1].x,parts[1].y,parts[#parts].x,parts[#parts].y

    -- local a = atan2((p.parts[#p.parts].x-p.parts[1].x),(p.parts[#p.parts].y-p.parts[1].y))
    -- print(a,0,20,1)
end
