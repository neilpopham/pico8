pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- ⬅️➡️⬆️⬇️🅾️❎

-- Using _𝘦𝘯𝘷 in PICO-8
-- https://www.lexaloffle.com/bbs/?tid=49047
-- https://www.lexaloffle.com/bbs/?tid=38894

_G=_ENV

-- local core={
--     create=function(_ENV,x,y)
--         return {x=x,y=y}
--     end
-- } setmetatable(core,{__index=_G})

-- local pixel={
--     create=function(_ENV,x,y,dir)
--         o=core:create(x,y)
--         o.dir=dir
--     end
-- } setmetatable(pixel,object)

-- o=core:create(1,2)

-- p=pixel:create(10,20,1)

-- cls()

-- print(o.x,0,0)
-- print(p.x,10,0)

class=setmetatable(
    {
        new=function(_ENV,tbl)
            tbl=tbl or {}
            setmetatable(tbl,{__index=_ENV})
            return tbl
        end,
    },
    {__index=_ENV}
)

entity=class:new({x=1,y=2})
print(entity.x,0,0)

pixel=class:new({
    x=10,
    y=20,
    update=function(_ENV)
        x+=1
    end,
    draw=function(_ENV)

    end
})

-- =================================

p2=setmetatable(
    {
        create=function(self,x,y,d)
            local o=setmetatable(
                {
                    x=x,
                    y=y,
                    d=d,
                },
                self
            )
            self.__index=self
            return o
        end,
        fn1=function(_ENV)
            return tostr(x)..'.'..tostr(y)..'.'..tostr(d)..'.'..'f1'
        end,
        update=function(_ENV)
            printh('there')
            y+=1
        end
    },
    {__index=_ENV}
)

f2=setmetatable(
    {
    create=function(self,x,y,d,z)
        local o=setmetatable(
            {
                x=x,
                y=y,
                d=d,

            },
            self
        )
        self.__index=self
        return o
    end,
    fn2=function(_ENV)
        return tostr(x)..'.'..tostr(y)..'.'..tostr(d)..'.'..'f2'
    end,
    update=function(_ENV)
        printh('here')
        p2.update(_ENV)
        x+=1
    end
    },
    {__index=p2}
)

p2a=p2:create(1,2,3)
f2a=f2:create(10,20,30)

-- ======================================

function _init()

end

function _update60()
    pixel:update()
    f2a:update()
    p2a:update()
end

function _draw()
    cls()
    print(entity.x,0,0)
    print(pixel.x,0,10)

    print(p2a.x,0,20)
    print(p2a:fn1(),20,20)
    print(f2a.x,0,30)
    print(f2a:fn1(),20,30)
    print(f2a:fn2(),80,30)
end

-- object={
--     create=function(_ENV,x,y)
--         return class:new({x=x,y=y})
--     end
-- }

-- pixel={
--     create=function(_ENV,x,y,dir)
--         local o=object:create(x,y)
--         o.dir=dir
--         return o
--     end
-- } setmetatable(pixel,object)

-- o=object:create(1,2)
-- p=pixel:create(10,20)
-- cls()
-- print(o.x,0,0)
-- print(p.x,0,10)

-- for x in all(o.x) do
--     print(x,0,20)
-- end