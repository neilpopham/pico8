player=class:new({
    reset=function(_ENV)

    end,
    update=function(_ENV)
        printh('x='..x..' y='..y)
    end,
    draw=function(_ENV)
        spr(32,x,y,2,2)
    end,


})

p=player:new({x=64,y=64})
p:reset()