drip=entity:new({
    reset=function(_ENV)
        pause,t,x,y,dy,s,mdy,c=range(10,120),0,ox,oy,0,0,range(4,5),13
    end,
    update=function(_ENV)
        t+=1
        if s==0 then
            if t<pause then return end
            dy=max(mdy,dy+.01)
            y+=dy
            ty=y\8
            if fget(mget(x\8,ty),0) then
                y=(ty-1)*8+7
                s,dy,my,c=1,-2,y,7
            end
        elseif s==1 then
            dy+=0.4
            y+=dy
            if y>my then t=0 s=2 end
        elseif t>pause then
            reset(_ENV)
        end
    end,
    draw=function(_ENV)
        if s<2 then pset(x,y,c) end
    end
})