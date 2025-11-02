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

machine={
    code,
    p,
    i,
    t,
    b,
    cells,
    stdin,
    stdout,
    command={
        [62]=function(self)
            if self.p==32767 then
                self.p=1
            else
                self.p+=1
            end
            return 1
        end,
        [60]=function(self)
            if self.p==1 then
                self.p=32767
            else
                self.p-=1
            end
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
            add(self.stdout, self:current())
            return 1
        end,
        [44]=function(self)
            self.cells[self.p]=deli(self.stdin,1)
            return 1
        end,
        [91]=function(self)
            if self:current()>0 then
                add(self.b,self.i+1)
                return 1
            end
            local open,char=0
            repeat
                self.i+=1
                char=sub(self.code,self.i,self.i)
                if char=='[' then
                    open+=1
                elseif char==']' and open>0 then
                    open-=1
                    char=' '
                end
            until char==']' or char==''
            return char==']' and 1 or 0
        end,
        [93]=function(self)
            if self:current()==0 then
                deli(self.b)
                return 1
            end
            self.i=self.b[#self.b]
            return 0
        end,
    },
    current=function(self)
        return self.cells[self.p] and self.cells[self.p] or 0
    end,
    reset=function(self)
        self.code,self.p,self.i,self.t,self.b,self.cells,self.stdin,self.stdout='',1,1,0,{},{},{},{}
    end,
    run=function(self, code)
        self:reset()
        code=tostr(code)
        self.code=code
        if #code==0 then return end
        local o
        repeat
            o=self:exec()
        until o==''
    end,
    exec=function(self)
        local o=sub(self.code,self.i,self.i)
        if o=='' then return o end
        local c,step=ord(o),1
        if self.command[c] then
            step=self.command[c](self)
            self.t+=1
        end
        self.i+=step
        return o
    end,
    dump=function(self)
        printh('== dump ==')
        printh('p='..self.p)
        printh('i='..self.i)
        printh('t='..self.t)
        printh('cells='..#self.cells)
        for k,v in pairs(self.cells) do
            printh(k..'='..v)
        end
        printh(#self.stdout)
        for k,v in pairs(self.stdout) do
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
-- machine:run('+ (hello) +'
-- machine:run('+>>+++++++++++++++++++++++++++++<<[>>>[>>]<[[>>+<<-]>>-[<<]]>+<<[-<<]<]>+>>[-<<]<+++++++++[>++++++++>+<<-]>-.----.>.')
-- machine:run('+>[++[++[-]][>]>>]-')
-- machine:run('>+>+>+>+>+>+>+[->[>]+[->[>]+>+>+[<]+<]+<]+++++++[>+++++++++++>+<<-]>+.----.>++.')
machine:run('>++++[>++++++<-]>-[[<+++++>>+<-]>-]<<[<]>>>>--.<<<-.>>>-.<.<.>---.<<+++.>>>++.<<---.[>]<<.')
machine:dump()
