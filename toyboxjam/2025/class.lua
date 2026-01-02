class = setmetatable(
    {
        new = function(_ENV, tbl)
            return setmetatable(tbl or {}, { __index = _ENV })
        end,
        foo = function(_ENV)
            return x .. ',' .. y
        end
    },
    { __index = _ENV }
)