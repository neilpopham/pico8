function dumptable(t,l)
 l=l or 0
 local p=""
 for i=0,l do
  p=p.."  "
 end
 local i=0
 for k,v in pairs(t) do
  i+=1
  if type(v)=="table" then
   printh(p..k.. " => (table)")
   dumptable(v,l+1)
  else
   local t=type(v)
   if v==nil then v="nil" end
   if type(v)=="boolean" then v=v and "true" or "false" end
   printh(p..k.. " => "..v.." ("..t..")")
  end
 end
 if i==0 then printh(p.."(empty)") end
end

function keywithfixedlengths(data,l)
    local items,r=split(data,";"),{}
    for item in all(items) do
        local b,d=split(item),{}
        local k=b[1]
        r[k]={}
        for i=2,#b do
            add(d,b[i])
            if #d==l then add(r[k],d) d={} end
        end
    end
    return r
end

function keywithfixedlength(data,l)
    local b,m,r,d=split(data),l+1,{},{}
    for i=1,#b do
        if i%m==1 then k=b[i] else add(d,b[i]) end
        if i%m==0 then r[k]=d d={} end
    end
    return r
end

function fixedlength(data,l)
    local b,r,d=split(data),{},{}
    for i=1,#b do
        add(d,b[i])
        if #d==l then add(r,d) d={} end
    end
    return r
end

function random(n) return flr(rnd(n))+1 end

function tile(v) return v\8 end

function los(a,b,c,d)
    local z,e,f,t=.5,a-c,b-d
    local g,h=abs(e),abs(f)
    g=max(1,max(g,h))
    repeat
        c+=e/g
        d+=f/g
        -- pset(c*8+3,d*8+3)
        t=mget(c+z,d+z)
        if t==0 or fget(mget(c+z,d+z),0) then return end
    until a==(c+z)\1 and b==(d+z)\1
    return true
end