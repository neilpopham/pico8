function round(v)
    return flr(v + (sgn(v) * 0.5))
end
function tile(v)
    return v \ 8
end
function pixel(v)
    return v > 0 and ceil(v) or flr(v)
end
function dirfrom(flags)
    return flags & 128 > 0 and -1 or 1
end
function aabb(x1, y1, x2, y2, x3, y3, x4, y4)
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end
function extend(...)
    local arg = { ... }
    local o = del(arg, arg[1])
    for _, a in pairs(arg) do
        for k, v in pairs(a) do
            o[k] = v
        end
    end
    return o
end
function scroll_tile(tile)
    local temp
    local startcol = tile % 16
    local startrow = flr(tile / 16)
    temp = peek4(startrow * 512 + 448 + startcol * 4)
    for i = 6, 0, -1 do
        poke4(
            startrow * 512 + ((i + 1) * 64) + startcol * 4,
            peek4(startrow * 512 + i * 64 + startcol * 4)
        )
    end
    poke4(startrow * 512 + startcol * 4, temp)
end
function mrnd(x, f)
    if f == nil then f = true end
    local r = x[1] + rnd((f and 1 or 0) + x[2] - x[1])
    return f and flr(r) or r
end
function range(n, m)
    return mrnd({ n, m })
end