0x5600..0x5dff / 22016..24063

There are 256 characters mapped to each of the 256 P8SCII codes. Each character consists of 8 bytes for each of its 8 rows of pixels, with the first byte being the top-most row, for a total of 2 KB (256 * 8 = 2048 bytes). Each byte consists of 8 pixels, with the left-most pixel in the LSB (bit 0, value 1), and the right-most pixel in the MSB (bit 7, value 128). This is reverse from the binary representation.

Since characters 0..15 are never drawn, their data in memory is purposed by PICO-8 to store default attributes for the font. From the manual:

0x5600 character width in pixels (can be more than 8, but only 8 pixels are drawn)
0x5601 character width for character 128 and above
0x5602 character height in pixels
0x5603 draw offset x
0x5604 draw offset y
0x5605 flags: 0x1 apply_size_adjustments  0x2: apply tabs relative to cursor home
0x5606 tab width in pixels (used only when alt font is drawn)
0x5607 unused

The remaining 120 bytes are used to adjust the width and vertical offset of characters 16..255. Each nibble (low nibbles first) describes the adjustments for one characters:

bits 0x7: adjust character width by 0,1,2,3,-4,-3,-2,-1
bit  0x8: when set, draw the character one pixel higher (useful for latin accents)

https://www.lexaloffle.com/bbs/?tid=49075

3-bit width adjustment and 1-bit y offset

poke(0x5600, state.width1)
poke(0x5601, state.width2)
poke(0x5602, state.height)
poke(0x5603, state.offsetx)
poke(0x5604, state.offsety)
poke(0x5605, 1 + (state.relative and 2 or 0))
poke(0x5606, state.tab)

for c=16, 255 do 
    local bytes = char[c].grid:get_bytes()
        
    for i, v in ipairs(bytes) do
        poke(0x5610 + (c - 16) * 8 + i - 1, v)
    end

    local width = c < 128 and state.width1 or state.width2
    local adjust = mid(-4, char[c].width - width, 3)
    local bp = adjust < 0 and (8 + adjust) or adjust
    local b = 1 << (bp - 1)
    if char[c].raise then b += 128 end
    poke(0x5deb + (c-16), b)
end

