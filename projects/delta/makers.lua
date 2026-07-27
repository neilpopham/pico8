makers = {
    [1] = function(x, y, s, m)
        return {corner:new({ x = x, y = y, s = s, m = m, dir = 1 })}
    end,
    [2] = function(x, y, s, m)
        return {corner:new({ x = x, y = y, s = s, m = m, dir = 2 })}
    end,
    [3] = function(x, y, s, m)
        return {corner:new({ x = x, y = y, s = s, m = m, dir = 3 })}
    end,
    [4] = function(x, y, s, m)
        return {corner:new({ x = x, y = y, s = s, m = m, dir = 4 })}
    end,
    [5] = function(x, y, s, m)
        return {
            entrance:new({ x = x, y = y, s = s, m = m }),
            ball:new({ x = x + 1, y = y, s = 6, m = m })
        }
    end,
    [7] = function(x, y, s, m)
        return {portal:new({ x = x, y = y, s = s, m = m, dir = 1 })}
    end,
    [8] = function(x, y, s, m)
        return {portal:new({ x = x, y = y, s = s, m = m, dir = 2 })}
    end,
    [9] = function(x, y, s, m)
        return {portal:new({ x = x, y = y, s = s, m = m, dir = 3 })}
    end,
    [10] = function(x, y, s, m)
        return {portal:new({ x = x, y = y, s = s, m = m, dir = 4 })}
    end,
    [11] = function(x, y, s, m)
        return {exit:new({ x = x, y = y, s = s, m = m })}
    end,
    [12] = function(x, y, s, m)
        return {bug:new({ x = x, y = y, s = s, m = m })}
    end,
    [13] = function(x, y, s, m)
        return {block:new({ x = x, y = y, s = s, m = m })}
    end,
    [17] = function(x, y, s, m)
        return {corner:new({ x = x, y = y, s = s, m = m, dir = 1, disolves = true })}
    end,
    [18] = function(x, y, s, m)
        return {corner:new({ x = x, y = y, s = s, m = m, dir = 2, disolves = true })}
    end,
    [19] = function(x, y, s, m)
        return {corner:new({ x = x, y = y, s = s, m = m, dir = 3, disolves = true })}
    end,
    [20] = function(x, y, s, m)
        return {corner:new({ x = x, y = y, s = s, m = m, dir = 4, disolves = true })}
    end
}