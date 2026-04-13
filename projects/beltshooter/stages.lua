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
        -- do shared drawing
    end
}

stages.intro = {
    init = function(self)
    end,
    update = function(self)
    end,
    draw = function(self)
        stages.shared()
    end
}

stages.game = {
    init = function(self)
        make_level(1)
    end,
    update = function(self)
        cam.x += 1
        if btnp(4) then cam:shake(1) end
        if btnp(5) then cam:shake(2) end
    end,
    draw = function(self)
        cls(0)
        cam:draw()
        map()
        camera()
        print(cam.s, 0, 0)
    end
}

stages.outro = {
    init = function(self)
    end,
    update = function(self)
    end,
    draw = function(self)
        stages.shared()
    end
}