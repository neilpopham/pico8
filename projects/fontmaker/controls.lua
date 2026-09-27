function create_spinner(src, prop, label, x, y, w, min, max)
    return {
        x = x,
        y = y,
        width = w,
        min = min,
        max = max,
        label = label,
        src = src,
        prop = prop,
        inc = false,
        dec = false,
        value = nil,
        -- increase = function(self)
        --     local v = self.src[self.prop] + 1
        --     self:set(min(v, self.max))
        -- end,
        -- decrease = function(self)
        --     local v = self.src[self.prop] - 1
        --     self:set(max(v, self.min))
        -- end,
        clamp = function(self, value)
            return mid(self.min, value, self.max)
        end,
        val = function(self, value)
            self.src[self.prop] = self:clamp(value)
        end,
        update = function(self)
            -- if key.key == "q" then self.decrease() end
            -- if key.key == "q" then self.increase() end
            -- self.set(value)

            self.inc = false
            self.dec = false
            local ix, v, hit = self.x + 6 + self.width * 4
            if aabb(mouse.x - 1, mouse.y - 1, mouse.x + 1, mouse.y + 1, self.x, self.y, self.x + 2, self.y + 4) then
                hit = true
                self.dec = true
                if mouse.left.active then
                    v = -1
                elseif mouse.right.active then
                    v = -10
                end
            end
            if aabb(mouse.x - 1, mouse.y - 1, mouse.x + 1, mouse.y + 1, ix, self.y, ix + 2, self.y + 4) then
                hit = true
                self.inc = true
                if mouse.left.active then
                    v = 1
                elseif mouse.right.active then
                    v = 10
                end
            end
            if v then
                self:val(self.src[self.prop] + v)
                if addresses[self.prop] then
                    poke(addresses[self.prop], self.src[self.prop])
                end
            end
            if hit then
                cursor = { chr = 94, col = 10, ox = -1, oy = 0 }
            end
            self.value = self.src[self.prop]
        end,
        draw = function(self)
            print('\022', self.x, self.y, self.dec and 9 or 5)
            print(lpad(self.value, self.width), self.x + 5, self.y, 7)
            print('\023', self.x + 6 + self.width * 4, self.y, self.inc and 9 or 5)
            if self.label then
                print(self.label, self.x, self.y - 7, 6)
            end
        end
    }
end

function create_checkbox(src, prop, label, x, y)
    return {
        x = x,
        y = y,
        src = src,
        prop = prop,
        label = label,
        hover = false,
        value = nil,
        val = function(self, v)
            self:toggle()
        end,
        toggle = function(self)
            self.src[self.prop] = not self.src[self.prop]
        end,
        update = function(self)
            self.hover = false
            local hit
            if aabb(mouse.x - 1, mouse.y - 1, mouse.x + 1, mouse.y + 1, self.x, self.y, self.x + 4, self.y + 4) then
                hit = true
                if mouse.left:clicked() then
                    self:toggle()
                end
                self.hover = true
            end
            if hit then
                cursor = { chr = 94, col = 10, ox = -1, oy = 0 }
            end
            self.value = self.src[self.prop]
        end,
        draw = function(self)
            rect(self.x, self.y, self.x + 4, self.y + 4, self.hover and 9 or (self.value and 6 or 5))
            if self.value then
                rectfill(self.x + 1, self.y + 1, self.x + 3, self.y + 3, 8)
            end
            if self.label then
                print(self.label, self.x, self.y - 7, 6)
            end
        end
    }
end