pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
_G = _ENV

memset(0x8000, 0, 0x2000)

poke(0x5f2e, 1)
pal({ [0] = 0, 0, -14, -5, 4, 5, -16, 7, -7, -8, 10, 11, 12, 13, -6, -2 }, 1)

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

function spad(n, l)
    l = l or -6
    return sub('000000' .. n, l)
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
                            nextstage()
                        end
                    end
                end
            end
        end
        if dt % 4 == 0 then
            local e, m = nil, 9999
            for enemy in all(enemies) do
                if enemy.visible then
                    local d = abs(x - enemy.x) + abs(y - enemy.y)
                    if d < m then
                        e, m = enemy, d
                    end
                end
            end
            if m < 9999 then
                local b = bullet:new()
                b:reset(e.x, e.y)
                add(bullets, b)
                sfx(0)
                if _G.dual > 0 then
                    local b = bullet:new()
                    b:reset(2 * x - e.x, 2 * y - e.y)
                    add(bullets, b)
                end
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
    visible = false,
    dead = false,
    reset = function(_ENV)
        local a = rnd()
        x = cos(a) * 90 + 64
        y = sin(a) * 90 + 64
        cell = scell(x, y)
    end,
    hit = function(_ENV, amount)
        player.score += 50
        local pc = 10
        health -= amount
        if health < 1 then
            dead = true
            pc = 20
            landmark(x, y)
            sfx(1)
        end
        for i = 1, pc do
            local p = rnd() < .6 and pixel:new() or block:new()
            p:reset(x + 4, y + 4, 9)
            add(particles, p)
        end
    end,
    update = function(_ENV)
        if freeze > 0 then return end
        local dx = player.x - x
        local dy = player.y - y
        a = atan2(dx, -dy)
        dx = cos(a) * .5
        dy = -sin(a) * .5
        x += dx
        y += dy
        if not visible then
            visible = x > -8 and x < 128 and y > -8 and y < 128
        end
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
        ttl = rnd(20) + 20
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

drop = class:new({
    x = 0,
    y = 0,
    ttl = 0,
    dead = false,
    reset = function(_ENV)
        x = rnd(107) + 10
        y = rnd(107) + 10
        ttl = rnd(120) + 120
    end
})

bomb = drop:new({
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
                sfx(2)
            end
        end
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 7, y + 7, 14)
    end
})

freeze = drop:new({
    update = function(_ENV)
        ttl -= 1
        if ttl < 1 then dead = true end
        if aabb(x, y, x + 7, y + 7, player.x, player.y, player.x + 7, player.y + 7) then
            dead = true
            _G.freeze += 150
            sfx(3)
        end
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 7, y + 7, 12)
    end
})

dual = drop:new({
    update = function(_ENV)
        ttl -= 1
        if ttl < 1 then dead = true end
        if aabb(x, y, x + 7, y + 7, player.x, player.y, player.x + 7, player.y + 7) then
            dead = true
            _G.dual += 300
            sfx(4)
        end
    end,
    draw = function(_ENV)
        rectfill(x, y, x + 7, y + 7, 15)
    end
})

dropmakers = { bomb, freeze, dual }

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
    drops = {}
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
    freeze = 0
    dual = 0
    score = nil
    bonus = 0
    player:reset()
end

reset()

function nextstage()
    stage = 2
    dt = 0
end

function _update60()
    if stage == 1 then
        cells = grid()
        counter = t() - start

        if counter > 20 then
            player.score += 1000
            nextstage()
        end

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

        if rnd() > .996 then
            local idx = flr(rnd(3)) + 1
            local drop = dropmakers[idx]
            local d = drop:new()
            d:reset()
            add(drops, d)
        end

        for drop in all(drops) do
            drop:update()
            if drop.dead then
                del(drops, drop)
            end
        end
    else
        if not score then
            score = player.score
            health = player.health
            bonus = 0
        end

        if player.health > 0 then
            bonus += 100
            score = player.score + bonus
            player.health -= 1
        end

        player.ns = spad(score)

        if btn(🅾️) then
            reset()
        end
    end

    for number in all(numbers) do
        number:update()
        if number.dead then
            del(numbers, number)
        end
    end

    if freeze > 0 then freeze -= 1 end
    if dual > 0 then dual -= 1 end

    dt += 1
end

function _draw()
    memcpy(0x6000, 0x8000, 0x2000)

    for number in all(numbers) do
        number:draw()
    end

    for drop in all(drops) do
        drop:draw()
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
        if dt > 240 then print("\^o1ffpress 🅾️ to restart", 27, 92, 7) end
        print("\^o1ffhealth bonus", 20, 80, 11)
        print("\^o1ff" .. spad(bonus, -5), 90, 80, 11)
    end
end

__label__
000000000000000000000000000000oooooooo00000000000000777077007770777077707770o000000000000000000000000000000000000000000000000000
000000000000000000000000000000oooooooo00000000000000707007000070707070707070o000000000000000000000000000000000000000000000000000
000000000000000000000000000000oooooooo00000000000000707007000770777070707070o000000000000000000000000000000000000000000000000000
000000000000000000000000000000oooooooo00000000000000707007000070707070707070o00000000000000000000000000000000000000000oooooooo00
000000000000000000000000000000oooooooo00000000000000777077707770777077707770000000000000000000000000000000000000000000oooooooo00
000000000000000000000000000000oooooooo00000000000000000000000000000000000000000000000000000000000000000000000000000000oooooooo00
000000000000000000000000000000oooooooo0000000000000000000000oooooooo00000000000000000000000000000000000000000000000000oooooooo00
000000000000000000000000000000000000000000000000000000000000oooooooo00000000000000000000000000000000000000000000000000oooooooo00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000oooooooo00
00000000000000000000000000000gggggg00000000000gggggg00000gggggg0000000000000000000000000000000000000000000000000000000oooooooo00
00000000000000000000000000000gg0g0g00000000000gg0g0g00000gg0g0g0000000000000000000000000000000000000000000000000000000oooooooo00
00000000000000000000000000000gg0g0g00000000000gg0g0g00000gg0g0g0oo00000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000gggggg0oooooooo00gggggg00000gggggg0oo00000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000ggg00oooooooo0000ggg00000000ggg000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000oooooooo000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000oooooooo000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000oooooooo000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000oooooooo0gggggg00000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000oooooooo0gg0g0g00000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000oooooooo0gg0g0g00000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000gggggg000000000000000000000000000000000000000000000000o0000000000000000000000000000
00000000000000000000000000000000000000000000000ggg000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000gggggg00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000gg0g0g00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000gg0g0g00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000gggggg000000000000000gggggg00oooooooo00000000000000000000000o0000000000000000000000000000000000000000000000000000000000
00000000000ggg000000000oooooooo0000g00oooooooo00000000000000000000000000000000000o00000000000000000000000000000000000000000000ii
00000000000000000000000oooooooo000g000oooooooo0000000000000000000000ooo00000oo000000000000000000000000000000000000000000000000ii
gggggg00000000000000000ooooooooggg0000oooooooo00000000000000000000000oo00000oo00o000000000000000000000000000000000000000000000ii
gg0g0g00000000000000000oooooooog0g0000oooooooo00000000000000000000000000oo0000000000o00000000000000000000000000000000000000000ii
gg0g0g00000000000000000oooooooo0000000oooooooo00000000000o00000000000000oo0000000000000000000000000000000000000000000000000000ii
gggggg00000000g00000000ooooooooggggg00oooooooo00000000oo0000000000000000000000000000000000000000000000000000000000000000000000ii
00ggg000gggggg000000000oooooooog0g0g00ooooooooggg00000oooo000000000000o000000000000000000o0000gggggg00000000000000000000000000ii
o0000000gg0g0g00000000ooooooooog0g0g0000000gg0g0g00o0000ooggoogg000000000000000000000000000000gg0g0g00000000000000000000000000ii
o0000000gg0g0g0000000000000000gggggg0000000gg0g0g000000000ggoo0g00000000000gggggg00000000000o0gg0g0g00000000000000oo0000000000ii
o0000000gggggg000000000000000g00ggg0gggggg0gggggg00oo00000gg0g0g00000000000gg0g0oooooooo000000gggggg00000000000000oo0000000000ii
o000000000ggg0ggg000000000000gg000000g0g0g000ggg000oo00000gggggg00000000000gg0g0oooooooo00000000ggg000000000000000000000000000ii
o00000000g0000g0g000000000000gggggg00g0g0g00000000gggggg0000ggg000000000000gggggoooooooo00000000000000000000000000000000000000ii
o00000000g0gg0g0g00000000000000ggg0g0ggggg00000000gg0g0g000000000000000000000gggoooooooo00000000000000000000000000000000000000ii
o0000000000gggggg0000000000000g000gg00ggg000000000gg0g0g000000000000000000000000oooooooo00000000000000000000000000000000000000ii
o000000000g00ggg0000000000000000000000000000000000gggggg0000000000000gggggg00000oooooooog0000000000000000000000000000000000000ii
0000000000gg00000000000000000000gggggg0gg00000gg000000g0gggggg0000000gg0g0g00000oooooooog0000000000000000000000000000000000000ii
0000000000gg0g0g0000000000000000gg0g0g0g00000000gggggg00gg0g0g000000oooooooo0000oooooooooo000000000000000000000000000000000000ii
0000000000gggggg0000000000000000gg0g0g000gggggg0ggog0g00gg0g0g000000oooooooo000000oooooooo000000000o00000000000000000000000000ii
000000000000ggg00000000000000000gggggg000g000000goog0g00gggggg00ggggoooooooo000000oooooooo00000000000000000000000000000000ggggii
000000000000000000000gggggg0000000ggg0o000gggg00googgg0000ggg000gg0goooooooo000000oooooooo00000000000000000000000000000000gg0gii
000000000000000000000000000000000000000000gg0g0000000000000000000000000000000000000000000000000000000000000000000000000000gg0gii
00000000000000ccccccccccccccc00cccccccccc0oo0000ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00000000ggggii
00000000000000ccccccccccccccc00cccccccccc0oo0g00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc0000000000ggii
000000000000g0ccccccccccccccc00cccccccccc0oo0g00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
000000000000g0ccccccccccccccc00cccccccccc0oo0gg0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
00000000000000ccccccccccccccc00cccccccccc0oo0gg0ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
0000000000ggg0ccccc00000ccccc0000000ccccc0oo00000000000000ccccc00ccccc00000ccccc00ccccc00000ccccc00ccccc00000ccccc000000000000ii
0000000000gg00ccccc0oog0ccccc0ooo000ccccc0ooggg0000000oo00ccccc00ccccc00000ccccc00ccccc0gg00ccccc00ccccc000g0ccccc000000000000ii
0000000000gg00ccccc0oog0ccccc0ooo000ccccc0oog0g0000000oo00ccccc00ccccc0gg00ccccc00ccccc0ggg0ccccc00ccccc000g0ccccc000000000000ii
0000000000ggg0ccccc0oo00ccccc00g0000ccccc0g0g0g00000000000ccccc00ccccc0g000ccccc00ccccc000g0ccccc00ccccc00000ccccc000000000000ii
000000000000g0ccccc0oo00ccccc0gg0000ccccc0ggggg000go000000ccccc00ccccc00000ccccc00ccccc0g000ccccc00ccccc00000ccccc000000o00000ii
00000000000000ccccc00000ccccc0g00000ccccc00ggg0000gg0cccccccccc00ccccccccccccccc00ccccc0g000ccccc00ccccc00000ccccc000000000000ii
00000000000000ccccc00000ccccc000ooo0ccccc00000000oog0cccccccccc00ccccccccccccccc00ccccc0g000ccccc00ccccc00000ccccc000oooooooooii
00000000000000ccccc00000ccccc000ooo0ccccc00000000oog0cccccccccc00ccccccccccccccc00ccccc00000ccccc00ccccc00000ccccc000oooooooooii
00000000000000ccccc0gg00ccccc0000000ccccc00000oooooo0cccccccccc00ccccccccccccccc00ccccc00000ccccc00ccccc00000ccccc00goooooooo0ii
00000000000000ccccc00g00ccccc0000gg0ccccc00000oooooo0cccccccccc00ccccccccccccccc00ccccc00000ccccc00ccccc00000ccccc00goooooooo0ii
00000000000000ccccc00g00ccccc0000gg0ccccc0ggggoooooo000000ccccc00ccccc00000ccccc00ccccc00000ccccc00ccccc00000ccccc00goooooooo0ii
00000000000000ccccc0gg00ccccc0000gg0ccccc0g0g0oooooooo0000ccccc00ccccc0ooo0ccccc00ccccc00000ccccc00ccccc00000ccccc00goooooooo0ii
00000000000000ccccc0g000ccccc0000gg0ccccc0g0g0oooooooo0gg0ccccc00ccccc0ooo0ccccc00ccccc00000ccccc00ccccc00o00ccccc000oooooooooii
00000000000000ccccc00000ccccc0000000ccccc0ggggooooooooogg0ccccc00ccccc0o770ccccc00ccccc0ggg0ccccc00ccccc00000ccccc000oooooooo0ii
00000000000000ccccc00000ccccc0000000ccccc00000000000000000ccccc00ccccc00000ccccc00ccccc00000ccccc00ccccc00000ccccc000000000000ii
00000000000000ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc000000000000ii
00000000000000ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00gggggg0000ii
00000000000000ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00gg0g0g0000ii
00000000000000ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00gg0g0g0000ii
00000000000000ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00ccccccccccccccc00gggggg0000ii
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ggg00000ii
0000000000000gg0g0g0000000gg0g0g0gg0g0g000ggggg00ooooooooooooooooooo0ggg0gggoo00o00ooooooooooo0000000o0000000gg0g0g00000000000ii
0000000000000gggggg0000000goog0g0gggggg00000ggg0gooooooooooooooooooo0000g000ooggoooooooooooooo000000000000000gggggg00000000000ii
000000000000000ggg00000000googgg000ggg0ggggg0000gooooooooooooooooooooooog0o0gg0goooooooooooooo00000000000000000ggg000000000000ii
0000000000000000000000000000ggg00gg000ggog0g0g00ggogoooooooooooooooooooog0oogg0goooooooooooooo00000000000000000000000000000000ii
00000000000000000000000000000000g00000gg0g0g0g00ggggoooooooooooooooooooo00ooggggooooooooooo00000oo0000000000000000000000000000ii
0000000000000000000000000000000000000000000000g000000000000000000000oooooooo00ggoooooooo00000000000000000000000000000000000000ii
000000000000000oooo0b0b0bbb0bbb0b000bbb0b0b000g0bbb00bb0bb00b0b00bb0ooooooooog00oooooooo00bbb0bbb0bbb0bbb0bbb00000000000000000ii
000000000000000oooo0b0b0b000b0b0b0000b00b0b00000b0b0b0b0b0b0b0b0b000ooooooo0oo0ooooooooo00b0b0b0b0b0b0b0b0b0b00000000000000000ii
000000000000000oooo0bbb0bb00bbb0b0000b00bbb0ggg0bb00b0b0b0b0b0b0bbb0ooooooo0oo00oooooooo00b0b0b0b0b0b0b0b0b0b00000000000000000ii
000000000000000oooo0b0b0b000b0b0b0000b00b0b0gg00b0b0b0b0b0b0b0b000b0ooooooogg0000000000gg0b0b0b0b0b0b0b0b0b0b00000000000000000ii
000000000000000oooo0b0b0bbb0b0b0bbb00b00b0b0gg00bbb0bb00b0b00bb0bb00ooooooo0g0000000000gg0bbb0bbb0bbb0bbb0bbb00000000000000000ii
000000000000000oooo0000000000000000000000000ggg00000000000000000000oooooooo0g0000000000gg0000000000000000000000000000000000000ii
000000000000000ooooooooooooogggg0gg00000000000ogg0g00g0g0gg0g00oooooooooooogg0000000000ggoogg00oo00000000000000000000000000000ii
000000000000000oooooooo00000ggg0g0g0000000000g000gg0gg0g0googggoooooooo00ggg0000000000000oog0000000000000000000000000000000000ii
000000000000000000000o0000000000g0g0000000000000000gg0ggg0oogg0ooooooooo000000000000000o00000000000000000000000000000000000000ii
00000000000000000000000000000gggggg000000000gggggg00000000000000000000gggggg00000000000000000000000000000000000000000000000000ii
0000000000000000000000000000000ggg0000000gg0gg0g0g0gggggg0000oooooooo000ggg000000000000000000000000000000000000000000000000000ii
000000000000000000000000gg000000000000000000000g0g00000000000o0000000000000000000000000000000000000000000000000000000000000000ii
000000000000000000000000gg077707770777007700770ggg007777700ggo0777007700000777077700770777077707770777000000000000000000000000ii
0000000000000000000000g0gg070707070700070007000gg00770007700go0070070700000707070007000070070707070070000000000000000000000000ii
000000000000000000000000gg07770770077007770777000g0770707700goo070070700000770077007770070077707700070000000000000000000000000ii
00000000000000000gggggg000070007070700000700070g00077000770ggoo070070700000707070000070070070707070070000000000000000000000000ii
00000000000000000gg0g0g0gg0700070707770770077000gg007777700g0oo070077000000707077707700070070707070070000000000000000000000000ii
00000000000ggggg0gg0g0g0gg00000000000000000000g0gg0000000000goo000000000000000000000000000000000000000000000000000oo0000000000ii
00000000000gg0g00gggggg000000000gggggg0000gggg00gg0g0g0000g0g0000000000000oooo000000000oooooooo00000000oooooooo000oo0000000000ii
00000000000gg0g0g00ggg000000000000ggg0000000ggg0gggggg0gggggg0000000000000oooo000000000oooooooo00000000oooooooo000000000000000ii
00000000000gggggg00o00000oo00000000000000000000000ggg0000ggg000000000000000000000000000000000oo00000gggoooooooo000000000000000ii
0000000000000ggg000000000oo00000000000000000000ggg00000000000oo000000000000000000000000000o000000000gg0oooooooo000000000000000ii
00000000000000000000000000000000000000000000000go0g0g00000000000000000000000000000000000000000000000gg0oooooooo000000000000000ii
00000000000000000000000000000000000000000000000gg0g0g00000000000000000000000000000000000000000000000gggoooooooo0000000o0000000ii
00000000000000000000000000000000000000000000000ggggggoooooooo00000000000000000000000000o00000000000000goooooooo000000000000000ii
000000000000000000000000gggggg0000000000000000000ggg0oooooooo0000000000gggggg00000000000000000000000000oooooooo000000000000000ii
000000000000000000000000gg0g0g00000000000000000000000oooooooo000gggggg0gg0g0g0000000000000000000000000000000000000000000000000ii
000000000000000000000000gg0g0g0ggg0000000000000000000ooooooooo00gg0g0g0gg0g0g0000000000000000000000000000000000000000000000000ii
000000000000000000000000gggggg00000000000000000000000ooooooooo0ogg0g0g0gggggg0000000000000000000000000000oooooooo0000000000000ii
00000000000000000000000000ggg0ooggggg000oo00000000000ooooooooo00gggggg000ggg00000000000000000000000000000oooooooo0000000000000ii
00000000000000000000000000000goog0g0g000oo00000000000ooooooooo0000ggg000000000000000000000000000000000000oooooooo0000000000000ii
0000000000000000000000000000000gg0g0g0000000000000000ooooooooo00000000000000oooooooo000000000000000000000ooooooooo000000000000ii
0000000000000000000000000000000gggggg00000000000000000oooooooo0gggggg0000000oooooooo000000000000000000000ooooooooo000000000000ii
000000000000000000000000000000000ggg000000000000000000oooooooo0gg0g0g0000000oooooooo000000000000000000000oooooooo0000000000000ii
00000000000000gggggg00000000000oo000000000000000000000oooooooo0gg0g0g0000000oooooooo000000000000000000000oooooooo0000000000000ii
00000000000000gg0g0g00000000000oo000000000000000000000000000000gggggg0000000oooooooo000000000000000000000oooooooo0000000000000ii
00000000000000gg0g0g000000000000000000000000000000000000000000000ggg00000000oooooooo000000000000gggggg00000oo0o000000000000000ii
00000000000000gggggg0000000000oooooooo00000000000000000000000oooooooo0000000oooooooo000000000000gg0gog00000oo00000000000000000ii
0000000000000000ggg00000000000oooooooo00000000000000000000000oooooooo0000000oooooooo000000000000gg0g0g000000000000000000000000ii
000000000000000000000000000000oooooooo00000000000000000000gggoooooooo000000000000000000000000gg0gggggg000000000000000000000000ii
000000000000000000000000000000oooooooo00000000000000000000gg0oooooooo000000000000000000000000gg000ggg0000000000000000000000000ii
000000000000000000000000000000oooooooo00000000000000000000gg0oooooooo000000000000000000000000gg0g00000000000000000000000000000ii
000000000000000000000000000000oooooooo00000000000000000000gggoooooooo00ooo0000000000000000000gggggg000oo0000000000000000000000ii
000000000000000000000000000000oooooooo0000000000000000000000goooooooo00oo0000000000000000000000ggg0000oo0000000000000000000000ii
0000oooooooo000000000000000000oooooooo00000000000000000000000oooooooogg00000000000000o0o00000000000000000000000000000000000000ii
0000oooooooo00000000000000000000000000000000000000000000000000000gg0g0g0000000000000000000000000000000000000000000000000000000ii
0000oooooooo00000000000000000000000000000000000000000000000000000gg0g0g0000000000000000000000000000000000000000000000000000000ii
0000oooooooo00000000000000000000000000000000000000000000000000000gggggg0000000000000000000000000000000000000000000000000000000ii

__sfx__
000100000f2200d220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000022330203301c32014310000000000000000000000000000000000000000000000000000000000000000000f0500f0500f0500f050120500f050120501205012050000000000000000000000000000000
0001000022670206701e6701c6701a670196701767013670106700e6700c6700a6600765004640026300061000600000000000000000000000000000000000000000000000000000000000000000000000000000
000100003335033350333500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b0502d0502f0603207034070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
