function lpad(x, n)
    n = n or 2
    return sub("0000000" .. x, -n)
end

function aabb(x1, y1, x2, y2, x3, y3, x4, y4)
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end