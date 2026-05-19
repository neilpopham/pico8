-- https://www.lexaloffle.com/bbs/?tid=30910
function hex(v)
    local s, l, r = tostr(v, true), 3, 11
    while sub(s, l, l) == "0" do
        l += 1
    end
    while sub(s, r, r) == "0" do
        r -= 1
    end
    return sub(s, min(l, 6), flr(v) == v and 6 or max(r, 8))
end

function lpad(x, n)
    n = n or 2
    return sub("0000000" .. x, -n)
end

function hp(v)
    return lpad(hex(v), 2)
end

function aabb(x1, y1, x2, y2, x3, y3, x4, y4)
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end