pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

-- https://tobiasvl.github.io/blog/write-a-chip-8-emulator/
-- https://en.wikipedia.org/wiki/CHIP-8#The_stack
-- https://johnearnest.github.io/Octo/

-- mode 3: 64x64
poke(0x5f2c,3)

printh('========================================')

local pc=0
local v=split("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")
local stack={}
local dt=60
local st=60
local i=0

local op1,op2,opcode,o,x,y,n,nn,nnn

function cpoke(a,v)
    poke(0x4300+a,v)
end

function cpeek(a)
    return peek(0x4300+a)
end

local data="00 E0 A2 2A 60 0C 61 08 D0 1F 70 09 A2 39 D0 1F A2 48 70 08 D0 1F 70 04 A2 57 D0 1F 70 08 A2 66 D0 1F 70 08 A2 75 D0 1F 12 28 FF 00 FF 00 3C 00 3C 00 3C 00 3C 00 FF 00 FF FF 00 FF 00 38 00 3F 00 3F 00 38 00 FF 00 FF 80 00 E0 00 E0 00 80 00 80 00 E0 00 E0 00 80 F8 00 FC 00 3E 00 3F 00 3B 00 39 00 F8 00 F8 03 00 07 00 0F 00 BF 00 FB 00 F3 00 E3 00 43 E0 00 E0 00 80 00 80 00 80 00 80 00 E0 00 E0"
data=split(data," ")

function fetch()
    if data[pc+1]==nil then op1,op2=0,0 return end
    op1=tonum("0x"..data[pc+1])
    op2=tonum("0x"..data[pc+2])
    printh(op1..' '..op2)
    pc+=2
end

function decode()
    -- o=(opcode&0xf000)>>12
    -- x=(opcode&0x0f00)>>8
    -- y=(opcode&0x00f0)>>4
    -- n=opcode&0xf
    -- nn=opcode&0xff
    -- nnn=opcode&0xfff
    o=(op1&0xf0)>>4
    x=op1&0xf
    y=(op2&0xf0)>>4
    n=op2&0xf
    nn=op2
    nnn=(x<<8)|nn
    printh('o='..o..' x='..x..' y='..y..' n='..n..' nn='..nn..' nnn='..nnn)
    -- assert(false)
end

function execute()
    local tx,ty=x+1,y+1
    if o==0x0 and nn==0xe0 then
        -- Clears the screen
        cls()
    elseif o==0x0 and nn==0xee then
        -- Returns from a subroutine
    elseif o==0x0 then
        -- Calls machine code routine (RCA 1802 for COSMAC VIP) at address NNN
    elseif o==0x1 then
        -- Jumps to address NNN
    elseif o==0x2 then
        -- Calls subroutine at NNN
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
        v[tx]=nn
    elseif o==0x7 then
        -- Adds NN to VX
        v[tx]+=nn
    elseif o==0x8 then
        if n==0x0 then
            -- Sets VX to the value of VY
            v[tx]=v[ty]
        elseif n==0x1 then
            -- Sets VX to VX or VY. (bitwise OR operation)
            v[tx]=v[tx]|v[ty]
        elseif n==0x2 then
            -- Sets VX to VX and VY. (bitwise AND operation)
            v[tx]=v[tx]&v[ty]
        elseif n==0x3 then
            -- Sets VX to VX xor VY
            v[tx]=v[tx]^^v[ty]
        elseif n==0x4 then
            -- Adds VY to VX. VF is set to 1 when there's an overflow, and to 0 when there is not
            v[tx]+=v[ty]
            v[16]=v[tx]<0 and 1 or 0
        elseif n==0x5 then
            -- VY is subtracted from VX. VF is set to 0 when there's an underflow, and 1 when there is not. (i.e. VF set to 1 if VX >= VY and 0 if not)
            v[tx]-=v[ty]
            v[16]=v[tx]>=v[ty] and 1 or 0
        elseif n==0x6 then
            -- Shifts VX to the right by 1, then stores the least significant bit of VX prior to the shift into VF
                v[16]=v[tx]&1
                v[tx]=v[tx]>>1
        elseif n==0x7 then
            -- Sets VX to VY minus VX. VF is set to 0 when there's an underflow, and 1 when there is not. (i.e. VF set to 1 if VY >= VX)
            v[tx]=v[ty]-v[tx]
            v[16]=v[ty]>=v[tx] and 1 or 0
        elseif n==0xe then
            -- Shifts VX to the left by 1, then sets VF to 1 if the most significant bit of VX prior to that shift was set, or to 0 if it was unset.
            v[16]=v[tx]&0x80
            v[tx]=v[tx]>>1
        end
    elseif o==0x9 and n==0 then
        -- Skips the next instruction if VX does not equal VY
        if v[tx]!=v[ty] then pc+=2 end
    elseif o==0xa then
        -- Sets I to the address NNN
        i=nnn
        printh('i '..i)
    elseif o==0xb then
        -- Jumps to the address NNN plus V0
        p=nnn+v[1]
    elseif o==0xc then
        -- Sets VX to the result of a bitwise and operation on a random number (Typically: 0 to 255) and NN
        v[tx]=flr(rnd(256))&nn
    elseif o==0xd then
        -- Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels
        local vx,vy=v[tx],v[ty]
        for h=0,n-1 do
            for w=0,7 do
                local sx,sy=vx+w,vy+h
                c=sget(sx,sy)
                printh('sx='..sx..' sy='..sy..' c='..c)
                sset(sx,sy,c==0 and 7 or 0)
            end
        end
        -- spr(0,0,0,8,4)
        assert(false)
    elseif o==0xe then
        if nn==0x9e then
            -- Skips the next instruction if the key stored in VX(only consider the lowest nibble) is pressed
            if key[v[tx]] then pc+=2 end
        elseif nn==0xa1 then
            -- Skips the next instruction if the key stored in VX(only consider the lowest nibble) is not pressed
            if not key[v[tx]] then pc+=2 end
        end
    elseif o==0xf then
        if nn==0x07 then
            -- Sets VX to the value of the delay timer
            v[tx]=dt
        elseif nn==0x0a then
            -- A key press is awaited, and then stored in VX
            if not key[17] then pc-=2 else v[tx]=key[17] end
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
        elseif nn==0x33 then
            -- Stores the binary-coded decimal representation of VX
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
    fetch()
    decode()
    execute()
    dt-=1
    st-=1
end

function _draw()
    spr(0,0,0,8,4)
end

-- __map__
-- 0101022060006108001070090239001002487008001070040257001070080266001070080275001012280000000030003000300030000000000000000038003000300038000000008000000000008000800000000000800800000030003000300039000800080300070000000000000003000300430000000080008000800080
-- 0001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 0000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
00E0A22A600C6108D01F7009A239D01FA2487008D01F7004A257D01F7008A266D01F7008A275D01F1228FF00FF003C003C003C003C00FF00FFFF00FF0038003F003F003800FF00FF8000E000E00080008000E000E00080F800FC003E003F003B003900F800F8030007000F00BF00FB00F300E30043E000E00080008000800080
00E000E000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
