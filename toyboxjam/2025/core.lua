dt = 0
stage = 1
stages = {
    {
        --[[
        intro
        ]]
        next = function(self)
            stage = 2
            stages[stage]:init()
        end,
        init = function(self)
            cartdata("5ou1_tbj2005_1")
            data = { exists = 0, player_x = 1, player_y = 2 }
            dt = 0
            player:reset()
            for entity in all(entities) do
                entity:reset()
            end
            local cdata = dget(data.exists) == 1
            player.x = cdata and dget(data.player_x) or 16
            player.y = cdata and dget(data.player_y) or 240
        end,
        update = function(self)
            if btnp(🅾️) or btnp(❎) then
                self:next()
            end
        end,
        draw = function(self)
            print("\^o0ffpress 🅾️ to start", 31, 60, 13)
        end
    },
    {
        --[[
        game
        ]]
        init = function(self)
            player.active = true
            player.button.down = true
        end,
        update = function(self)
            if player.done then
                stage = 3
                stages[stage]:init()
                return
            end
        end,
        draw = function(self)
            -- do nothing
        end
    },
    {
        --[[
        outro
        ]]
        next = function(self)
            stage = 1
            stages[stage]:init()
        end,
        init = function(self)
            dt = 0
        end,
        update = function(self)
            if dt > 120 then
                if btnp(🅾️) or btnp(❎) then
                    self:next()
                end
            end
            -- player:death()
        end,
        draw = function(self)
            print("\^w\^t\^o0ffgame over", 31, 52, 8)
            if dt > 120 then
                print("\^o0ffpress 🅾️ to restart", 29, 72, 12)
            end
        end
    }
}

function _init()
    stages[stage]:init()
    menuitem(
        1,
        "reset checkpoint",
        function()
            dset(data.exists, 0)
            dset(data.player_x, 0)
            dset(data.player_y, 0)
            stage = 1
            stages[stage]:init()
        end
    )
    song = 21
    playing = true
    music(song)
    menuitem(
        2,
        "toggle music",
        function()
            playing = not playing
            music(playing and song or -1)
        end
    )
end

function _update60()
    player:update()
    for entity in all(entities) do
        entity:update()
    end
    for particle in all(particles) do
        particle:update()
        if particle.done then
            del(particles, particle)
        end
    end
    if dt % 2 == 0 then
        scroll_tile(16)
    end
    dt += 1

    stages[stage]:update()
end

function _draw()
    cls()
    camera(mid(0, player.rx - 64, 896), mid(0, player.ry - 64, 128))
    pal(3, 0)
    map()
    pal()

    player:draw()
    for entity in all(entities) do
        entity:draw()
    end
    for particle in all(particles) do
        particle:draw()
    end
    camera()
    print(player.rx, 0, 0, 9)
    print(player.ry, 20, 0, 9)
    print(mid(0, player.rx - 64, 896), 40, 0, 3)
    print(player.frame, 60, 0, 4)
    print(dt, 80, 0, 4)
    print(player.wall, 100, 0, 8)
    print(#particles, 0, 10, 10)

    if player.keys > 0 then
        rectfill(0, 118, 6 * player.keys - 1, 127, 0)
        for k = 1, player.keys do
            spr(30, (k - 1) * 6 - 1, 119)
        end
    end

    stages[stage]:draw()
end