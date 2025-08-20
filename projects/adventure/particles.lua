particles_fg,particles_bg={},{}

dust=class:new({
    update=function(_ENV)
        dy=mid(-2,dy-g,3)
        y=y-dy
        if y>oy then
            del(col,_ENV)
        end
    end,
    draw=function(_ENV)
        pset(x,y,1)
    end
})

function create_dust(x1,x2,y,dy,a)
    local mx=x1+((x2-x1)/2)
    for i=1,a do
        local col=i%2==0 and particles_fg or particles_bg
        local x=range(x1,x2)
        local dy=mid(1,rnd()+dy-abs(mx-x),3)
        add(col,dust:new({x=x,y=y,dy=dy,oy=y,col=col,g=range(2,6)/10}))
    end
end