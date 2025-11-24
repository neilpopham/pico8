pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
printh('=============')
extcmd('rec')

_G = _ENV

memset(0x8000, 0, 0x2000)

poke(0x5f2e, 1)
pal({ [0] = 0, 0, 2, 3, 4, 5, -16, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, 1)

enemies = {}
bullets = {}
particles = {}
numbers = {}
bombs = {}
dt = 0
cells = {}
stage = 1

function storedigits()
    cls()
    print("0123456789", 0, 0, 7)
    pixels = {}
    for n = 0, 9 do
        pixels[n + 1] = {}
        for x = 1, 3 do
            pixels[n + 1][x] = {}
            for y = 1, 7 do
                if pget(x - 1 + n * 4, y - 1) == 7 then pixels[n + 1][x][y] = 1 end
            end
        end
    end
end

function drawstoreddigit(d, x, y, c, w, h)
    w = w or 4
    h = h or 4
    for px, a in pairs(pixels[d + 1]) do
        for py, _ in pairs(a) do
            local x1 = x + (px - 1) * w
            local y1 = y + (py - 1) * h
            rectfill(x1, y1, x1 + w - 1, y1 + h - 1, c)
        end
    end
    return w * 3
end

function drawstorednumber(n, x, y, c, w, h)
    w = w or 4
    h = h or 4
    local s = tostr(n)
    for i = 1, #s do
        local w = drawstoreddigit(sub(s, i, i), x, y, c, w, h)
        x += w + 2
    end
end

function cset(x, y, c)
    if c == 0 then return end
    local b = 0x8000 + (y * 64) + (x \ 2)
    local d = peek(b)
    local v = x % 2 == 0 and ((d & 240) | c) or ((d & 15) | (c << 4))
    poke(b, v)
end

function scell(x, y)
    return { x = mid(0, x \ 16, 7), y = mid(0, y \ 16, 7) }
end

storedigits()

skull = "01111110,16666661,16616161,16616161,16666661,01166610,00011100"
skrows = split(skull, ",", false)
for k, row in ipairs(skrows) do
    skrows[k] = split(row, "")
end

function landmark(x, y)
    for sy, row in ipairs(skrows) do
        for sx, c in ipairs(row) do
            cset(flr(x) + sx, flr(y) + sy, c)
        end
    end
end

function minmax(x, y)
    return {
        min = {
            x = max(0, x - 1),
            y = max(0, y - 1)
        },
        max = {
            x = min(7, x + 1),
            y = min(7, y + 1)
        }
    }
end

function aabb(x1, y1, x2, y2, x3, y3, x4, y4)
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end

function spad(n)
    return sub('000000' .. n, -6)
end

class = setmetatable(
    {
        new = function(_ENV, tbl)
            return setmetatable(tbl or {}, { __index = _ENV })
        end,
        foo = function(_ENV)
            return x .. ',' .. y
        end
    },
    { __index = _ENV }
)

entity = class:new({
    x = 1,
    y = 2,
    f1 = function(_ENV, z)
        return tostring(x) .. "," .. tostring(y) .. "," .. tostring(z)
    end
})

player = class:new({
    x = 60,
    y = 60,
    health = 100,
    score = 0,
    ns = "",
    os = "",
    reset = function(_ENV)
    end,
    update = function(_ENV)
        if btn(0) then x -= 1 end
        if btn(1) then x += 1 end
        if btn(2) then y -= 1 end
        if btn(3) then y += 1 end
        x = max(0, min(x, 120))
        y = max(0, min(y, 120))
        cell = scell(x, y)
        local range = minmax(cell.x, cell.y)
        for cy = range.min.y, range.max.y do
            for cx = range.min.x, range.max.x do
                for e in all(cells:get(cx, cy)) do
                    if aabb(x, y, x + 7, y + 7, e.x, e.y, e.x + 7, e.y + 7) then
                        e:hit(10)
                        health -= 1
                        if health < 1 then
                            _G.stage = 2
                        end
                    end
                end
            end
        end
        if dt % 4 == 0 then
            local e, m = nil, 9999
            for enemy in all(enemies) do
                if enemy.d < m then
                    e, m = enemy, enemy.d
                end
            end
            if m < 9999 then
                local b = bullet:new()
                b:reset(e.x, e.y)
                add(bullets, b)
            end
        end
        if dt % 2 == 0 then
            os = ns ns = spad(score)
        end
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 7, y + 7, 7)
        print(health, 80, 120, 3)
        print(score, 100, 120, 3)
        -- print(cell.x .. ' ' .. cell.y, 80, 10, 3)

        for i = 1, #ns do
            -- if ns[i] != os[i] then
            --     print('\^w\^t' .. ns[i], 40 + i * 4, 0, 7)
            -- else
            --     print(ns[i], 40 + i * 4, 0, 7)
            -- end
            local nx = 40 + i * 4
            if ns[i] != os[i] then
                local n = number:new()
                n:reset(nx, 0, ns[i])
                add(numbers, n)
                printh('number ' .. ns[i])
            end
            print(ns[i], nx, 0, 7)
        end
    end
})

enemy = class:new({
    x = 60,
    y = 60,
    a = 0,
    d = 0,
    cell = nil,
    health = 2,
    dead = false,
    reset = function(_ENV)
        local a = rnd()
        x = cos(a) * 80 + 64
        y = sin(a) * 80 + 64
    end,
    hit = function(_ENV, amount)
        player.score += 10
        local pc = 5
        health -= amount
        if health < 1 then
            dead = true
            pc = 10
            landmark(x, y)
        end
        for i = 1, pc do
            local p = particle:new()
            p:reset(x + 4, y + 4, 9)
            add(particles, p)
        end
    end,
    update = function(_ENV)
        local dx = player.x - x
        local dy = player.y - y
        a = atan2(dx, -dy)
        dx = cos(a) * .5
        dy = -sin(a) * .5
        x += dx
        y += dy
        d = abs(player.x - x) + abs(player.y - y)
        cell = scell(x, y)
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 7, y + 7, 9)
        -- rect(cell.x * 16, cell.y * 16, cell.x * 16 + 15, cell.y * 16 + 15, 1)
    end
})

bullet = class:new({
    x = player.x + 4,
    y = player.y + 4,
    a = 0,
    cell = nil,
    dead = false,
    reset = function(_ENV, tx, ty)
        x = player.x + 4
        y = player.y + 4
        local dx = tx - x
        local dy = ty - y
        a = atan2(dx, -dy)
    end,
    update = function(_ENV)
        dx = cos(a) * 2
        dy = -sin(a) * 2
        x += dx
        y += dy
        if x < -4 or x > 127 or y < -4 or y > 127 then
            dead = true
            return
        end
        cell = scell(x, y)
        local range = minmax(cell.x, cell.y)
        for cy = range.min.y, range.max.y do
            for cx = range.min.x, range.max.x do
                for e in all(cells:get(cx, cy)) do
                    if aabb(x, y, x + 3, y + 3, e.x, e.y, e.x + 7, e.y + 7) then
                        e:hit(1)
                        dead = true
                        return
                    end
                end
            end
        end
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 3, y + 3, 12)
        -- rect(cell.x * 16, cell.y * 16, cell.x * 16 + 15, cell.y * 16 + 15, 2)
    end
})

particle = class:new({
    x = player.x + 4,
    y = player.y + 4,
    a = 0,
    c = 0,
    dead = false,
    reset = function(_ENV, sx, sy, sc)
        x = sx
        y = sy
        c = sc
        a = rnd()
        -- ttl = 10
        ttl = rnd(20) + 20
    end,
    update = function(_ENV)
        dx = cos(a) * 2
        dy = -sin(a) * 2
        x += dx
        y += dy
        if x < -4 or x > 127 or y < -4 or y > 127 then
            dead = true
            return
        end
        ttl -= 1
        if ttl < 1 then dead = true end
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 1, y + 1, c)
        -- pset(x, y, 9)
    end
})

number = class:new({
    x = player.x + 4,
    y = player.y + 4,
    a = 0,
    n = 0,
    ttl = 0,
    dead = false,
    reset = function(_ENV, sx, sy, sn)
        x = sx
        y = sy
        n = sn
        a = rnd()
        ttl = rnd(10) + 20
    end,
    update = function(_ENV)
        dx = cos(a)
        dy = -sin(a)
        x += dx
        y += dy
        if x < -4 or x > 127 or y < -4 or y > 127 then
            dead = true
            return
        end
        ttl -= 1
        if ttl < 1 then dead = true end
    end,
    draw = function(_ENV)
        print("\^w\^t" .. n, x, y, 7)
        -- pset(x, y, 9)
    end
})

bomb = class:new({
    x = player.x + 4,
    y = player.y + 4,
    a = 0,
    n = 0,
    ttl = 0,
    dead = false,
    reset = function(_ENV)
        x = rnd(107) + 10
        y = rnd(107) + 10
        -- n = sn
        -- a = rnd()
        ttl = rnd(120) + 120
    end,
    update = function(_ENV)
        ttl -= 1
        if ttl < 1 then dead = true end
        if aabb(x, y, x + 7, y + 7, player.x, player.y, player.x + 7, player.y + 7) then
            dead = true
            for enemy in all(enemies) do
                if enemy.d < 100 then
                    enemy:hit(10)
                end
            end
            for i = 1, 40 do
                local p = particle:new()
                p:reset(x + 4, y + 4, 14)
                add(particles, p)
            end
        end
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 7, y + 7, 14)
    end
})

grid = function()
    return {
        cells = { [0] = {}, {}, {}, {}, {}, {}, {}, {} },
        set = function(self, x, y, entity)
            if not self.cells[y] then self.cells[y] = {} end
            if not self.cells[y][x] then self.cells[y][x] = {} end
            add(self.cells[y][x], entity)
        end,
        get = function(self, x, y)
            if not self.cells[y][x] then return {} end
            return self.cells[y][x]
        end
    }
end

for i = 0, 20 do
    local e = enemy:new()
    e:reset()
    add(enemies, e)
end

function _update60()
    cells = grid()
    if t() > 20 then
        -- extcmd("reset")
        stage = 2
    end

    if stage == 1 then
        if #enemies < 40 then
            local e = enemy:new()
            e:reset()
            add(enemies, e)
        end

        for enemy in all(enemies) do
            enemy:update()
            if enemy.dead then
                del(enemies, enemy)
            else
                cells:set(enemy.cell.x, enemy.cell.y, enemy)
            end
        end

        player:update()

        for bullet in all(bullets) do
            bullet:update()
            if bullet.dead then
                del(bullets, bullet)
            end
        end

        for particle in all(particles) do
            particle:update()
            if particle.dead then
                del(particles, particle)
            end
        end

        for number in all(numbers) do
            number:update()
            if number.dead then
                del(numbers, number)
            end
        end

        if rnd() > .995 then
            local b = bomb:new()
            b:reset()
            add(bombs, b)
        end

        for bomb in all(bombs) do
            bomb:update()
            if bomb.dead then
                del(bombs, bomb)
            end
        end
    else
        if btn(4) then
            player:reset()

            stage = 1
        end
    end
    dt += 1
end

function _draw()
    --cls()
    memcpy(0x6000, 0x8000, 0x2000)
    -- memcpy(0x6000, 0x0000, 0x2000)

    for bullet in all(bullets) do
        bullet:draw()
    end
    player:draw()
    for enemy in all(enemies) do
        enemy:draw()
    end
    for particle in all(particles) do
        particle:draw()
    end
    for number in all(numbers) do
        number:draw()
    end
    for bomb in all(bombs) do
        bomb:draw()
    end

    if stage == 2 then
        drawstorednumber(player.ns, 13, 49, 6, 5, 5)
        drawstorednumber(player.ns, 12, 48, 12, 5, 5)
    end

    print(t(), 0, 0)
    print(stage, 0, 10)

    -- rectfill(124, 27, 127, 127, 2)
    -- rectfill(124, 127 - player.health, 127, 127, 3)
    rectfill(126, 27, 127, 127, 2)
    rectfill(126, 127 - player.health, 127, 127, 3)
end

__gfx__
00000000044444400444444004444440044444400444444004444440444444440000000077777700000000000000000000000000000000000000000000000000
00000000444ff444444ff444444ff444444444444444444444444444444ffff00000000077070700000000000000000000000000000000000000000000000000
000000004f1ff1f44f1ff1f44f1ff1f444444444444444444444444444fff1f00000000077070700000000000000000000000000000000000000000000000000
000000004ffffff44ffffff44ffffff444444444444444444444444444fffff00000000077777700000000000000000000000000000000000000000000000000
000000000fff1ff00fff1ff00fff1ff004444440044444400444444044fffff00000000000777000000000000000000000000000000000000000000000000000
0000000005555550055555f00f555550055555500555555005555550055555500000000000000000000000000000000000000000000000000000000000000000
000000000f5555f00f555110011555f0055555500555555005555550055ff5500000000000000000000000000000000000000000000000000000000000000000
00000000011001100110000000000110011001100110000000000110011101100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
