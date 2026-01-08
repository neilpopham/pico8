pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
printh('===')

stages = {
    set = function(new)
        _stage = new
    end,
    check = function()
        if _stage then
            stage = _stage
            stage:init()
            _stage = nil
        end
    end,
    shared = function()
        print("\^w\^tshared", 0, 20, 2)
    end
}

stages.intro = {
    init = function(self)
        printh("init intro")
    end,
    update = function(self)
        if btnp(🅾️) or btnp(❎) then
            stages.set(stages.game)
        end
    end,
    draw = function(self)
        stages.shared()
        print("\^w\^tintro", 0, 0, 7)
    end
}

stages.game = {
    init = function(self)
        printh("init game")
    end,
    update = function(self)
        if btnp(🅾️) or btnp(❎) then
            stages.set(stages.outro)
        end
    end,
    draw = function(self)
        print("\^w\^tgame", 0, 0, 8)
    end
}

stages.outro = {
    init = function(self)
        printh("init outro")
    end,
    update = function(self)
        if btnp(🅾️) or btnp(❎) then
            stages.set(stages.intro)
        end
    end,
    draw = function(self)
        stages.shared()
        print("\^w\^toutro", 0, 0, 9)
    end
}

function _init()
    stage = stages.intro
    stage:init()
end

function _update60()
    stage:update()
end

function _draw()
    cls()
    stage:draw()
    stages:check()
end
