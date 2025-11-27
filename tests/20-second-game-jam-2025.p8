pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
_G = _ENV

memset(0x8000, 0, 0x2000)

poke(0x5f2e, 1)
pal({ [0] = 0, 0, -14, -5, 4, 5, -16, 7, -7, -8, 10, 11, 12, 13, -6, 15 }, 1)

extcmd("rec")

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
        end
    },
    { __index = _ENV }
)

player = class:new({
    x = 60,
    y = 60,
    health = 100,
    score = 0,
    -- ns = "",
    -- os = "",
    reset = function(_ENV)
        score = 0
        -- ns = spad(score)
        health = 100
        x = 60
        y = 60
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
                        health -= 2
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
                local d = abs(x - enemy.x) + abs(y - enemy.y)
                if d < m then
                    e, m = enemy, d
                end
            end
            if m < 9999 then
                local b = bullet:new()
                b:reset(e.x, e.y)
                add(bullets, b)
            end
        end
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 7, y + 7, 7)
    end
})

enemy = class:new({
    x = 60,
    y = 60,
    a = 0,
    cell = nil,
    health = 2,
    dead = false,
    reset = function(_ENV)
        local a = rnd()
        x = cos(a) * 80 + 64
        y = sin(a) * 80 + 64
    end,
    hit = function(_ENV, amount)
        player.score += 25
        local pc = 10
        health -= amount
        if health < 1 then
            dead = true
            pc = 20
            landmark(x, y)
        end
        for i = 1, pc do
            local p = rnd() < .6 and pixel:new() or block:new()
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
        cell = scell(x, y)
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 7, y + 7, 9)
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
        ttl = rnd(20) + 10
    end,
    update = function(_ENV)
        dx = cos(a) * 2
        dy = -sin(a) * 2
        x += dx
        y += dy
        if x < -3 or x > 127 or y < -3 or y > 127 then
            dead = true
            return
        end
        ttl -= 1
        if ttl < 1 then dead = true end
    end
})

block = particle:new({
    draw = function(_ENV)
        rectfill(x, y, x + 1, y + 1, c)
    end
})

pixel = particle:new({
    draw = function(_ENV)
        pset(x, y, c)
    end
})

number = class:new({
    x = 0,
    y = 0,
    s = 0,
    n = 0,
    ttl = 0,
    dead = false,
    reset = function(_ENV, sx, sy, sn, ss)
        x = sx
        y = sy
        n = sn
        s = ss
    end,
    update = function(_ENV)
        s -= 1
        if s < 1 then dead = true end
    end,
    draw = function(_ENV)
        drawstorednumber(n, x, y, 7, s, s)
    end
})

bomb = class:new({
    x = player.x + 4,
    y = player.y + 4,
    ttl = 0,
    dead = false,
    reset = function(_ENV)
        x = rnd(107) + 10
        y = rnd(107) + 10
        ttl = rnd(120) + 120
    end,
    update = function(_ENV)
        ttl -= 1
        if ttl < 1 then dead = true end
        if aabb(x, y, x + 7, y + 7, player.x, player.y, player.x + 7, player.y + 7) then
            dead = true
            for enemy in all(enemies) do
                local d = abs(x - enemy.x) + abs(y - enemy.y)
                if d < 100 then
                    enemy:hit(10)
                end
            end
            for i = 1, 80 do
                local p = rnd() < .6 and pixel:new() or block:new()
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

function reset()
    enemies = {}
    bullets = {}
    particles = {}
    numbers = {}
    bombs = {}
    dt = 0
    cells = {}
    stage = 1
    start = t()
    countdown = { n = 20, size = 0 }
    for i = 0, 20 do
        local e = enemy:new()
        e:reset()
        add(enemies, e)
    end
    ns = spad(0)
    os = ns
    player:reset()
end

reset()

function _update60()
    cells = grid()
    counter = t() - start

    if counter > 20 and stage == 1 then
        stage = 2
        dt = 0
    end

    if stage == 1 then
        if #enemies < counter * 3 then
            local e = enemy:new()
            e:reset()
            add(enemies, e)
        end

        if counter >= 15 then
            local n = 20 - flr(counter)
            if countdown.n == n then
                countdown.size = max(0, countdown.size - 1)
            else
                countdown = { n = n, size = n == 0 and 0 or 32 }
            end
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
        -- if time() > 20.8 then
        --     extcmd("video") stop()
        -- end
        printh(dt)
        if btn(🅾️) then
            reset()
        end
        if player.health > 0 then
            player.score += 100
            player.health -= 1
        end
        player.ns = spad(player.score)
    end

    for number in all(numbers) do
        number:update()
        if number.dead then
            del(numbers, number)
        end
    end

    dt += 1
end

function _draw()
    memcpy(0x6000, 0x8000, 0x2000)

    for number in all(numbers) do
        number:draw()
    end

    for bomb in all(bombs) do
        bomb:draw()
    end

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

    if countdown and countdown.size > 0 then
        drawstorednumber(countdown.n, 0, 0, 8, countdown.size, countdown.size)
    end

    rectfill(126, 27, 127, 127, 2)
    if player.health > 0 then
        rectfill(126, 127 - player.health, 127, 127, 3)
    end

    ns = spad(player.score)
    for i = 1, #ns do
        local nx = 48 + i * 4
        if ns[i] != os[i] then
            local n = number:new()
            n:reset(nx, 0, ns[i], (6 - i) * 3)
            add(numbers, n)
        end
        print("\^o1ff" .. ns[i], nx, 0, 7)
    end
    os = ns

    if stage == 2 then
        for oy in all({ 47, 49 }) do
            for ox in all({ 13, 15 }) do
                drawstorednumber(player.ns, ox, oy, 1, 5, 5)
            end
        end
        drawstorednumber(player.ns, 14, 48, 12, 5, 5)
        if dt > 300 then print("\^o1ffpress 🅾️ to restart", 27, 80, 7) end
    end
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
__label__
ppppppppppppppppppppppppppppppppppppppppppppppppppp07770777077707770777077700000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppp07070707070707070007070000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppp07070707077707770007077700000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppp07070707070700070007000700000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppp07770777077700070007077700000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppp0000000000000g000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000ggg000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000o00000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp0000000000000000000oo00000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000ppppppppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000ppppppppppppppppppp000000000000oo000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000ggppppppppppppppppppp00000oo00000oo000000gggggg000000000000000000000000000000000000000000000
000000000000000000000000000000000000ggppppppppppppppppppp00000oo0000000000000gg0g0g000000000000000000000000000000000000000000000
000000000000000000000000000000000000ggppppppppppppppppppp0000000qqqqqqqq00000gg0g0g000000000000000000000000000000000000000000000
000000000000000000000000000000000000ggppppppppppppppppppp0000000qqqqqqqq00000ggggoo000000000000000000000000000000000000000000000
0000000000000000000000000000gggggg0000ppppppppppppppppppp0000000qqqqqqqq0000000ggoo0o0000000000000000000000000000gggggg000000000
0000000000000000000000000000gg0g0g0000ppppppppppppppppppp0000000qqqqqqqq00000000000000000000000000000000000000000gg0g0g000000000
0000000000000000000000000000gg0g0g0000ppppppppppppppppppp0000000qqqqqqqq0000000000000000000000gggggg0000000000000gg0g0g0000000ii
0000000000000000000000000000gggggg0000ppppppppppppppppppp000000ooqqqqqqq0000000000000000000000gg0g0g0000000000000gggggg0000000ii
000000000000000000000000000000ggg00000ppppppppppppppppppp000000ooqqqqqqq0000000000000000000000gg0g0g000000000000000ggg00000000ii
00000000000000000000000000000000000000ppppppppppppppppppp0000000qqqqqqqq000000000000000000oo00gggggg00000000000000000000000000ii
00000000000000000000000000000000000000ppppppppppppppppppp0000000gggggg00000000000000000000oo0000ggg000000000000000000000000000ii
00000000000000000000000000000000000000ppppppppppppppppppp00gggg0gg0g0g000000000000000000000o0000000000000000000000000000000000ii
000000000000000oo000000000000000000000ppppppppppppppppppp00gg0g0gg0g0g00000000000000000000000000000000000000000000000000000000ii
000000000000000oo000000000000000000000ppppppppppppppppppp00gg0g0gggggg00000000000000000000000000000000000000000000000000000000ii
00000000000000000000000000000000000000ppppppppppppppppppp00ggggg00ggg00000000000000oo000000000000000000gggggg00000000000000000ii
00000000000000000000000000000000000000ppppppppppppppppppp0000ggg000000gggggg0000000oo000000000000000000gg0g0g00000000000000000ii
00000000000000000000000000000000000000ppppppppppppppppppp0000000000000ggoooooooo00000000gggggg000000000gg0g0g00000000000000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppgggg0g0000000ggoooooooo00000000gg0g0g000000000gggggg00000000000000000ii
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp0g0g0g0000000ggoooooooo00000000gg0g0g00000000000ggg000000000000000000ii
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp0g0g0g00ggggg00oooooooo00000000gggggg00000000000000000000000000000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppgggg0000gg0g0g0oooooooooooo000000ggg000000000000000000000000000000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppggg00000gg0g0g0oooooooooooo0000000000000000000oooooooo000000000000000ii
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp0000000oooooooooooooooooooo0000000000000000000oooooooo000000000000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppoooooo0oooooooooooooooooooo00000000000000gggggoooooooo000000000000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppoooooo0oooooooooooooooooooo00000000000000gg0g0oooooooo000000000000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppoooooo0oooooooooooooooooooo00000000000000og0g0oooooooo000000000000000ii
ppppppppppppp00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccc00000ccccc00ccccc00000ccccc00ccccc00000ccccc00ccccc00000ccccc000000000000ccccc00ccccc0000000000000000000000ii
ppppppppppppp0ccccc0ppp0ccccc00ccccc0ppp0ccccc00ccccc0ppp0ccccc00ccccc0oo00ccccc0g0g0g000000ccccc00ccccc0000000000000000000000ii
ppppppppppppp0ccccc0ppp0ccccc00ccccc0ppp0ccccc00ccccc0ppp0ccccc00ccccc0oo00ccccc0ggggg0gg000ccccc00ccccc0ggggg0000000000000000ii
ppppppppppppp0ccccc0ppp0ccccc00ccccc0ppp0ccccc00ccccc0ppp0ccccc00ccccc00000ccccc00ggg0g0g000ccccc00ccccc0g0g0g0000000000000000ii
ppppppppppppp0ccccc0ggg0ccccc00ccccc0ggg0ccccc00ccccc00000ccccc00ccccc00000ccccc0oooooooo000ccccc00ccccc0000000000000000000000ii
ppppppppppppp0ccccc0ggg0ccccc00ccccc000g0ccccc00ccccccccccccccc00ccccccccccccccc0oooooooooo0ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccc00000ccccc00ccccc00g00ccccc00ccccccccccccccc00ccccccccccccccc0oooooooooo0ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccc00g00ccccc00ccccc00go0ccccc00ccccccccccccccc00ccccccccccccccc0oooooooooo0ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccc00000ccccc00ccccc00go0ccccc00ccccccccccccccc00ccccccccccccccc0oooooooooo0ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccc0ggg0ccccc00ccccc000o0ccccc00ccccccccccccccc00ccccccccccccccc0oooooooooo0ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccc0g0g0ccccc00ccccc000o0ccccc00ccccc00000ccccc000000000000ccccc0oooooooooo0ccccc000000000000ccccc0000000000ggii
ppppppppppppp0ccccc0g0g0ccccc00ccccc000o0ccccc00ccccc00g00ccccc07770oooooo0ccccc0oooooooooo0ccccc0ggg00000000ccccc0000000000ggii
ppppppppppppp0ccccc0ggg0ccccc00ccccc000o0ccccc00ccccc00g00ccccc07770oooooo0ccccc0oooo0000oo0ccccc000000000000ccccc0000000000ggii
ppppppppppppp0ccccc0gg00ccccc00ccccc000o0ccccc00ccccc0gg00ccccc077oooooooo0ccccc0ooooooo00g0ccccc000000000000ccccc0000000000ggii
ppppppppppppp0ccccc00000ccccc00ccccc00000ccccc00ccccc00000ccccc077oooooooo0ccccc0ooooooo0000ccccc000000000000ccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc07ooooooooo0ccccc0ooooooo0000ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc0777ooooooo0ccccc0ooooooo0000ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00o0goooooo0ccccc0ooooooo0000ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00o0o0ooooo0ccccc0ooooooo0000ccccc00ccccccccccccccc000000000000ii
ppppppppppppp0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00g0o00oooo0ccccc0ooooooo0000ccccc00ccccccccccccccc000gggggg000ii
ppppppppppppp0000000000000000000000000000000000000000000000000000ggooo0ooo0000000ooooooo00000000000000000000000000000gg0g0g000ii
ppppppppppppppppppp0000000000000000ooooooooooooooooooooooooooooo00goooooooooooo0g000ggg000000000000000000000000000000gg0g0g000ii
ppppppppppppppppppp0000000gggggg000ooooooooooooooooooooooooooooo0g0o0oooooooooo0g0oooooooo0000000000gggggg0gg00000000gggggg000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppooooooogoooooooooooooogooooooooooooooooo000gg0g0g00g0000000000ggg0000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppooooo00ggoo00oooooooo00ooooooooooooooooo000gg0g0g00g00000000000000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppooggg0g00o000ooooooooogooooooooooooooooo000gggggg0gg00000000000000000ii
pppppppppppppppppppppppppp000000000000000000000pppp0000000og0g000000000ooo00000000000000000000000000000000gg000000000000000000ii
pppppppppppppppppppppppppp077707770777007700770ppp007777700g0g077700770ooo07770777007707770777077707770ggg00000000000000000000ii
pppppppppppppppppppppppppp070707070700070007000ppp077000770ggg007007070ooo07070700070000700707070700700g0g00000000000000000000ii
pppppppppppppppppppppppppp077707700770077707770ppp077070770oooo07007070ooo07700770077700700777077000700g0g00000000000000000000ii
pppppppppppppppppppppppppp070007070700000700070ppp077000770oooo07007070ooo0707070000070070070707070070gggg00000000000000000000ii
pppppppppppppppppppppppppp070p07070777077007700ppp007777700000g07007700ooo0707077707700070070707070070ggg000000000000000000000ii
pppppppppppppppppppppppppp000p0000000000000000ppppp0000000ggg0g0000000oooo000000000000o000000000000000000000000oooooooo0000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppoooooooooooooo0000gggggg0oooooooo000000000000000000000oooooooo0000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppoooooooooooooo000000ggg0goooooooo000000000000000000000oooooooo0000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppoooooooooooooo00000000000oooooooo000000000000000000000oooooooo0000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppoooooooooooooo000000g00ggoooooooo000000000000000000000oooooooo0000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppooooooogg000gggggg0000g00oooooooo000000000000000000000oooooooo0000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppooooooog0000gg0gog0000000oooooooo000000000000000000000oooooooo0000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppooooooo00000gg0g0g000000000000000000000000000000000000oooooooo0000000ii
pppppppppppppppppppppppppppppppppppppppppppppppppppppppppooooooo00000gogggg00000000gggggg0000000000000000000000000000000000000ii
ppppppppppppppppppppppppppppppppppppppppppppppppppppppppp00000000000000000000000000gg0g0g0000000000000000000000000000000000000ii
0gg0g0g000000000000000000ggg00000000000000000000000000000000000000000gggggg000000000g0g0g0000000000000000000000000000000000000ii
0gg0g0000000000000000000000000000gggggg000000000000000000000000000000gg0g0g000gggggg0gggg0000000000000000000000000000000000000ii
0ggg000000gg000000000000000000000gg0g0g0gggg00000000oooooooo000000000gg0g0g000gg0g0g0ggg000gggggg0gg00000000g0000gggggg0000000ii
0000gggggg0g000000000000000000000gg0g0g00g0g00000000oooooooo000000000gggggg000gg0g0g0000000gg0g0g00g00gggggg00000gg0g0g0000000ii
0000gg0g0g0g000000000000000000000gggggg00g0g00000000oooooooo00000gggg00ggg0000gggggg0000000gg0g0g00g00gg0g0g00000gg0g0g0000000ii
0000gg0g0g0g00000000000000000000000ggg0ggggg00000000oooooooo00000gg0g0g000000000ggg00000000gggggg0gg00gg0g0g00000gggggg0000000ii
0000gggggg000000000000000000000000000000ggg000000000oooooooo00000gg0g0g0000000000000000000000gggooooooooggg00000000ggg00000000ii
000000ggg00000000000000oooooooo000000000000000000000oooooooo00000gggggg0000000000000000000000000oooooooogg0gggggg0000000000000ii
0000000000000oo0ooooooooooooooo00gggggg0000000000000oooooooo0000000ggg0000000000000000000000ggggoooooooo000gg0g0g0000000000000ii
0000000000000oo0ooooooooooooooo00gg0g0g0000000000000oooooooo00000000000000000000000000000000gg0goooooooo000gg0g0g0000000000000ii
0000000000000000ooooooooooooooo00gg0g0g00000000000000000000000000000000000000000000000000000gg0goooooooo000gggggg0000000000000ii
0000000000000000ooooooooooooooo00gggggg00000000000000000000000000000000000000000000000000000ggggoooooooo00000ggg00000000000000ii
0000000000000000ooooooooooooooo0000ggg00000000000000000000000000000000000000000000000000000000ggoooooooo0000000000000000000000ii
0000000000000000ooooooooooooooo0000000000000000000000000000000000000gggggg0000000000000000000000oooooooo0000000000000000000000ii
0000000000000000ooooooooooooooo000000000000000000000000000gggggg0000gg0g0g0000000000000000000000000000000gggggg000000000000000ii
0000000000000000oooooooogggg000000000000000000000000000000gg0g0g0000gg0g0g0000000000000000000000000000000gg0g0g000000000000000ii
0000000000000000000000gg0g0g000000000000000000000000000000gg0g0g0000gggggg0000000000000000000000000000000gg0g0g000000000000000ii
0000000000000000000000gg0g0g0000000000000000000000gggggg00gggggg000000ggg00000000000000000000000000000000gggggg000000000000000ii
0000000000000000000000gggggg0000000000000000000000gg0g0g0000ggg00000000000000000000000000000000000000000000ggg00000000gggggg00ii
000000000000000000000000ggg00000000000000000gggggg0g0g0g00000000000000000000000000000000000000000000000000000000000000gg0g0g00ii
00000000000000000000000000000000000000000o00gg0g0g0ggggg00000000000000000000000000000000000000000000000000000000000000gg0g0g00ii
00000000000000000000000000000000000000000000gg0g0g00ggg000000000000000000000000000000000000000000000000000000000000000gggggg00ii
00000000000000000000000000000000000000000000gggggg0000000000000000000000000000gggggg000000000000000000000000000000000000ggg000ii
0000000000000000000000000000000000000000000000ggg00000000000000000000000000000gg0g0g000000000000000000000000000000000000000000ii
000000000000000000000000000000000000000000000000000000000000000000000000000000gg0g0g000000000000000000000000000000000000000000ii
000000000000000000000000000000000000000000000000000000000000000000000000000000gggggg000000000000000000000000000000000000000000ii
00000000000000000000000000000000000000000000000000000000000000000000000000000g00ggg0000000000000000000000000000000000000000000ii
00000000000000000000000000000000000000000000000000000000000000000000000000000ggg0000000000000000000000000000000000000000000000ii
0000000000000000000000000000000000000000000000000000000000000000000000000000000ggg00000000000000000000000000000000000000000000ii
0000000000000000000000000000000000oooooooo000000000000000000000000000000000000000000000000000000000000000000000000000000000000ii
0000000000000000000000000000000000oooooooo000000000000000000000000000000000000000000000000000000000000000000000000000000000000ii
0000000000000000000000000000000000oooooooo000000000000000000000000000000000000000000000000000000000000000000000000000000000000ii
0000000000000000000000000000000000oooooooo000000000000000000000000000000000000000000000000000000000000000000000000000000000000ii

