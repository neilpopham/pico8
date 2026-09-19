function make_grid()
    return {
        cells = {},
        empty = true,
        raise = false,
        init = function(self)
            for y = 1, 8 do
                self.cells[y] = {}
                for x = 1, 8 do
                    self.cells[y][x] = 0
                end
            end
        end,
        get = function(self, x, y)
            return self.cells[y][x]
        end,
        set = function(self, x, y, v)
            self.cells[y][x] = v
            self.empty = false
        end,
        row = function(self, r)
            local tmp = {}
            for x = 1, 8 do
                tmp[x] = self.get(self, x, r)
            end
            return tmp
        end,
        col = function(self, c)
            local tmp = {}
            for x = 1, 8 do
                tmp[x] = self.get(self, c, x)
            end
            return tmp
        end,
        draw = function(self, sx, sy, width, height)
            rectfill(sx, sy, sx + width * 8 - 2, sy + height * 8 - 2, 2)
            for y = 0, 7 do
                for x = 0, 7 do
                    local dx, dy, c = x + 1, y + 1, 1
                    if self:get(dx, dy) == 1 then
                        c = 7
                    elseif dy > height or dx > width then
                        c = 3
                    end
                    rectfill(sx + x * 8, sy + y * 8, sx + x * 8 + 6, sy + y * 8 + 6, c)
                end
            end
        end
    }
end