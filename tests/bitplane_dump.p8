pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
seen = {}
for dst = 0, 15 do
    for src = 0, 15 do
        for m = 0, 255 do
            cls(dst)
            m1 = (m & 0b11110000) >> 4
            m2 = m & 0b00001111
            poke(0x5f5e, (m1 << 4) | m1)
            circfill(44, 64, 36, src)
            poke(0x5f5e, (m2 << 4) | m2)
            circfill(84, 64, 36, src)
            poke(0x5f5e, 255)
            print(m1 .. ' ' .. m2 .. ' ' .. src .. ' ' .. dst, 0, 0, 7)
            hash = 'a' .. tostr(pget(127, 127)) .. 'b' .. tostr(pget(44, 64)) .. 'c' .. tostr(pget(64, 64)) .. 'd' .. tostr(pget(84, 64))
            if not seen[hash] then
                seen[hash] = true
                extcmd('screen')
            end
        end
    end
end
