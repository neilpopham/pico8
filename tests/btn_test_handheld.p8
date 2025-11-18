pico-8 cartridge // http://www.pico-8.com
version 43
__lua__


function _init()
    buttons,b={}
    for p=0,7 do
        buttons[p]={}
    end
end

function _update60()
    for p=0,7 do
        for b=0,5 do
            buttons[p][b]=btn(b,p)
        end
    end
    b=btn()
end

function _draw()
    cls(0)
    for p=0,7 do
        rectfill(p*16+5,0,p*16+9,4,buttons[p][2] and 9 or 1)
        rectfill(p*16,5,p*16+4,9,buttons[p][0] and 9 or 1)
        rectfill(p*16+10,5,p*16+14,9,buttons[p][1] and 9 or 1)
        rectfill(p*16+5,10,p*16+9,14,buttons[p][3] and 9 or 1)
        rectfill(p*16+2,20,p*16+6,24,buttons[p][4] and 8 or 1)
        rectfill(p*16+8,20,p*16+12,24,buttons[p][5] and 8 or 1)
        print('p'..p,p*16+2,26,3)
    end

    for p=0,1 do
        rectfill(p*64+24,48,p*64+39,63,b&(2^(p*8+2))>0 and 9 or 1)
        rectfill(p*64+24,80,p*64+39,95,b&(2^(p*8+3))>0 and 9 or 1)
        rectfill(p*64+8,64,p*64+23,79,b&(2^(p*8))>0 and 9 or 1)
        rectfill(p*64+40,64,p*64+55,79,b&(2^(p*8+1))>0 and 9 or 1)
        rectfill(p*64+8,112,p*64+23,127,b&(2^(p*8+4))>0 and 8 or 1)
        rectfill(p*64+40,112,p*64+55,127,b&(2^(p*8+5))>0 and 8 or 1)
        print('p'..p,p*64+8,48,3)
    end

    print('\^w\^t'..sub('000'..b, -4), 50, 92, 7)
end


-- function _update60()
--     b=btn()
-- end

-- function _draw()
--     cls()
--     print('\^w\^t'..sub('000'..b, -4), 50, 110, 7)
--     for i=0,1 do
--         rectfill(i*64+24,0,i*64+39,15,b&(2^(i*8+2))>0 and 9 or 1)
--         rectfill(i*64+24,32,i*64+39,47,b&(2^(i*8+3))>0 and 9 or 1)
--         rectfill(i*64+8,16,i*64+23,31,b&(2^(i*8))>0 and 9 or 1)
--         rectfill(i*64+40,16,i*64+55,31,b&(2^(i*8+1))>0 and 9 or 1)
--         rectfill(i*64+8,64,i*64+23,79,b&(2^(i*8+4))>0 and 8 or 1)
--         rectfill(i*64+40,64,i*64+55,79,b&(2^(i*8+5))>0 and 8 or 1)
--     end
-- end