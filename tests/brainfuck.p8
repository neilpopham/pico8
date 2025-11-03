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
    instructions,
    count,
    cells,
    errors,
    stdin,
    stdout,
    brackets,
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
            add(self.stdout,self:current())
            return 1
        end,
        [44]=function(self)
            self.cells[self.p]=deli(self.stdin,1)
            return 1
        end,
        [91]=function(self)
            if self:current()==0 then
                self.i=self.brackets[self.i]
            end
            return 1
        end,
        [93]=function(self)
            if self:current()==0 then return 1 end
            self.i=self.brackets[self.i]+1
            return 0
        end,
    },
    current=function(self)
        return self.cells[self.p] and self.cells[self.p] or 0
    end,
    run=function(self, code)
        self:parse(code)
        if #code==0 then return end
        local o
        repeat
            o=self:exec()
        until o==false
    end,
    start=function(self, code)
        self:parse(code)
    end,
    step=function(self)
        local t=self.t
        while t==self.t do
            o=self:exec()
        end
    end,
    exec=function(self)
        local c=self.instructions[self.i].c
        local step=self.command[c](self)
        self.t+=1
        self.i+=step
        if self.i>self.count then
            return false
        else
            return true
        end
    end,
    parse=function(self,code)
        code=tostr(code)
        self.code=code
        self.p,self.i,self.t,self.count=1,1,0,0
        self.brackets,self.instructions,self.cells,self.stdin,self.stdout={},{},{},{},{}
        for s=1,#code do
            local o=sub(self.code,s,s)
            local c=ord(o)
            if self.command[c] then
                self.count+=1
                self.instructions[self.count]={c=c,s=s}
            end
        end
        local open={}
        for i,ins in pairs(self.instructions) do
            if ins.c==91 then add(open,i) end
            if ins.c==93 then
                if #open>0 then
                    self.brackets[i]=deli(open)
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
        for k,v in pairs(self.brackets) do self.brackets[v]=k end
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
machine:run('>++++[>++++++<-]>-[[<+++++>>+<-]>-]<<[<]>>>>--.<<<-.>>>-.<.<.>---.<<+++.>>>++.<<---.[>]<<.')
machine:dump()


-- stop()

machine:start('+(hello)>[++]')
machine:step()
machine:dump()
machine:step()
machine:dump()

