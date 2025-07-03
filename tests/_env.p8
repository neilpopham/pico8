pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- ⬅️➡️⬆️⬇️🅾️❎

-- Using _𝘦𝘯𝘷 in PICO-8
-- https://www.lexaloffle.com/bbs/?tid=49047
-- https://www.lexaloffle.com/bbs/?tid=38894

-- local _G=_ENV

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

global=_ENV

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

-- object

-- entity=class:new({x=1,y=2})

-- pixel=class:new({
--     local o=class:new({x=10,y=20})

-- })

object={
    create=function(_ENV,x,y)
        return class:new({x=x,y=y})
    end
}

pixel={
    create=function(_ENV,x,y,dir)
        local o=object:create(x,y)
        o.dir=dir
        return o
    end
} setmetatable(pixel,object)

o=object:create(1,2)
p=pixel:create(10,20)
cls()
print(o.x,0,0)
print(p.x,0,10)

for x in all(o.x) do
    print(x,0,20)
end