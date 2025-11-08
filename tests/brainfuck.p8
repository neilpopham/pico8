pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

-- >	Increment the data pointer by one (to point to the next cell to the right).
-- <	Decrement the data pointer by one (to point to the next cell to the left).
-- +	Increment the byte at the data pointer by one.
-- -	Decrement the byte at the data pointer by one.
-- .	Output the byte at the data pointer.
-- ,	Accept one byte of input, storing its value in the byte at the data pointer.
-- [	If the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command.
-- ]	If the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command.

-- local o='><+-.,[]'
-- for i=1,#o do
--     printh(ord(o,i))
-- end

-- INFO: 62
-- INFO: 60
-- INFO: 43
-- INFO: 45
-- INFO: 46
-- INFO: 44
-- INFO: 91
-- INFO: 93

function hex(v)
    local s,l,r=tostr(v,true),3,11
    while(ord(s,l)==48) l+=1
    while(ord(s,r)==48) r-=1
    return sub(s,l<r and l or 6,r>7 and r or 6)
end

function digits(n,d,c1,c2)
    local s,r=tostr(n),''
    local z=d-#s
    if z>0 then r=r..'\f'..hex(c1)..'\*'..z..'0' end
    return r..'\f'..hex(c2)..s
end

machine={
    code,
    p,
    i,
    t,
    instructions,
    count,
    cells,
    errors,
    stdin,
    stdout,
    brackets,
    errors,
    done,
    command={
        [62]=function(self)
            if self.p==32767 then self.p=1 else self.p+=1 end
            return 1
        end,
        [60]=function(self)
            if self.p==1 then self.p=32767 else self.p-=1 end
            return 1
        end,
        [43]=function(self)
            self.cells[self.p]=(self:current()+1)&0xff
            return 1
        end,
        [45]=function(self)
            self.cells[self.p]=(self:current()-1)&0xff
            return 1
        end,
        [46]=function(self)
            add(self.stdout,self:current())
            return 1
        end,
        [44]=function(self)
            if #self.stdin>0 then self.cells[self.p]=ord(deli(self.stdin,1)) end
            return 1
        end,
        [91]=function(self)
            if self:current()==0 then self.i=self.brackets[self.i] end
            return 1
        end,
        [93]=function(self)
            if self:current()==0 then return 1 end
            self.i=self.brackets[self.i]+1
            return 0
        end,
    },
    cell=function(self,p)
        return self.cells[p] and self.cells[p] or 0
    end,
    current=function(self)
        return self:cell(self.p)
    end,
    run=function(self, code)
        self:parse(code)
        if self.count==0 then return end
        local o
        repeat
            self:exec()
        until self.done
    end,
    load=function(self, code)
        self:parse(code)
    end,
    step=function(self)
        self:exec()
    end,
    exec=function(self)
        if self.done then return end
        local opcode=self.instructions[self.i].opcode
        local step=self.command[opcode](self)
        self.t+=1
        self.i+=step
        self.done=self.i>self.count
    end,
    parse=function(self,code)
        code=tostr(code)
        self.p,self.i,self.t,self.count=1,1,0,0
        self.brackets,self.instructions,self.cells,self.stdout,self.errors={},{},{},{},{}
        self.code=code
        self.done=false
        self.stdin=split('hello world!','')
        for s=1,#code do
            local o=sub(self.code,s,s)
            local c=ord(o)
            if self.command[c] then
                self.count+=1
                self.instructions[self.count]={opcode=c,position=s}
            end
        end
        local open,closed={},{}
        for i,ins in pairs(self.instructions) do
            if ins.opcode==91 then add(open,i) end
            if ins.opcode==93 then
                if #open>0 then
                    closed[i]=deli(open)
                else
                    add(self.errors,{i=i,code=2})
                end
            end
        end
        if #open>0 then
            for i in all(open) do
                add(self.errors,{i=i,code=1})
            end
        end
        for k,v in pairs(closed) do
            self.brackets[k]=v
            self.brackets[v]=k
        end
        return #self.errors==0

    end,
    dump=function(self)
        printh('== dump ==')
        printh('p='..self.p)
        printh('i='..self.i)
        printh('t='..self.t)
        printh('cells='..#self.cells)
        for k,v in ipairs(self.errors) do
            printh('error at '..v.i..' code '..v.code)
        end
        for k,v in pairs(self.cells) do
            printh(k..'='..v)
        end
        printh(#self.stdout)
        for k,v in ipairs(self.stdout) do
            printh(k..'='..v.. ' or '..chr(v))
        end
    end
}

printh('-------------------')

-- machine:run('[++]---->++++>[-]+')
-- machine:run('[++]')
-- machine:run('+++[+[--]]++')
-- machine:run('++++[--]+>-.<.')
-- machine:run('++[--[+]]')
-- machine:run('++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.')
-- machine:run('++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]')
-- machine:run('+++[+[--]>]++')
-- machine:run('+[+++++++++++++++++++++++++++++++++.<]')
-- machine:run('+ (hello) +')
-- machine:run('+>>+++++++++++++++++++++++++++++<<[>>>[>>]<[[>>+<<-]>>-[<<]]>+<<[-<<]<]>+>>[-<<]<+++++++++[>++++++++>+<<-]>-.----.>.')
-- machine:run('+>[++[++[-]][>]>>]-')
-- machine:run('>+>+>+>+>+>+>+[->[>]+[->[>]+>+>+[<]+<]+<]+++++++[>+++++++++++>+<<-]>+.----.>++.')
-- machine:run('>++++[>++++++<-]>-[[<+++++>>+<-]>-]<<[<]>>>>--.<<<-.>>>-.<.<.>---.<<+++.>>>++.<<---.[>]<<.')

machine:run('Brainfuck test program written by Robert de Bath \
Length is 140 instructions \
It needs 7 cells \
It checks for a number of mistakes commonly made in simple interpreters \
 \
>++++++++[-<+++++++++>]<.>>+>-[+]++ \
>++>+++[>[->+++<<+++>]<<]>-----.>-> \
+++..+++.>-.<<+[>[+>+]>>]<--------- \
-----.>>.+++.------.--------.>+.>+.')
machine:dump()

machine:run('Brainfuck test program written by Robert de Bath in 2017 \
Length is 105 instructions \
It needs 14 cells \
It checks for many mistakes commonly made in simple interpreters \
 \
+[>[<->+[>+++>[+++++++++++>][]-[<]> \
-]]++++++++++<]>>>>>>----.<<+++.<-. \
.+++.<-.>>>.<<.+++.------.>-.<<+.<.')
machine:dump()

-- machine:run('>,[>,]<[.<]')
-- machine:dump()

-- stop()

-- machine:load('+(hello)>[++]')
-- machine:step()
-- machine:dump()
-- machine:step()
-- machine:dump()

function _init()
    -- machine:load('++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.')
    -- machine:load('>,[>,]<[.<]')
    -- machine:load('+>>+++++++++++++++++++++++++++++<<[>>>[>>]<[[>>+<<-]>>-[<<]]>+<<[-<<]<]>+>>[-<<]<+++++++++[>++++++++>+<<-]>-.----.>.')
    machine:load('>+>+>+>+>+>+>+[->[>]+[->[>]+>+>+[<]+<]+<]+++++++[>+++++++++++>+<<-]>+.----.>++.')
    speed=5
    t=0
end

function _update60()
    if t%speed==0 then machine:step() end
    t+=1
end

function _draw()
    cls()
    local o=split('><+-.,[]','')
    for k,c in ipairs(o) do
        local o=k-1
        rect(o*10,38,8+(o*10),46,1)
        print(c,3+(o*10),40,7)
    end
    rect(8*10,38,88,46,9)
    spr(1,82,40)
    -- rect(7,38,15,46,1)
    -- print('>',10,40,7)
    -- rect(17,38,25,46,1)
    -- print('<',20,40,7)

    local p=machine.p\20
    local s=p*20
    for c=s,s+19 do
        local p,x,y=c+1,c%5,c%20\5
        print(digits(c,5,5,p==machine.p and 9 or 7),x*27,78+y*13,3)
        print(digits(machine:cell(p),3,1,12),8+x*27,84+y*13,3)
    end


    -- print('\f5\*40\f60',0,117)
    -- print('  \f100\fc9',0,123)
    -- print('\f5\*40\f61',24,117)
    -- print('  \f10\fc25',24,123)

    -- print(digits(12,4,2,8),0,90)
    -- print(digits(1234,4,2,8),20,90)

    -- You can set your own button delay by poking memory 0X5F5C like this:
    -- POKE(0X5F5C, DELAY)
    -- You can set it to 255 to stop the btnp from resetting automatically at all, so that the player must release the button and press again for it to trigger again.
    -- You can set your own repeating delay by poking memory 0X5F5D like this:
    -- POKE(0X5F5D, DELAY)
end

__gfx__
0000000000eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ee0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ee0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
