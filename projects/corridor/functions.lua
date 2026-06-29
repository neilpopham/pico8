function aabb(x1, y1, x2, y2, x3, y3, x4, y4)
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end

_mget = mget
function mget(x, y)
	if x < 0 or y < 0 or x >= 1024 or y >= 8 then
		return _mget(-1, -1)
	end
	return _mget(x % 128, y + 8 * (x \ 128))
end

function round(v) return flr(v+.5) end

function manhattan(x1,y1,x2,y2)
    return abs(x1-x2)+abs(y1-y2)
end

function clone(o)
    local c = {}
    for k, v in pairs(o) do
        c[k] = v
    end
    return c
end

function action_msg(action, c, type, b)
    -- printh('creating action_msg for '..type)
    b = b or '🅾️'
    _G.msg = _G.msg .. '\f3' .. b .. '\fd ' .. action .. ' \f' .. hex(c) .. colour_names[c] .. '\fd ' .. type .. '\n'
end

function cartval(i, d)
	return dget(i) > 0 and dget(i) or d
end

function lerp(v0,v1,t)
    return v0+t*(v1-v0)
end

function set_volumes(sfxid, start, values)
    local address=0x3200+68*sfxid+start*2
    for _,value in ipairs(values) do
        local bytes=%address&0xf1ff
        bytes=bytes|value<<9
        poke2(address,bytes)
        address+=2
    end
end

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
