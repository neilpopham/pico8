pico-8 cartridge // http://www.pico-8.com
version 43
__lua__


-- px9 data compression v10
-- by zep & co.
--
-- changelog:
--
-- v11:
--  @felice: removed unneeded
--  brackets -> 214 tokens
--
-- v10:
--  @pancelor
--  ★ remove cruft
--  ★ clever getval() tricks
--  ★ fix low-entropy bug
--  215 tokens
--  @zep: added tests tab 3
--
-- v9:
--  @pancelor
--  ★ redo bitstream order
--  234 tokens (but ~4% slower)
--
-- v8:
--  @pancelor
--  ★ smaller vlist initialization
--  241 tokens
--
-- v7:
--  smaller vlist_val by @felice
--  7b -> 254 tokens (fastest)
--  7a -> 247 tokens (smallest)
--
-- v6:
--  smaller vlist_val by @p01
--  -> 258 tokens
--
-- v5:
--  fixed bug found by @icegoat
--  262 tokens (the bug was caused by otherwise redundant code!)
--
-- v4:
--  @catatafish
--  ★ smaller decomp
--
--  @felice
--  ★ fix bit flush at end
--  ★ use 0.2.0 functionality
--  ★ even smaller decomp
--  ★ some code simpler/cleaner
--  ★ hey look, a changelog!
--
-- v3:
--  @felice
--  ★ smaller decomp
--
-- v2:
--  @zep
--  ★ original release
--
--[[

    features:
    ★ 273 token decompress
    ★ handles any bit size data
    ★ no manual tuning required
    ★ decent compression ratios


    ██▒ how to use ▒██

    1. compress your data

        px9_comp(source_x, source_y,
            width, height,
            destination_memory_addr,
            read_function)

        e.g. to compress the whole
        spritesheet to the map:

        px9_comp(0,0,128,128,
            0x2000, sget)

    …………………………………
    2. decompress

        px9_decomp(dest_x, dest_y,
            source_memory_addr,
            read_function,
            write_function)

        e.g. to decompress from map
        memory space back to the
        screen:

        px9_decomp(0,0,0x2000,
            pget,pset)

        …………………………………

        (see example below)

        note: only the decompress
        code (tab 1) is needed in
        your release cart after
        storing compressed data.

]]

function old_init()

    -- test: compress from
    -- spritesheet to map, and
    -- then decomp back to screen

    cls()
    print("compressing..",5)
    flip()

    w=128 h=128
    raw_size=(w*h+1)\2 -- bytes

    ctime=stat(1)

    -- compress spritesheet to map
    -- area (0x2000) and save cart

    clen = px9_comp(
        0,0,
        w,h,
        0x2000,
        sget)

    ctime=stat(1)-ctime

    --cstore() -- save to cart

    -- show compression stats
    print("                 "..(ctime/30).." seconds",0,0)
    print("")
    print("compressed spritesheet to map",6)
    ratio=tostr(clen/raw_size*100)
    print("bytes: "
        ..clen.." / "..raw_size
        .." ("..sub(ratio,1,4).."%)"
        ,12)
    print("")
    print("press ❎ to decompress",14)

    memcpy(0x7000,0x2000,0x1000)

    -- wait for user
    repeat until btn(❎)

    print("")
    print("decompressing..",5)
    flip()

    -- save stats screen
    local cx,cy=cursor()
    local sdata={}
    for a=0x6000,0x7ffc do
        sdata[a]=peek4(a)
    end

    dtime=stat(1)

    -- decompress data from map
    -- (0x2000) to screen

    px9_decomp(0,0,0x2000,pget,pset)

    dtime=stat(1)-dtime

    -- wait for user
    repeat until btn(❎)

    -- restore stats screen
    for a,v in pairs(sdata) do
        poke4(a,v)
    end

    -- add decompression stats
    print("                 "..(dtime/30).." seconds",cx,cy-6,5)
    print("")

end

-->8
-- px9 decompress

-- x0,y0 where to draw to
-- src   compressed data address
-- vget  read function (x,y)
-- vset  write function (x,y,v)

function
    px9_decomp(x0,y0,src,vget,vset)

    local function vlist_val(l, val)
        -- find position and move
        -- to head of the list

--[ 2-3x faster than block below
        local v,i=l[1],1
        while v!=val do
            i+=1
            v,l[i]=l[i],v
        end
        l[1]=val
--]]

--[[ 7 tokens smaller than above
        for i,v in ipairs(l) do
            if v==val then
                add(l,deli(l,i),1)
                return
            end
        end
--]]
    end

    -- read an m-bit num from src
    local function getval(m)
        -- $src: 4 bytes at flr(src)
        -- >>src%1*8: sub-byte pos
        -- <<32-m: zero high bits
        -- >>>16-m: shift to int
        local res=$src >> src%1*8 << 32-m >>> 16-m
        src+=m>>3 --m/8
        return res
    end

    -- get number plus n
    local function gnp(n)
        local bits=0
        repeat
            bits+=1
            local vv=getval(bits)
            n+=vv
        until vv<(1<<bits)-1
        return n
    end

    -- header

    local
        w_1,h_1,      -- w-1,h-1
        eb,el,pr,
        splen,
        predict
        =
        gnp"0",gnp"0",
        gnp"1",{},{},
        0
        --,nil

    for i=1,gnp"1" do
        add(el,getval(eb))
    end
    for y=y0,y0+h_1 do
        for x=x0,x0+w_1 do
            splen-=1

            if splen<1 then
                splen,predict=gnp"1",not predict
            end

            local a=y>y0 and vget(x,y-1) or 0

            -- create vlist if needed
            local l=pr[a] or {unpack(el)}
            pr[a]=l

            -- grab index from stream
            -- iff predicted, always 1

            local v=l[predict and 1 or gnp"2"]

            -- update predictions
            vlist_val(l, v)
            vlist_val(el, v)

            -- set
            vset(x,y,v)
        end
    end
end

-->8
-- px9 compress

-- x0,y0 where to read from
-- w,h   image width,height
-- dest  address to store
-- vget  read function (x,y)

function
    px9_comp(x0,y0,w,h,dest,vget)

    local dest0=dest

    local function vlist_val(l, val)
        -- find position and move
        -- to head of the list

--[ 2-3x faster than block below
        local v,i=l[1],1
        while v!=val do
            i+=1
            v,l[i]=l[i],v
        end
        l[1]=val
        return i
--]]

--[[ 8 tokens smaller than above
        for i,v in ipairs(l) do
            if v==val then
                add(l,deli(l,i),1)
                return i
            end
        end
--]]
    end

    local bit=1
    local byte=0
    local function putbit(bval)
        if (bval>0) byte+=bit
        poke(dest, byte) bit<<=1
        if (bit==256) then
            bit=1 byte=0
            dest += 1
        end
    end

    local function putval(val, bits)
        for i=0,bits-1 do
            putbit(val>>i&1)
        end
    end

    local function putnum(val)
        local bits = 0
        repeat
            bits += 1
            local mx=(1<<bits)-1
            local vv=min(val,mx)
            putval(vv,bits)
            val -= vv
        until vv<mx
    end


    -- first_used

    local el={}
    local found={}
    local highest=0
    for y=y0,y0+h-1 do
        for x=x0,x0+w-1 do
            c=vget(x,y)
            if not found[c] then
                found[c]=true
                add(el,c)
                highest=max(highest,c)
            end
        end
    end

    -- header

    local bits=1
    while highest >= 1<<bits do
        bits+=1
    end

    putnum(w-1)
    putnum(h-1)
    putnum(bits-1)
    putnum(#el-1)
    for i=1,#el do
        putval(el[i],bits)
    end


    -- data

    local pr={} -- predictions

    local dat={}

    for y=y0,y0+h-1 do
        for x=x0,x0+w-1 do
            local v=vget(x,y)

            local a=y>y0 and vget(x,y-1) or 0

            -- create vlist if needed
            local l=pr[a] or {unpack(el)}
            pr[a]=l

            -- add to vlist
            add(dat,vlist_val(l,v))

            -- and to running list
            vlist_val(el, v)
        end
    end

    -- write
    -- store bit-0 as runtime len
    -- start of each run

    local nopredict
    local pos=1

    while pos <= #dat do
        -- count length
        local pos0=pos

        if nopredict then
            while dat[pos]!=1 and pos<=#dat do
                pos+=1
            end
        else
            while dat[pos]==1 and pos<=#dat do
                pos+=1
            end
        end

        local splen = pos-pos0
        putnum(splen-1)

        if nopredict then
            -- values will all be >= 2
            while pos0 < pos do
                putnum(dat[pos0]-2)
                pos0+=1
            end
        end

        nopredict=not nopredict
    end

    if(bit>0) dest+=1 -- flush

    return dest-dest0
end

-->8
-- tests
-- uncomment run_tests() at
-- bottom of this tab. each
-- test compresses video and
-- checks crc matches.

--[[
expected sizes
blank:    21 (0.0026)
circ:    254 (0.0310)
lines:  2109 (0.2574)
dots:   2075 (0.2533)
lunch:  1275 (0.1556)
noise: 12819 (1.5648)
noise1: 3277 (0.4000)
]]

function vid_crc()
    local res=109
    for i=0x6000,0x7fff,4 do
        res ^^= 0x9e13.48b1
        res += $i
        res <<>= 5
        res *= 103.11
    end
    return res
end

-- compress whatever is on the
-- screen and check crc matches
function vid_test(name)

crc0=vid_crc()
len=px9_comp(0,0,128,128,
    0x8000,pget)
printh(name..": "..len..
 " ("..(len/8192)..")")
cls()
px9_decomp(0,0,0x8000,pget,pset)

crc1=vid_crc()
assert(crc0==crc1)
end


function run_tests()

    printh("--- px9 tests ---")

    cls(2)
    vid_test("blank")

    -- circles
    cls()circfill(64,64,32,12)
    vid_test("circ")

    --lines
    cls()
    for i=0,128,4 do
    line(i,0,0,128-i,8+i/8)
    line(i,128,128,128-i,8+i/8)
    end
    vid_test("lines")

    --dots
    cls()srand()
    for i=0,2000 do
        circfill(rnd(128),rnd(128),rnd(16),rnd(16))
    end
    vid_test("dots")

    cls()spr(0,0,0,16,16)
    vid_test("lunch")

    -- noise
    cls()
    for i=0x6000,0x7fff do
        poke(i, rnd(256))
    end
    vid_test("noise")

    -- 1-bit noise
    cls()
    for i=0x6000,0x7fff do
        poke(i, rnd(2)+(rnd(2)\1)*16)
    end
    vid_test("noise1")

    -- fuzz
    -- (would be more meaningful
    -- with more variation in
    -- data characteristics)
    srand()

    --for j=0,500 do
    for j=0,4 do
    cls(rnd(16))
    for i=0,rnd(4000) do
        circfill(rnd(128),rnd(128),rnd(16),rnd(16))
    end
    for i=0,rnd(4000) do
        pset(rnd(128),rnd(128),rnd(16),rnd(16))
    end
    vid_test("fuzz"..j)
    end

    color(7)
    cls()
    stop("ok")

end


--run_tests()


-- reload(0x0, 0x0, 0x2000, "px9_2.p8")
clen = px9_comp(0, 0, 128, 128, 0x2000, sget)
cstore(0x0, 0x2000, clen, "px9_1_compressed.p8")
stop()

cls()

reload(0x8000,0x0000,0x2000, "px9_2_compressed.p8")

-- print(peek(0x8000))
-- stop()

px9_decomp(0,0,0x8000,pget,pset)
repeat until false

-- cls()
-- x,y=0,0
-- for s=0,255 do
--     spr(s,x*8,y*8)
--     x+=1
--     if x==16 then x=0 y+=1 end
-- end



__gfx__
ddddddddddddddddddddddddddddddddddddddddd666666d15dddddddddddddddddddddddd666666666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddddddddd666666d155ddddddddddddddddddddddd666666666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddddddddd6666666515ddddddddddddddddddddddd666666666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddddddddd6666666d015dddddddddddddddddddddd666666666666666666666666666666666666666666666666666660
dddddddddddddddddddddddddddddddddddddddd66666666d005ddddddddddddddddddddddd66666666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddddddd666666666d5055dddddddddddddddddddddd66666666666666666666666666666666666666666666666666660
dddddddddddddddddddddddddddddddddddddddd6666666665005dddddddddddddddddddddd66666666666666666666666666666666666666666666666666660
dddddddddddddddddddddddddddddddddddddddd666666666d0055ddddddddddddddddddddd66666666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddddd6666666666d6d1015ddddddddddddddddddddd66666666666666666666666666666666666666666666666666660
dddddddddddddddddddddddddddddddddddddd6666666666dd50055ddddddddddddddddddddd6666666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddddddd66666666dddd1015ddddddddddddddddddddd6666666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddddd6666666666dd6d5015ddddddddddddddddddddd6666666666666666666666666666666666666666666666666660
dddddddddddddddddddddddddddddddddddddd666666666dd6651155ddddddddddddddddddddd666666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddd66ddd6666666ddd6d1155dddddddddddddddddddddd66666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddd6666666666666dd6d51155dddddddddddddddddddddd6666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddd666666666666666dddd555555dddddddddddddddddddddd666666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddfdddddd66666666666666ddd555555dddddddddddddddddddddd666666666666666666666666666666666666666666666660
dddddddddddddddddddddddddddddddddd6d6666666666666dd6d155555ddddddddddddddddddddddd6666666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddd6d666666666666dddd5155555dddddddddddddddddddddddddd666666666666666666666666666666666666666660
ddddddddddddddddddddddddddddddddddddddd6666666666dddd51555555ddddddddddddddddddddddddddd66666666666666666666666666666666666666d0
dddddddddddddddddddddddddddddddddddddddd6666666666dddd5155555dddddddddddddddddddddddddddddd6666666666666666666666666666dddddddd0
ddddddddddddddddddddddddddddddddddddddd66666666666d6dd5155f555dddddddddddddddddddddddddddddd6666666666666666666666ddddddddddddd0
ddddddddddddddddddddddddddddddddddddddd666ddd66666dddd551555555ddddddddddddddddddddddddddddddd666666666666666dddddddddddddddddd0
ddddddddddddddddddddddddddddddddddddddd666ddddddd66dddd5551555555ddddddddddddddddddddddddddddddd6666ddddddddddddddddddddddddddd0
dddddddddddddddddddddddddddddddddddddd66666dddddddddddd5555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0
ddddddddddddddddddddddddddddddddddddd666666ddddddddddddd55555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0
dddddddddddddddddddddddddddddddddddd666666dddddddddddddd515555555555ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0
ddddddddddddddddddddddddddddddddddd6666666dddddddddd5ddd5011155555555ddddddddddddddddddddddddddddddddddddddddddddddddddddddd5dd0
ddddddddddddddddddddddddddddddddddd66666666dddddd5dddd5dd0011555555555ddddddddddddddddddddddddddddddddddddddddddddddddddd5555550
dddddddddddddddddddddddddddddddddd666dddddd6ddddddddd5556500155555555555dddddddddddddddddddddddddddddddddddddddddddddd66666666d0
dddddddddddddddddddddddddd6dddddd6666ddddddd6ddddd55dd5d6500115555555555ddddddd5ddddddddddddddddddddddddddddddddddd66666ddddd6d0
dddddddddddddddddddddddddddddddd6666ddddddddddddddd55d556510115555555555ddddd55555dddddddddddddddddddddddddddddd666d666666dd66d0
dddddddddddddddddddddddddddddddd666ddd55dddddddddddd5d55dd11515555115555555dd555555d5ddddddddddddddddddddddddd666dd66666ddddddd0
dddddddddddddddddddddddddddddddd66dddddddddddd6dddddd555dd51555555115555555555555555555dddddddddddddddddddd6666dddddddd6666dddd0
dddddddddddddddddddddddddddddddd66ddddddddddddddddddd5555dd55555551155555555555555555555ddddddddddddddddd6666dddd6666666d66dddd0
dddddddddddddddddddddddddddddddd66ddd5ddd66dddddddddd5d55dd5555555515555555555555555555555dddddddddddddd6ddddddd6666666666ddddd0
dddddddddddddddddddddddddddd6666dddddddd66666666666dd55d55dd55d5550155555555555555555555555ddddddddddd6666666dd6666666666dddddd0
dddddddddddddddddddddddddd666666ddddddddd66666666ddddd5555555555510155555555555555555555555555dddd5d66dd66d66666666666666dddddd0
dddddddddddddddddddddddddd666666ddddddddd6666666d6dd5d55555555d551155d55555d555555555555555555555566dddddddd6666666666ddddddddd0
dddddddddddddddddddddddddd666666dd55ddd6666dddddddd255dd55555d555111dd55dddd55555555555555555555566dddd6dd666666666666ddddddddd0
ddddddddddddddddddddddddddd66666ddd55dd6ddddddddd555d55555d5dddd5505dd55ddddd555555555555555555d6d6d66d66666666666666666ddddddd0
dddddddddddddddddddddddddd66666ddddd5ddddddddd55555dd55dd5dddd555555d555ddddd5555d555555551155d6dddddd6666666666666666ddddddddd0
ddddddddddddddddddddddddd66666dddddddddddddddd55555555d5ddd5dd555555d55ddddd555d5555dd5551111d6ddddd6666666666666666ddddddddddd0
dd66666ddd6666dddddddddd66666dddddddddddddd5dd655555dd555dd555d5d5555555ddd555555dd555155111d6d55ddddd666666666666666dddddddddd0
d66666666d66666dddddddd666666ddddddddddddddd5d5655d5d5d5ddd55ddd555dd55d5d5515515dd51155511d6d5dddddddd666666666666666ddddddddd0
d66666666d66666ddddddd6666666ddddddddd555d55dd5dddddd5ddd65d555d55ddd5dd55d51505555005555556dddddddddddddddddd6666ddddddddddddd0
d6666666ccc6666ddddddd666666ddddddddddd555555ddddd5dd655565ddd5555ddd5d55d015555d100555d55ddd5dddddfddddddddddddddddddddddddddd0
66666666cccc6666dddddd6666666dddddddddddd55ddd5d55d5d5d55dddd55515dd55d55550515500055d55ddddd555dd65ddddddddddddddddddddddddddd0
d6666666cccc6666dddddd666666ddddddddddddd5d5dd5ddd55556d5ddddd55dd6d55555055d5d500015d5dddddddd555ddddddddddddddddddddddddddddd0
dd666666cccc666dddddd6666666ddddd5dddddddddddddddd555d5dddddd555ddddd55555555dd51005d55555555ddddddddddddd55d5ddddddddddddddddd0
dd66666cccccc6ddddddd666666dddd55ddddddddddddddd5dd5d6d6dd6dddddddeddd5550516555515d5d55555d55d5dddd555555ddddddddddddddddddddd0
dd66666ccccccddddddd666666dddd555dd5dddddddddddd55ddd666ddddddddddddd4050d05d5551155d555555dd6dddd5ddddddd5dddd5ddddddddddddddd0
cc66666ccccccddddddd666666ddddd55dd5dd66dddddd6ddddd6d66dddd66f6ddef42050d555d5d555555dd52555ddddd5555dddddd5ddd55ddddddddddddd0
ccc666ccccccddddddd666666dddddddddddd66dd6ddd666dddd666666d6ff6dddeddd505d50d55555d5d5552dd5dddd6555ddddddddd5555ddddddddd6dddd0
cc6666ccccccddddddd666666dddd55ddddd66666d666666666667766666ffffddedd555dd50d50155555555d755dddddd6ddd555252555555d5ddddddddddd0
cc666ccccccd6ddddd666666ddd55555555dd666dd66666666666776666f77fedded501dd5515100555555dd255555dd66d55555555555555555ddddd6ddddd0
cc666cccccdd6666dd666666dddd55115155ddd666667666666666f66f6777fddedd5055610500055dd515fd555555dd666ddd5555dddd55555554dd66ddddd0
cc666cccc666666666666666ddddd5511111555d66666ddddd6667666f777ffddfdd050d5505dd055255dd5d555d55dddd666dd555225555555544dd66ddddd0
cc66cccc6666666666666666ddddd55551000155d6d51000005d66f66f777ffeded5550515dd6555555765dd55d2dd57ddddddddd5552225444444dd666666d0
cc66cccc6666666666666666dddddd55555010005d5500000000d6666f67766fed1555550dddd11552555d555d5f52555d666ddd55d222244ddd44d666666660
cc6ccccc66666666666666666dddddd55555555d6d00555551000d6666f66ffdf6d5d5515dddd5001755555d7d555555ddddd5dd5d5222244dddd5d666666660
ccccccccc6666666666666666ddddddddd55d666650555d66d5005666666666fd65d00d5d666dd5005d55755d5555d5dddddddddd522222444ddd5d666666660
ccccccccc6666666666666666ddddddddd5dd666d0555555d5d100d6666dd6ddd5d555d566f6dd515d65555555665525555dd66ddd552222224dddd666666660
cccccccccc6666666666666666ddddd6dd55d66650555500001510d666dd6d5665d5dd5d6f6d6d55dd65ddd5555555555d5dd66dddd42222224ddd6666666660
cccc6666ccc66666666ddd6666dddd666d55d66650555000000510d666dd66d1dddd65666f6665d6d66dd5155dd5522225dddddddd52222224dddd6666666660
cccc6666cccd666666dddd6666dddd6ddd55dd66505550000005105666d5dd56ddddd6fd66f6dd6666d5d55555555255555ddddddd2222224dddd66666666660
ccc66666cccdd66666ddddd66ddddd66ddd5dd6650055500005550d666d5d5ddd55d5dddff6ddd66666ddd25255255522555dddd22222555dddd666666666660
ccc666666dddd66666ddddddddddd666ddd5dd6dd505d50005551066676d655d5556dddd666dd6666666ddd5252225552255d45552222225dddd666666666660
cc6666666ddd666666dddddddddddd666d5d5dd6d50055555551006666d6d65500dddddd66dd66666666dddd52555255255445452222225dddd6666666666660
cc666666ddd66666666dddddddddddd66d5d55d66d5005555500056677dd6d05056dd5d66d6ddd666666dddd25522222222254d52222555dddddd66666666660
cc666666dd6666666ddddddddddddddddd5d5dd666d5000000000d676d66555d556d566dddd5555dd6666ddddd5d5252522554422222555ddddd666666666660
c66666dd666666666ddddd56ddddddd5ddd55dddd66d510000055d676d6ddd51d55dd6d6dd0000000566d66dddd525552222255421552255ddd6666666666660
6666666666666666ddddddddd6dddd555dd55dddd6666666d5555666d6ddd5555ddd6dd6d0000000005d6666dd5ddd455222224521155555ddd6666666666660
6666666666666666ddddddd5dddddd55555555ddddd6f66665555d6d6d66d05ddd5d666d000056d5100556d6dddd54555522222555555555dd66666666666660
66666666666666ddddddddd55dddd6555555555ddddd66fdd55105d666d6d5d55d5666d0005555555500566dddddd5544522555555555555dd66666666666660
6666666666666dddddddddddd55dddd6d555552dd5ddd66dd55115d666ddd5d6dd666d50005510055510056dddddddddd252255555555555dd66666666666660
dd6666666666dddddddddddd5555ddddddddd52555d5dddddd155dd6d6d5dddddd66dd00055500001551055dddddddd4452445555555555ddd66666666666660
ddd666666666ddddddddddd555555ddddd7ddd555ddddddd5505d6d6667ddddd6d66d01005550000055505555ddddddd444552255555555ddd66666666666660
c666666666ddd66776dddd5555555ddddddddddd666d6dddd5dddd66666d6ddddddd105005550000555505d00555ddd44445255555555555dd66666666666660
dd6666666666ddddddddd5d7d55555dddddddfd666dd6dddd5d56dd66666ddddd5d5001101551000555505d10005555d4452222255555555dd66666666666660
d66666666666dddddddddd5555557ddddddddddd66666ddddd5dd666d66666ddd50050000055555555501dd5150001555222222255555555dd66666666666660
d66666666666dddddddddddddddd55566ddddd667dd66ff66dddddddd6ddd5ddd500115500055555550056dd55000005225522222555555ddd66666666666660
d666666666666dddddddddddd555555dddd76d67665d5d666dd5dddddddddd55500515d6d00005550005d6ddd5100000552255525555555ddd66666666666660
666777666666dddddd676666d67776d5ddddd66676d5ddf66d555dddddddd6d5d50552d66d100000051d666ddd500000555511155555555dd666666666666660
66677666666666ddd5ddddd55ddddddddddd77766666d5666555dddddddd55d2250155d6fddd51155dd6ddddd555555155555555555555ddd666666666666660
6677766666ddddddd55d67666dddddd6666667776d66666665515555d5dd222122015d5d66d6dddddddddddd5255510001115555555555ddd666666666666660
6777766666ddddd7ddddddddddddd666ddddd666665d666665555155dd55525551125dddddf6dddddddd12252555551000011555555555dd6666666666666660
677666666666ddddddddddd6666677666666dd666dddd6666d1155105155512242522ddd2dddddddddd22255555555111000155555555ddd6666666666666660
677666666666dddddddd66676666ddddd6666766d66666666d10122251015254d444d5d2d5dddddd5222522254dd25551155555555555ddd6666666666666660
6666676666dddd555d57d666666666dd7d7d6676d6dd66666d5012225550005dddd455ddd525255552221222224d45555555555555555ddd6666666666666660
66777766ddddd5dd70ddd66666667667555666d66ddd66d6dd515125000005dddddd45dd552d55555222244444d54d525555555555555dd66666666666666660
6667776ddddd575dd55dd666666676666675dd76dd666dddddd010500005d666ddddddddd4d42222252254dddddddd52255555555555ddd66666666666666660
66677766dd56d555dd55dd76666666767dd57ddddddddddd45d10010015d66665d62dddddd42222022225dddddddd55522555555555dddd66666666666666660
77777776dddddd5555557dd666666676666555ddddddddd5dd5500155dd6666fd5d0525ddddd4255555255555555525525555555555ddd666666666666666660
777777766dd5dd55557555dddd666dd6666dd5dddddddddd4552055dddd6d5d666666dddddddf777fd0155555100115555555555555ddd666666666666666660
777777776dd55dd5755565dd6d6dddd7d66dd5555ddd6dd5d4520525dddddd55d5dd6fffdddd5555551056d6500155155555555555ddd6666666666666666660
777777766dd555d1550055d5dddd556ddddddd5555dddddddd45254d4ddd66ddd5d56ddddffd555555550100065d51555555555555ddd6666666666666666660
777666766d5557555755565555555555ddddddd555dddddddddd444445d5dd66dd666dfdd7d552d7e55555551111165d555555555ddd66666666666666666660
7776d6666d5555555555d5d55555555555d5ddddd5ddddddddddddddddddddd5dddd666dfdd5df52252fd555511115516d555555ddd666666666666666666660
7676dd666dd55155555017515505555555555555ddddddddddddddddddddddddddfdfdfd556555527255250651111111555d555dddd666666666666666666660
7766666666555555551165511555555555555555555dd5dddddddddddddddddddddfddd566522222511651111061111155555d5ddd6666666666666666666660
666666666dd5555555555550605555555515555555d555ddddddddddddddddddddddd55d15d1555511000070110107011555555dd66666666666666666666660
676766d666d56555d56555500055555155115555555555dddddddddddddddddddd5d56511617d111000000006010011611555dddd66666666666666666666660
666666666ddd15551605550005555551110011155555555555dddddddddd555555516070006007000000000000d0001111d5dddd666666666666666666666660
66666f666dd5555510055510155550000100015515555555555d55255d55555115000606000050600000000000006001555d6d66666666666666666666666660
d6666666ddd5555500511d011555100001000551011115511555551555115000000000d0d0000600d00000000000006155ddd666666666666666666666666660
6d666d6ddd55555d05115001155500000000010000001101151110010000100000000006d00000d00700000000000015d5dddddd666666666666666666666660
66dddd6ddd551150050170101110000000000000000000001000000011000000000000005700000100600000000000155dddddd6666666666666666666666660
ddd6dddd555110501000001000000000001000000000000000000000110000000010000000600000050d000000000015555ddddd666666666666666666666660
ddddd55555100650000000000000000000000000000111111110000100000000101000000dd500000050d50000000015555d6dddd66666666666666666666660
5d555551150000100005115555555555555555555555555555111101010000000000000000560000000d0dd1011111555555ddddd66666666666666666666660
1550501155555555dddddddddddddddd5d55555555555555555111110011000000001111000d51111155d5dd555555555ddddddd666666666666666666666660
ddddddddddddddddddddddd6fdddddddddddddddddddd555552525555555555555555555555dd5555dddddddddddddddddddddd6666666666666666666666660
66666666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd666666666666666666666660
6666666666666dddddd6dddddd666dddddddd666666666666ddddddddddddddddddddddddd666ddddddddddd6dddddddddddddd6666666666666666666666660
6666666666666dddddddddddddddddddddddddddd66ddddddddddddddddddddddddddddddd666ddddddddd6666dddddd6dddd666666666666666666666666660
66666666666666666dd666666666666666666666666666666d6dddddd66d66dddddddddd66666dddddd66666ddddddddddddd666666666666666666666666660
6666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddd66666666666666666666666666666660
666666666666666666666666666666666666666666666666666666666666666ddd6666666666ddddddddddddddddddddd6666666666666666666666666666660
666666666666666666666666666666666666666666666666666666666666666d6d6666666666dddddddddddddddddddd66666666666666666666666666666660
6666666666666666666666666666666666666666666666666666666666666666666666666666ddddddddddddddddddddd6666666666666666666666666666660
76666666666666666666666666666666666666666666666666666666666666666666666666666d66dddddddddddddddd66666666666666666666666666666660
77766666666666666666666666666666666666666666666666666666666666666666666666666666666666dddd66666666666666666666666666666666666660
77776666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660
77776666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660
77777666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660
77777666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660
77777766666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660
