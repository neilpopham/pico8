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

function lerp(v0,v1,t)
    return v0+t*(v1-v0)
end

function right(flags) return flags&128>0 end

function set_volumes(sfxid, start, values)
    local address=0x3200+68*sfxid+start*2
    for _,value in ipairs(values) do
        local bytes=%address&0xf1ff
        bytes=bytes|value<<9
        poke2(address,bytes)
        address+=2
    end
end
