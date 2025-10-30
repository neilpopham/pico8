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
    code='',
    p=1,
    i=1,
    b={},
    cells={},
    stdin={},
    stdout={},
    command={
        [62]=function(self)
            printh('parsing >')
            self.p+=1
            return 1
        end,
        [60]=function(self)
            printh('parsing <')
            self.p-=1
            return 1
        end,
        [43]=function(self)
            printh('parsing +')
            printh(self.cells[self.p])
            if self.cells[self.p]==nil then
                self.cells[self.p]=1
            else
                self.cells[self.p]+=1
                self.cells[self.p]=self.cells[self.p]&0xff
            end
            return 1
        end,
        [45]=function(self)
            printh('parsing -')
            if self.cells[self.p]==nil then
                self.cells[self.p]=255
            else
                self.cells[self.p]-=1
                self.cells[self.p]=self.cells[self.p]&0xff
            end
            return 1
        end,
        [46]=function(self)
            add(self.stdout, self.cells[self.p])
            return 1
        end,
        [44]=function(self)
            self.cells[self.p]=deli(self.stdin,1)
            return 1
        end,
        [91]=function(self)
            add(self.b,self.i)
            if self.cells[self.p]==0 then
                local s
                repeat
                    s=sub(self.code,self.i,self.i)
                    printh('s='..s)
                    self.i+=1
                until s==']' or s==''
            end
            return 1
        end,
        [93]=function(self)
            printh('b='..tostr(#self.b))
            printh('cell='..self.cells[self.p])
            if self.cells[self.p]==0 then return 1 end
            assert(#self.b>0)
            self.i=deli(self.b)
            printh('i='..self.i)
            return 0
        end,
    },
    exec=function(self,code)
        code=tostr(code)
        self.code=code
        if #code==0 then return end
        local o
        repeat
            o=sub(code,self.i,self.i)
            printh('operation='..o)
            local c=ord(o)
            if self.command[c]==nil then break end
            assert(self.command[c]!=nil)
            printh('i was '..self.i)
            local step=self.command[c](self)
            printh('step='..step)
            self.i+=step
            printh('i is now '..self.i)
        until o==''
    end,
    dump=function(self)
        printh('p='..self.p)
        printh('i='..self.i)
        printh(#self.cells)
        for k,v in pairs(self.cells) do
            printh(k..'='..v)
        end
    end
}

printh('-------------------')

-- machine:exec('[++]---->++++>[-]+')
-- machine:exec('[++]')
machine:exec('---->++++>[-]+')

machine:dump()