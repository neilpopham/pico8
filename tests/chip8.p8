pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

-- https://tobiasvl.github.io/blog/write-a-chip-8-emulator/
-- https://en.wikipedia.org/wiki/CHIP-8#The_stack
-- https://johnearnest.github.io/Octo/

printh('========================================')

-- mode 3: 64x64
poke(0x5f2c,3)

local pc,v,ps,key,dt,st,i,op1,op2,o,x,y,n,nn,nnn=512,{},{},{},0,0
-- v=split("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")

function hex2dec(v)
    return tonum("0x"..v)
end

function cpoke(a,v)
    poke(0x4300+a,v)
end

function cpeek(a)
    return peek(0x4300+a)
end

-- Clear chip-8 memory
memset(0x4300,0,0xfff)

local font={
    {0xF0, 0x90, 0x90, 0x90, 0xF0}, -- 0
    {0x20, 0x60, 0x20, 0x20, 0x70}, -- 1
    {0xF0, 0x10, 0xF0, 0x80, 0xF0}, -- 2
    {0xF0, 0x10, 0xF0, 0x10, 0xF0}, -- 3
    {0x90, 0x90, 0xF0, 0x10, 0x10}, -- 4
    {0xF0, 0x80, 0xF0, 0x10, 0xF0}, -- 5
    {0xF0, 0x80, 0xF0, 0x90, 0xF0}, -- 6
    {0xF0, 0x10, 0x20, 0x40, 0x40}, -- 7
    {0xF0, 0x90, 0xF0, 0x90, 0xF0}, -- 8
    {0xF0, 0x90, 0xF0, 0x10, 0xF0}, -- 9
    {0xF0, 0x90, 0xF0, 0x90, 0x90}, -- A
    {0xE0, 0x90, 0xE0, 0x90, 0xE0}, -- B
    {0xF0, 0x80, 0x80, 0x80, 0xF0}, -- C
    {0xE0, 0x90, 0x90, 0x90, 0xE0}, -- D
    {0xF0, 0x80, 0xF0, 0x80, 0xF0}, -- E
    {0xF0, 0x80, 0xF0, 0x80, 0x80}  -- F
}

-- Write font to memory at 0x50
for c,char in ipairs(font) do
    for k,bits in ipairs(char) do
        cpoke(0x4f+k+((c-1)*5),bits)
    end
end

local data

-- https://github.com/Timendus/chip8-test-suite/blob/main/bin/2-ibm-logo.8o
data="00 E0 A2 2A 60 0C 61 08 D0 1F 70 09 A2 39 D0 1F A2 48 70 08 D0 1F 70 04 A2 57 D0 1F 70 08 A2 66 D0 1F 70 08 A2 75 D0 1F 12 28 FF 00 FF 00 3C 00 3C 00 3C 00 3C 00 FF 00 FF FF 00 FF 00 38 00 3F 00 3F 00 38 00 FF 00 FF 80 00 E0 00 E0 00 80 00 80 00 E0 00 E0 00 80 F8 00 FC 00 3E 00 3F 00 3B 00 39 00 F8 00 F8 03 00 07 00 0F 00 BF 00 FB 00 F3 00 E3 00 43 E0 00 E0 00 80 00 80 00 80 00 80 00 E0 00 E0"

-- https://github.com/Timendus/chip8-test-suite/blob/main/bin/1-chip8-logo.8o
data="00 E0 61 01 60 08 A2 50 D0 1F 60 10 A2 5F D0 1F 60 18 A2 6E D0 1F 60 20 A2 7D D0 1F 60 28 A2 8C D0 1F 60 30 A2 9B D0 1F 61 10 60 08 A2 AA D0 1F 60 10 A2 B9 D0 1F 60 18 A2 C8 D0 1F 60 20 A2 D7 D0 1F 60 28 A2 E6 D0 1F 60 30 A2 F5 D0 1F 12 4E 0F 02 02 02 02 02 00 00 1F 3F 71 E0 E5 E0 E8 A0 0D 2A 28 28 28 00 00 18 B8 B8 38 38 3F BF 00 19 A5 BD A1 9D 00 00 0C 1D 1D 01 0D 1D 9D 01 C7 29 29 29 27 00 00 F8 FC CE C6 C6 C6 C6 00 49 4A 49 48 3B 00 00 00 01 03 03 03 01 F0 30 90 00 00 80 00 00 00 FE C7 83 83 83 C6 FC E7 E0 E0 E0 E0 71 3F 1F 00 00 07 02 02 02 02 39 38 38 38 38 B8 B8 38 00 00 31 4A 79 40 3B DD DD DD DD DD DD DD DD 00 00 A0 38 20 A0 18 CE FC F8 C0 D4 DC C4 C5 00 00 30 44 24 14 63 F1 03 07 07 77 17 63 71 00 00 28 8E A8 A8 A6 CE 87 03 03 03 87 FE FC 00 00 60 90 F0 80 70"

-- https://github.com/Timendus/chip8-test-suite/blob/main/bin/3-corax%2B.8o
data="12 0A 60 01 00 EE 60 02 12 A6 00 E0 68 32 6B 1A A4 F1 D8 B4 68 3A A4 F5 D8 B4 68 02 69 06 6A 0B 6B 01 65 2A 66 2B A4 B5 D8 B4 A4 ED D9 B4 A4 A5 36 2B A4 A1 DA B4 6B 06 A4 B9 D8 B4 A4 ED D9 B4 A4 A1 45 2A A4 A5 DA B4 6B 0B A4 BD D8 B4 A4 ED D9 B4 A4 A1 55 60 A4 A5 DA B4 6B 10 A4 C5 D8 B4 A4 ED D9 B4 A4 A1 76 FF 46 2A A4 A5 DA B4 7B 05 A4 CD D8 B4 A4 ED D9 B4 A4 A1 95 60 A4 A5 DA B4 7B 05 A4 AD D8 B4 A4 ED D9 B4 A4 A5 12 90 A4 A1 DA B4 68 12 69 16 6A 1B 6B 01 A4 B1 D8 B4 A4 ED D9 B4 60 00 22 02 A4 A5 40 00 A4 A1 DA B4 7B 05 A4 A9 D8 B4 A4 E1 D9 B4 A4 A5 40 02 A4 A1 30 00 DA B4 7B 05 A4 C9 D8 B4 A4 A9 D9 B4 A4 A1 65 2A 67 00 87 50 47 2A A4 A5 DA B4 7B 05 A4 C9 D8 B4 A4 AD D9 B4 A4 A1 66 0B 67 2A 87 61 47 2B A4 A5 DA B4 7B 05 A4 C9 D8 B4 A4 B1 D9 B4 A4 A1 66 78 67 1F 87 62 47 18 A4 A5 DA B4 7B 05 A4 C9 D8 B4 A4 B5 D9 B4 A4 A1 66 78 67 1F 87 63 47 67 A4 A5 DA B4 68 22 69 26 6A 2B 6B 01 A4 C9 D8 B4 A4 B9 D9 B4 A4 A1 66 8C 67 8C 87 64 47 18 A4 A5 DA B4 7B 05 A4 C9 D8 B4 A4 BD D9 B4 A4 A1 66 8C 67 78 87 65 47 EC A4 A5 DA B4 7B 05 A4 C9 D8 B4 A4 C5 D9 B4 A4 A1 66 78 67 8C 87 67 47 EC A4 A5 DA B4 7B 05 A4 C9 D8 B4 A4 C1 D9 B4 A4 A1 66 0F 86 66 46 07 A4 A5 DA B4 7B 05 A4 C9 D8 B4 A4 E1 D9 B4 A4 A1 66 E0 86 6E 46 C0 A4 A5 DA B4 7B 05 A4 E5 D8 B4 A4 C1 D9 B4 A4 9E F1 65 A4 A5 30 AA A4 A1 31 55 A4 A1 DA B4 68 32 69 36 6A 3B 6B 01 A4 E5 D8 B4 A4 BD D9 B4 A4 9E 60 00 61 30 F1 55 A4 9E F0 65 81 00 A4 9F F0 65 A4 A5 30 30 A4 A1 31 00 A4 A1 DA B4 7B 05 A4 E5 D8 B4 A4 B5 D9 B4 A4 9E 66 89 F6 33 F2 65 A4 A1 30 01 14 32 31 03 14 32 32 07 14 32 A4 9E 66 41 F6 33 F2 65 A4 A1 30 00 14 32 31 06 14 32 32 05 14 32 A4 9E 66 04 F6 33 F2 65 A4 A1 30 00 14 32 31 00 14 32 32 04 14 32 A4 A5 DA B4 7B 05 A4 E5 D8 B4 A4 E1 D9 B4 A4 A1 66 04 F6 1E DA B4 7B 05 A4 E9 D8 B4 A4 ED D9 B4 A4 A5 66 FF 76 0A 36 09 A4 A1 86 66 36 04 A4 A1 66 FF 60 0A 86 04 36 09 A4 A1 86 66 36 04 A4 A1 66 FF 86 6E 86 66 36 7F A4 A1 86 66 86 6E 36 7E A4 A1 66 05 76 F6 36 FB A4 A1 66 05 86 05 36 FB A4 A1 66 05 80 67 30 FB A4 A1 DA B4 14 9C AA 55 00 00 A0 40 A0 00 A0 C0 80 E0 A0 A0 E0 C0 40 40 E0 E0 20 C0 E0 E0 60 20 E0 A0 E0 20 20 E0 C0 20 C0 60 80 E0 E0 E0 20 40 40 E0 E0 A0 E0 E0 E0 20 C0 40 A0 E0 A0 C0 E0 A0 E0 E0 80 80 E0 C0 A0 A0 C0 E0 C0 80 E0 E0 80 C0 80 00 A0 A0 40 A0 40 A0 A0 0A AE A2 42 38 08 30 B8"

-- https://github.com/Timendus/chip8-test-suite/blob/main/bin/4-flags.8o
-- data="12 A0 60 00 E0 A1 12 04 70 01 40 10 00 EE 12 04 FC 65 22 76 41 00 00 EE 80 10 22 76 42 00 00 EE 80 20 22 76 43 00 00 EE 80 30 22 76 44 00 00 EE 80 40 22 76 45 00 00 EE 80 50 22 76 46 00 00 EE 80 60 22 76 47 00 00 EE 80 70 22 76 48 00 00 EE 80 80 22 76 49 00 00 EE 80 90 22 76 4A 00 00 EE 80 A0 22 76 4B 00 00 EE 80 B0 22 76 4C 00 00 EE 80 C0 22 76 00 EE A5 57 F0 1E DD E4 7D 04 00 EE A5 5B 8E D0 8E EE 8E EE FE 1E DA B4 7A 05 00 EE A5 58 92 C0 A5 55 7B 01 DA B3 7A 04 7B FF 00 EE 00 E0 6A 32 6B 1B A6 09 DA B4 6A 3A A6 0D DA B4 6D 00 6E 00 A5 F7 22 10 6A 16 6B 00 61 0F 6D 01 22 80 63 0F 6F 14 83 F1 6F 00 62 32 82 11 8E F0 6C 3F 22 90 82 E0 6C 00 22 90 82 30 6C 1F 22 90 7A 05 6D 02 22 80 63 0F 6F 14 83 F2 6F 00 62 32 82 12 8E F0 6C 02 22 90 82 E0 6C 00 22 90 82 30 6C 04 22 90 7B 05 6A 00 6D 03 22 80 63 0F 6F 14 83 F3 6F 00 62 32 82 13 8E F0 6C 3D 22 90 82 E0 6C 00 22 90 82 30 6C 1B 22 90 7A 05 6D 04 22 80 6F 14 8F 14 84 F0 63 0F 6F 14 83 F4 6F AA 62 32 82 14 8E F0 6C 41 22 90 82 E0 6C 00 22 90 82 30 6C 23 22 90 82 40 6C 00 22 90 7A 01 6D 05 22 80 6F 14 8F 15 84 F0 63 14 6F 0F 83 F5 65 0A 6F 0A 85 F5 85 F0 6F AA 62 32 82 15 35 01 6F 02 8E F0 6C 23 22 90 82 E0 6C 01 22 90 82 30 6C 05 22 90 82 40 6C 01 22 90 7B 05 6A 00 6D 06 22 80 6F 3C 8F F6 83 F0 6F AA 62 3C 82 26 8E F0 6C 1E 22 90 82 E0 6C 00 22 90 82 30 6C 00 22 90 7A 05 6D 07 22 80 6F 0A 8F 17 84 F0 63 0F 6F 14 83 F7 65 0A 6F 0A 85 F7 85 F0 6F AA 62 0F 61 32 82 17 35 01 6F 02 8E F0 6C 23 22 90 82 E0 6C 01 22 90 82 30 6C 05 22 90 82 40 6C 01 22 90 7A 01 6D 0E 22 80 6F 32 8F FE 83 F0 6F AA 62 32 82 2E 8E F0 6C 64 22 90 82 E0 6C 00 22 90 82 30 6C 00 22 90 6D 00 6E 10 A5 FD 22 10 6A 16 6B 10 61 64 6D 04 22 80 6F C8 8F 14 84 F0 63 64 6F C8 83 F4 6F AA 62 C8 82 14 8E F0 6C 2C 22 90 82 E0 6C 01 22 90 82 30 6C 2C 22 90 82 40 6C 01 22 90 7A 01 6D 05 22 80 6F 5F 8F 15 84 F0 63 5F 6F 64 83 F5 6F AA 62 5F 82 15 8E F0 6C FB 22 90 82 E0 6C 00 22 90 82 30 6C FB 22 90 82 40 6C 00 22 90 7B 05 6A 00 6D 06 22 80 6F 3D 8F F6 83 F0 6F AA 62 3D 82 26 8E F0 6C 1E 22 90 82 E0 6C 01 22 90 82 30 6C 01 22 90 7A 05 6D 07 22 80 6F 69 8F 17 84 F0 63 69 6F 64 83 F7 6F AA 62 69 82 17 8E F0 6C FB 22 90 82 E0 6C 00 22 90 82 30 6C FB 22 90 82 40 6C 00 22 90 7A 01 6D 0E 22 80 6F BC 8F FE 83 F0 6F AA 62 BC 82 2E 8E F0 6C 78 22 90 82 E0 6C 01 22 90 82 30 6C 01 22 90 6D 00 6E 1B A6 03 22 10 6A 16 6B 1B 6D 0F 22 80 7A FF 6D 0E 22 80 A5 44 61 10 F1 1E 60 AA F0 55 A5 54 F0 65 82 00 6C AA 22 90 A5 44 6F 10 FF 1E 60 55 F0 55 A5 54 F0 65 82 00 6C 55 22 90 15 42 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 A0 C0 80 A0 40 A0 E0 A0 A0 E0 C0 40 40 E0 E0 20 C0 E0 E0 60 20 E0 A0 E0 20 20 E0 C0 20 C0 E0 80 E0 E0 E0 20 20 20 E0 E0 A0 E0 E0 E0 20 E0 40 A0 E0 A0 C0 E0 A0 E0 E0 80 80 E0 C0 A0 A0 C0 E0 C0 80 E0 E0 80 C0 80 60 80 A0 60 A0 E0 A0 A0 E0 40 40 E0 60 20 20 C0 A0 C0 A0 A0 80 80 80 E0 E0 E0 A0 A0 C0 A0 A0 A0 E0 A0 A0 E0 C0 A0 C0 80 40 A0 E0 60 C0 A0 C0 A0 60 C0 20 C0 E0 40 40 40 A0 A0 A0 60 A0 A0 A0 40 A0 A0 E0 E0 A0 40 A0 A0 A0 A0 40 40 E0 60 80 E0 00 00 00 00 00 E0 00 00 00 00 00 40 48 2C 68 68 8C 00 34 2C 70 70 8C 00 64 78 48 3C 70 00 0A AE A2 42 38 08 30 B8"

-- https://github.com/Timendus/chip8-test-suite/blob/main/bin/7-beep.8o
-- data="A2 54 F0 65 62 01 83 00 64 0B 6A 1C 6B 0C A2 54 F2 1E F1 65 A2 67 DA B7 F0 18 F0 15 22 2C DA B7 F1 15 22 2C 72 02 52 30 12 0E 12 00 E4 A1 12 38 F0 07 30 00 12 2C 00 EE 60 00 61 3C 62 0B 00 E0 A2 67 DA B7 F1 18 E2 A1 12 44 DA B7 F0 18 E2 9E 12 4C 12 40 13 0A 05 0A 05 0A 14 1E 05 1E 05 1E 14 0A 05 0A 05 0A 3C 19 2A C8 8B C8 2A 19"

-- https://github.com/mattmikolay/chip-8/blob/master/delaytimer/delay_timer_test.8o
-- data="64 00 22 1E F5 0A 45 02 76 01 45 08 76 FF 35 05 12 02 F6 15 F6 07 22 1E 36 00 12 14 12 02 00 E0 A2 3A F6 33 F2 65 63 00 F0 29 D3 45 73 05 F1 29 D3 45 73 05 F2 29 D3 45 00 EE"

-- https://github.com/mattmikolay/chip-8/blob/master/randomnumber/random_number_test.8o
-- data="65 00 00 E0 C3 FF A2 22 F3 33 F2 65 64 00 F0 29 D4 55 74 05 F1 29 D4 55 74 05 F2 29 D4 55 F3 0A 12 02"

-- My first programme! Use FX29 to render a character (4th byte) to the screen
-- data="00 E0 60 0D F0 29 D0 05 12 02"

-- Beep for v0 cycles
-- data="00 E0 60 4F F0 18 61 00 12 06"

-- Write code to memory from 512 onward
for k,v in ipairs(split(data," ")) do cpoke(0x1ff+k,hex2dec(v)) end

-- ⬅️➡️⬆️⬇️🅾️❎
function input()
    key={}
    local k=nil
    if btn(⬅️) then k=0x4 end
    if btn(➡️) then k=0x6 end
    if btn(⬆️) then k=0x2 end
    if btn(⬇️) then k=0x8 end
    if k then key[k]=true key[17]=k end
end

function timers()
    if dt>0 then dt-=1 end
    if st>0 then
        st-=1
        sfx(0)
        if st==0 then sfx(-2) end
    end
end

function fetch()
    op1=cpeek(pc)
    op2=cpeek(pc+1)
    printh('pc='..pc..' op1='..op1..' op2='..op2..' '..tostr(op1,1)..' '..tostr(op2,1))
    assert(op1+op2>0,op2)
    pc+=2
end

function decode()
    o=(op1&0xf0)>>4
    x=op1&0xf
    y=(op2&0xf0)>>4
    n=op2&0xf
    nn=op2
    nnn=(x<<8)|nn
end

function execute()
    local tx,ty=x+1,y+1
    if o==0x0 and nnn==0x0e0 then
        -- Clears the screen
        cls()
    elseif o==0x0 and nnn==0x0ee then
        -- Returns from a subroutine
        pc=deli(ps)
    elseif o==0x0 then
        -- Calls machine code routine (RCA 1802 for COSMAC VIP) at address NNN
    elseif o==0x1 then
        -- Jumps to address NNN
        pc=nnn
    elseif o==0x2 then
        -- Calls subroutine at NNN
        add(ps,pc)
        pc=nnn
    elseif o==0x3 then
        -- Skips the next instruction if VX equals NN
        if v[tx]==nn then pc+=2 end
    elseif o==0x4 then
        -- Skips the next instruction if VX does not equal NN
        if v[tx]!=nn then pc+=2 end
    elseif o==0x5 and n==0 then
        -- Skips the next instruction if VX equals VY
        if v[tx]==v[ty] then pc+=2 end
    elseif o==0x6 then
        -- Sets VX to NN
        v[tx]=nn&0xff
    elseif o==0x7 then
        -- Adds NN to VX
        v[tx]=(v[tx]+nn)&0xff
    elseif o==0x8 then
        if n==0x0 then
            -- Sets VX to the value of VY
            v[tx]=v[ty]
        elseif n==0x1 then
            -- Sets VX to VX or VY
            v[tx]=v[tx]|v[ty]
        elseif n==0x2 then
            -- Sets VX to VX and VY
            v[tx]=v[tx]&v[ty]
        elseif n==0x3 then
            -- Sets VX to VX xor VY
            v[tx]=v[tx]^^v[ty]
        elseif n==0x4 then
            -- Adds VY to VX. VF is set to 1 when there's an overflow, and to 0 when there is not
            v[tx]+=v[ty]
            if v[tx]>255 then v[tx]=v[tx]&0xff v[16]=1 else v[16]=0 end
        elseif n==0x5 then
            -- VY is subtracted from VX. VF is set to 0 when there's an underflow, and 1 when there is not
            local vf=v[tx]>=v[ty] and 1 or 0
            v[tx]=(v[tx]-v[ty])&0xff
            v[16]=vf
        elseif n==0x6 then
            -- Shifts VX to the right by 1, then stores the least significant bit of VX prior to the shift into VF
            local vf=v[tx]&1>0 and 1 or 0
            v[tx]=flr(v[tx]>>1)
            v[16]=vf
        elseif n==0x7 then
            -- Sets VX to VY minus VX. VF is set to 0 when there's an underflow, and 1 when there is not
            local vf=v[ty]>=v[tx] and 1 or 0
            v[tx]=(v[ty]-v[tx])&0xff
            v[16]=vf
        elseif n==0xe then
            -- Shifts VX to the left by 1, then sets VF to 1 if the most significant bit of VX prior to that shift was set, or to 0 if it was unset.
            local vf=v[tx]&0x80>0 and 1 or 0
            v[tx]=(v[tx]<<1)&0xff
            v[16]=vf
        end
    elseif o==0x9 and n==0 then
        -- Skips the next instruction if VX does not equal VY
        if v[tx]!=v[ty] then pc+=2 end
    elseif o==0xa then
        -- Sets I to the address NNN
        i=nnn
    elseif o==0xb then
        -- Jumps to the address NNN plus V0
        pc=nnn+v[1]
    elseif o==0xc then
        -- Sets VX to the result of a bitwise and operation on a random number and NN
        v[tx]=flr(rnd(256))&nn
    elseif o==0xd then
        -- Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels
        v[16]=0
        local vx,vy=v[tx],v[ty]
        for h=0,n-1 do
            local byte=cpeek(i+h)
            for w=0,7 do
                local sx,sy=vx+w,vy+h
                local mask=2^(7-w)
                local bit=byte&mask
                local px=sget(sx,sy)
                local col=7
                if bit>0 then
                    if px>0 then col=0 v[16]=1 end
                    sset(sx,sy,col)
                end
            end
        end
    elseif o==0xe then
        if nn==0x9e then
            -- Skips the next instruction if the key stored in VX (only consider the lowest nibble) is pressed
            if key[v[tx]&0xf] then pc+=2 end
        elseif nn==0xa1 then
            -- Skips the next instruction if the key stored in VX (only consider the lowest nibble) is not pressed
            if not key[v[tx]&0xf] then pc+=2 end
        end
    elseif o==0xf then
        if nn==0x07 then
            -- Sets VX to the value of the delay timer
            v[tx]=dt
        elseif nn==0x0a then
            -- A key press is awaited, and then stored in VX
            if key[17] then v[tx]=key[17] else pc-=2 end
        elseif nn==0x15 then
            -- Sets the delay timer to VX
            dt=v[tx]
        elseif nn==0x18 then
            -- Sets the sound timer to VX
            st=v[tx]
        elseif nn==0x1e then
            -- Adds VX to I. VF is not affected
            i+=v[tx]
        elseif nn==0x29 then
            -- Sets I to the location of the sprite for the character in VX
            i=0x50+v[tx]*5
        elseif nn==0x33 then
            -- Stores the binary-coded decimal representation of VX
            cpoke(i,flr(v[tx]/100))
            cpoke(i+1,flr(v[tx]%100/10))
            cpoke(i+2,flr(v[tx]%10))
        elseif nn==0x55 then
            -- Stores from V0 to VX (including VX) in memory, starting at address I
            for a=0,x do
                cpoke(i+a,v[a+1])
            end
        elseif nn==0x65 then
            -- Fills from V0 to VX (including VX) with values from memory, starting at address I
            for a=0,x do
                v[a+1]=cpeek(i+a)
            end
        end
    end
end

function _update60()
    input()
    fetch()
    decode()
    execute()
    timers()
end

function _draw()
    spr(0,0,0,8,4)
end

__sfx__
000600000415004150073000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
