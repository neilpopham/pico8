-- advanced particle system
-- blog.ccatgames.com

function _init()
  make_sparks_ps(64,64)
end

function _update()
    update_psystems()

    if (btnp(1)) then
        currdemo += 1
        if (currdemo>count(demos)) then
            currdemo = 1
         end
         deleteallps()
         demos[currdemo].createfunc()
    end
    if (btnp(0)) then
        currdemo -= 1
        if (currdemo<=0) then
            currdemo = count(demos)
         end
         deleteallps()
         demos[currdemo].createfunc()
    end
    if (btnp(5)) then
        demos[currdemo].createfunc()
        --make_smoke_ps(rnd(107)+10,rnd(107)+10)
    end
end

function _draw()
    cls()
    for ps in all(particle_systems) do
        draw_ps(ps)
    end
    print(demos[currdemo].name,0,0,7)
    print(demos[currdemo].desc,0,8,7)
    print("left/right to change demo", 0, 112, 5)
    print("x to spawn particle system",0,120,5)
    print(stat(1),105,120,3)
end

function deleteallps()
    for ps in all(particle_systems) do
        del(particle_systems, ps)
    end
end

-- demos -------------------------------------------------------
function sparks_demo()
    make_sparks_ps(rnd(107)+10,rnd(107)+10)
end

function explo_demo()
    make_explosion_ps(rnd(107)+10,rnd(107)+10)
end

function richexplo_demo()
    local rx = rnd(107)+10
    local ry = rnd(107)+10
    make_explosmoke_ps(rx,ry)
    make_explosparks_ps(rx,ry)
    make_explosion_ps(rx,ry)
end

function blood_demo()
    make_blood_ps(rnd(64),rnd(90)+10)
end

function smoke_demo()
    make_smoke_ps(rnd(107)+10,rnd(90)+10)
end

function waterfall_demo()
    make_waterfall_ps(rnd(107)+10,rnd(50)+10)
end

function starfield_demo()
    make_starfield_ps()
end

function warp_demo()
    make_3dwarp_ps()
end

function magicsparks_demo()
    make_magicsparks_ps(rnd(107)+10,rnd(107)+10)
end

function butterflies_demo()
    make_butterflies_ps(rnd(107)+10,rnd(54)+64)
end

function bubbles_demo()
    make_bubbles_ps()
end

demos = {
    {name = "sparks", desc = "", createfunc = sparks_demo },
    {name = "explosion", desc = "", createfunc = explo_demo },
    {name = "rich explosion", createfunc = richexplo_demo, desc = "multiple particle systems" },
    {name = "blood", createfunc = blood_demo, desc = "stopzone affector" },
    {name = "smoke", createfunc = smoke_demo, desc = "continuos particle system" },
    {name = "waterfall", createfunc = waterfall_demo, desc = "streak draw bouncezone affector" },
    {name = "starfield", createfunc = starfield_demo, desc = "" },
    {name = "3d warp", createfunc = warp_demo, desc = "attract affector" },
    {name = "magic sparks", createfunc = magicsparks_demo, desc = "rndspr" },
    {name = "bubbles", createfunc = bubbles_demo, desc = "agespr, orbit affector" },
    {name = "butterflies", createfunc = butterflies_demo, desc = "animspr, forcezone affector" },
}
currdemo = 1

-- sample particle system constructors -------------------------
function make_bubbles_ps()
    local ps = make_psystem(0.5,3.0, 1,9,0.5,0.5)

    ps.autoremove = false
    add(ps.emittimers,
        {
            timerfunc = emittimer_constant,
            params = {nextemittime = time(), speed = 0.2}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_box,
            params = { minx = 0, maxx = 127, miny = 100, maxy= 110, minstartvx = 0, maxstartvx = 0, minstartvy = -1.50, maxstartvy=-0.2 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_agespr,
            params = { frames = {16,16,17,17,17,18,18,18,18,18,18,18,18,18,18,19} }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_orbit,
            params = { phase = 0, speed = 0.005, xstrength = 0.5, ystrength = 0 }
        }
    )
end

function make_magicsparks_ps(ex,ey)
    local ps = make_psystem(0.3,1.7, 1,5,1,5)

    add(ps.emittimers,
        {
            timerfunc = emittimer_burst,
            params = { num = 10}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_box,
            params = { minx = ex-8, maxx = ex+8, miny = ey-8, maxy= ey+8, minstartvx = -1.5, maxstartvx = 1.5, minstartvy = -3, maxstartvy=-2 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_rndspr,
            params = { frames = {32,33,34,35,36}, colors = {8,9,11,12,14} }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_force,
            params = { fx = 0, fy = 0.3 }
        }
    )

end

function make_butterflies_ps(ex,ey)
    local ps = make_psystem(2,3, 1,9,1,5)

    add(ps.emittimers,
        {
            timerfunc = emittimer_burst,
            params = { num = 10}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_box,
            params = { minx = ex-16, maxx = ex+16, miny = ey-8, maxy= ey+8, minstartvx = 0, maxstartvx = 0, minstartvy = -2, maxstartvy= -1 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_animspr,
            params = { frames = {22,23,24,23}, speed = 0.5, colors = {8,9,11,12,14}, currframe = 1 }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_forcezone,
            params = { fx = -0.2, fy = 0.0, zoneminx = 64, zonemaxx = 127, zoneminy = 64, zonemaxy = 100 }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_forcezone,
            params = { fx = 0.2, fy = 0.0, zoneminx = 0, zonemaxx = 64, zoneminy = 30, zonemaxy = 70 }
        }
    )
end

function make_3dwarp_ps()
    local ps = make_psystem(1,2, 1,2,0.5,0.5)
    ps.autoremove = false
    add(ps.emittimers,
        {
            timerfunc = emittimer_constant,
            params = {nextemittime = time(), speed = 0.001}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_box,
            params = { minx = 62, maxx = 66, miny = 62, maxy= 66, minstartvx = 0, maxstartvx = 0, minstartvy = 0, maxstartvy=0 }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_attract,
            params = { x = 64, y = 64, mradius = 64, strength = 0.01 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_streak,
            params = { colors = {1,1,1,1,1,13,13,13,13,13,6,7,13,6,6,6,7,6,6,7,6,7,7} }
        }
    )
end

function make_starfield_ps()
    local ps = make_psystem(4,6, 1,2,0.5,0.5)
    ps.autoremove = false
    add(ps.emittimers,
        {
            timerfunc = emittimer_constant,
            params = {nextemittime = time(), speed = 0.01}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_box,
            params = { minx = 125, maxx = 127, miny = 0, maxy= 127, minstartvx = -2.0, maxstartvx = -0.5, minstartvy = 0, maxstartvy=0 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_pixel,
            params = { colors = {7,6,7,6,7,6,6,7,6,7,7,6,6,7} }
        }
    )
end

function make_waterfall_ps(ex,ey)
    local ps = make_psystem(1.5,2, 1,2,0.5,0.5)
    ps.autoremove = false
    add(ps.emittimers,
        {
            timerfunc = emittimer_constant,
            params = {nextemittime = time(), speed = 0.01}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_box,
            params = { minx = ex-8, maxx = ex+8, miny = ey, maxy= ey+1, minstartvx = -0.5, maxstartvx = 0.5, minstartvy = 0, maxstartvy=0 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_streak,
            params = { colors = {7,12,1,12,12,1,12,1,1,7,7,7} }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_force,
            params = { fx = 0, fy = 0.3 }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_bouncezone,
            params = { damping = 0.2, zoneminx = 0, zonemaxx = 127, zoneminy = 100, zonemaxy = 127 }
        }
    )
end

function make_blood_ps(ex,ey)
    local ps = make_psystem(2,3, 1,2,0.5,0.5)

    add(ps.emittimers,
        {
            timerfunc = emittimer_burst,
            params = { num = 30}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_point,
            params = { x = ex, y = ey, minstartvx = 1, maxstartvx = 3, minstartvy = -3, maxstartvy=-2 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_pixel,
            params = { colors = {8} }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_force,
            params = { fx = 0, fy = 0.3 }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_stopzone,
            params = { zoneminx = 0, zonemaxx = 127, zoneminy = 100, zonemaxy = 127 }
        }
    )
end

function make_sparks_ps(ex,ey)
    local ps = make_psystem(0.3,0.7, 1,2,0.5,0.5)

    add(ps.emittimers,
        {
            timerfunc = emittimer_burst,
            params = { num = 10}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_point,
            params = { x = ex, y = ey, minstartvx = -1.5, maxstartvx = 1.5, minstartvy = -3, maxstartvy=-2 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_fillcirc,
            params = { colors = {7,10,15,9,4,5} }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_force,
            params = { fx = 0, fy = 0.3 }
        }
    )
end

function make_explosparks_ps(ex,ey)
    local ps = make_psystem(0.3,0.7, 1,2,0.5,0.5)

    add(ps.emittimers,
        {
            timerfunc = emittimer_burst,
            params = { num = 10}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_point,
            params = { x = ex, y = ey, minstartvx = -1.5, maxstartvx = 1.5, minstartvy = -1.5, maxstartvy=1.5 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_pixel,
            params = { colors = {15,6,13,4,2,1} }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_force,
            params = { fx = 0, fy = 0.2 }
        }
    )
end

function make_explosion_ps(ex,ey)
    local ps = make_psystem(0.1,0.5, 9,14,1,3)

    add(ps.emittimers,
        {
            timerfunc = emittimer_burst,
            params = { num = 4 }
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_box,
            params = { minx = ex-4, maxx = ex+4, miny = ey-4, maxy= ey+4, minstartvx = 0, maxstartvx = 0, minstartvy = 0, maxstartvy=0 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_fillcirc,
            params = { colors = {7,0,10,9,9,4} }
        }
    )
end

function make_smoke_ps(ex,ey)
    local ps = make_psystem(0.2,2.0, 1,2,3,5)

    ps.autoremove = false

    add(ps.emittimers,
        {
            timerfunc = emittimer_constant,
            params = {nextemittime = time(), speed = 0.2}
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_box,
            params = { minx = ex-4, maxx = ex+4, miny = ey, maxy= ey+2, minstartvx = 0, maxstartvx = 0, minstartvy = 0, maxstartvy=0 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_fillcirc,
            params = { colors = {13,5,1} }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_force,
            params = { fx = 0.003, fy = -0.01 }
        }
    )
end

function make_explosmoke_ps(ex,ey)
    local ps = make_psystem(1.5,2.0, 5,8,17,18)

    add(ps.emittimers,
        {
            timerfunc = emittimer_burst,
            params = { num = 1 }
        }
    )
    add(ps.emitters,
        {
            emitfunc = emitter_point,
            params = { x = ex, y = ey, minstartvx = 0, maxstartvx = 0, minstartvy = 0, maxstartvy=0 }
        }
    )
    add(ps.drawfuncs,
        {
            drawfunc = draw_ps_fillcirc,
            params = { colors = {1} }
        }
    )
    add(ps.affectors,
        {
            affectfunc = affect_force,
            params = { fx = 0.003, fy = -0.01 }
        }
    )
end

-- particle system library -----------------------------------
particle_systems = {}

function make_psystem(minlife, maxlife, minstartsize, maxstartsize, minendsize, maxendsize)
    local ps = {}
    -- global particle system params
    ps.autoremove = true

    ps.minlife = minlife
    ps.maxlife = maxlife

    ps.minstartsize = minstartsize
    ps.maxstartsize = maxstartsize
    ps.minendsize = minendsize
    ps.maxendsize = maxendsize

    -- container for the particles
    ps.particles = {}

    -- emittimers dictate when a particle should start
    -- they called every frame, and call emit_particle when they see fit
    -- they should return false if no longer need to be updated
    ps.emittimers = {}

    -- emitters must initialize p.x, p.y, p.vx, p.vy
    ps.emitters = {}

    -- every ps needs a drawfunc
    ps.drawfuncs = {}

    -- affectors affect the movement of the particles
    ps.affectors = {}

    add(particle_systems, ps)

    return ps
end

function update_psystems()
    local timenow = time()
    for ps in all(particle_systems) do
        update_ps(ps, timenow)
    end
end

function update_ps(ps, timenow)
    for et in all(ps.emittimers) do
        local keep = et.timerfunc(ps, et.params)
        if (keep==false) then
            del(ps.emittimers, et)
        end
    end

    for p in all(ps.particles) do
        p.phase = (timenow-p.starttime)/(p.deathtime-p.starttime)

        for a in all(ps.affectors) do
            a.affectfunc(p, a.params)
        end

        p.x += p.vx
        p.y += p.vy

        local dead = false
        if (p.x<0 or p.x>127 or p.y<0 or p.y>127) then
            dead = true
        end

        if (timenow>=p.deathtime) then
            dead = true
        end

        if (dead==true) then
            del(ps.particles, p)
        end
    end

    if (ps.autoremove==true and count(ps.particles)<=0) then
        del(particle_systems, ps)
    end
end

function draw_ps(ps, params)
    for df in all(ps.drawfuncs) do
        df.drawfunc(ps, df.params)
    end
end

function emittimer_burst(ps, params)
    for i=1,params.num do
        emit_particle(ps)
    end
    return false
end

function emittimer_constant(ps, params)
    if (params.nextemittime<=time()) then
        emit_particle(ps)
        params.nextemittime += params.speed
    end
    return true
end

function emit_particle(psystem)
    local p = {}

    local e = psystem.emitters[flr(rnd(count(psystem.emiters)))+1]
    e.emitfunc(p, e.params)

    p.phase = 0
    p.starttime = time()
    p.deathtime = time()+rnd(psystem.maxlife-psystem.minlife)+psystem.minlife

    p.startsize = rnd(psystem.maxstartsize-psystem.minstartsize)+psystem.minstartsize
    p.endsize = rnd(psystem.maxendsize-psystem.minendsize)+psystem.minendsize

    add(psystem.particles, p)
end

function emitter_point(p, params)
    p.x = params.x
    p.y = params.y

    p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
    p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function emitter_box(p, params)
    p.x = rnd(params.maxx-params.minx)+params.minx
    p.y = rnd(params.maxy-params.miny)+params.miny

    p.vx = rnd(params.maxstartvx-params.minstartvx)+params.minstartvx
    p.vy = rnd(params.maxstartvy-params.minstartvy)+params.minstartvy
end

function affect_force(p, params)
    p.vx += params.fx
    p.vy += params.fy
end

function affect_forcezone(p, params)
    if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
        p.vx += params.fx
        p.vy += params.fy
    end
end

function affect_stopzone(p, params)
    if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
        p.vx = 0
        p.vy = 0
    end
end

function affect_bouncezone(p, params)
    if (p.x>=params.zoneminx and p.x<=params.zonemaxx and p.y>=params.zoneminy and p.y<=params.zonemaxy) then
        p.vx = -p.vx*params.damping
        p.vy = -p.vy*params.damping
    end
end

function affect_attract(p, params)
    if (abs(p.x-params.x)+abs(p.y-params.y)<params.mradius) then
        p.vx += (p.x-params.x)*params.strength
        p.vy += (p.y-params.y)*params.strength
    end
end

function affect_orbit(p, params)
    params.phase += params.speed
    p.x += sin(params.phase)*params.xstrength
    p.y += cos(params.phase)*params.ystrength
end

function draw_ps_fillcirc(ps, params)
    for p in all(ps.particles) do
        c = flr(p.phase*count(params.colors))+1
        r = (1-p.phase)*p.startsize+p.phase*p.endsize
        circfill(p.x,p.y,r,params.colors[c])
    end
end

function draw_ps_pixel(ps, params)
    for p in all(ps.particles) do
        c = flr(p.phase*count(params.colors))+1
        pset(p.x,p.y,params.colors[c])
    end
end

function draw_ps_streak(ps, params)
    for p in all(ps.particles) do
        c = flr(p.phase*count(params.colors))+1
        line(p.x,p.y,p.x-p.vx,p.y-p.vy,params.colors[c])
    end
end

function draw_ps_animspr(ps, params)
    params.currframe += params.speed
    if (params.currframe>count(params.frames)) then
        params.currframe = 1
    end
    for p in all(ps.particles) do
        pal(7,params.colors[flr(p.endsize)])
        spr(params.frames[flr(params.currframe+p.startsize)%count(params.frames)],p.x,p.y)
    end
    pal()
end

function draw_ps_agespr(ps, params)
    for p in all(ps.particles) do
        local f = flr(p.phase*count(params.frames))+1
        spr(params.frames[f],p.x,p.y)
    end
end

function draw_ps_rndspr(ps, params)
    for p in all(ps.particles) do
        pal(7,params.colors[flr(p.endsize)])
        spr(params.frames[flr(p.startsize)],p.x,p.y)
    end
    pal()
end

