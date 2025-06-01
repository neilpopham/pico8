--dusk child
--by sophie houlden

px=24--360--player x
py=64--150--player y
fx=0--force x
fy=0--force y
pg=0--player grounded
pf=false--flip player sprite
cring=false--crouching
dead=false
gametitle = true
fadeout=-1
super=false

cpu=0

--game progression
wopen=false
wlit=false
eopen=false
elit=false

cx=900--checkpoint x
cy=0--checkpoint y
checkwopen=false
checkwlit=false
checkeopen=false
checkelit=false
checkinv=0
--no checkpoint info for super
--put unavoidable checkpoints
--around that!!!

gameover=false

cansuper=false
cutscene=false


woff=0--world offset
yoff=0

killer=false--what killed the player
kx=0--where to draw deach circle
ky=0

spheremsg=1

texts={"","","","","","","","","",""}
texttimes={0,0,0,0,0,0,0,0,0,0}
textscroll=7

--update game object stuff
function goupdate()
for i=1,count(actors) do
 actor=actors[i]
 
 --save tokens!
 actype=actor.t
 acx=actor.x
 acy=actor.y
 aca=actor.a
 acb=actor.b
 acc=actor.c
 acwoff=actor.woff
 acyoff=actor.yoff
 
 --carried objects
  --orb and keystones
  if actype==3 or actype==9 then
   if aca==1 then
    acx=px
    acy=py
    acwoff=woff
    acyoff=yoff
   end
  end
 
  --bucket
  if actype==4 then
   lastc=acc
   if acc>0 and aca==1 then
    acc-=0.4
    dropcol=7
    if(rnd()>0.4)dropcol=12
    addpart(2,px+rnd()*2,py-7+rnd()*2,dropcol)
   end
   acb=2
   if(acc<60) acb=3
   if(acc<30) acb=4
   if(acc<=0) acb=5
   
   if aca==1 then
    --being carried
    acx=px-4
    acy=py-8
    acwoff=woff
    acyoff=yoff
    --if acc<60 and lastc>=60 then
     --addtext("water leaks from the bucket")
    --end
    --if acc<=0 and lastc>0 then
     --addtext("the bucket is empty")
    --end
   end
   
   buckettile=msget(acx+4,acy+4)
   if buckettile==20 then
    acc+=5
    if acc>50 then
     acc=100
     --if(aca==1 and lastc<97)addtext("the bucket is full")
    end
   end
   
   if buckettile==19 or (super and aca==1) then
    acc=0
    if(aca==1 and lastc>0)addtext("the water evaporates")
   end
   
  end
 
 if acwoff==woff and
    acyoff==yoff then
 
  --fire
  if actype==1 then
   lit=true
   if (actor.wlit and not wlit) lit=false
   if (actor.elit and not elit) lit=false
   if lit then
    sparkcount=5
    if(cpu>0.7)sparkcount=3
    if(cpu>0.8)sparkcount=2
    if(cpu>0.9)sparkcount=0
    for k=0,sparkcount do
     sparkcol=7
     if (rnd()>0.5) sparkcol=9
     if (rnd()>0.5) sparkcol=10
     addpart(1,acx+2+(rnd()*4),acy+8,sparkcol,acb)
    end
   end
  end
  
  --eyedol
  if actype==2 then
  
   lastc=acc
   acc=0
   for k=1,count(actors) do
    actorb=actors[k]
    if actorb.t==3 then
    if (actorb.woff==acwoff and
       actorb.yoff==acyoff) or
       k==inv then
     if(lastc==0) addtext("the orb pacifies eyedols")
     acc=1--doopy
    
    end
    end 
   end
  
  
   ppy=py-12
   if(cring)ppy=py-4
   dist=getdist(px,ppy,acx+4,acy+4)
   lasta=aca
   aca=0
   if(dist<60) aca=1
   if(dist<40) aca=2
   
   if acc==1 then
     --pacified
     aca=0
     dist=500
   end
   
   if lasta<1 and dist<60 then
    sfx(8)
   end
   if lasta<2 and dist<40 then
    sfx(7)
    addtext("the eyedol glares at you")
   end
   if dist<40 then
    acb+=0.5
    if(flr(acb)>count(eyeflash)) acb=1
   end
   if dist<30 then
    sfx(9)
    dienow(actor)
    
    midx=(px-acx)*0.5
    kx=px-midx
    midy=(py-(acy+16))*0.5
    ky=py-midy
    
    addtext("dont anger eyedols")
   end
   
  end
  
  --sprinkler
  if actype==5 then
   dropcount=4
   if(cpu>0.7)dropcount=3
   if(cpu>0.8)dropcount=2
   if(cpu>0.9)dropcount=1
   
   if (acb==1 and not wopen) dropcount=0
   if (acb==2 and not eopen) dropcount=0
   
   for k=1,dropcount do
    dropcol=7
    if (rnd()>0.5) dropcol=13
    if (rnd()>0.5) dropcol=12
    addpart(2,acx+2+(rnd()*4),acy,dropcol)
   end
  end
  
  --pullyshelf
  if actype==7 then
  
   shelfweighted=false
   for k=1,count(actors) do
    actorb=actors[k]
    if (actorb.t==3 or
       actorb.t==9 or
       (actorb.t==4 and
       actorb.c>0)) and
       actorb.a==0 and
       actoraabb(actor,actorb) then
     shelfweighted=true
    end
   end
  
   if shelfweighted then
    aca=0
   else
    aca=8
   end
  end
  
  --pullydoor
  if actype==6 then
   
   dooropen=false
   
   if acb==0 then
   for k=1,count(actors)do
    actorb=actors[k]
    if actorb.t==7 and
       actorb.a==0 and
       actorb.woff==acwoff and
       actorb.yoff==acyoff then
     dooropen=true 
    end
    if actorb.t==10 and
       actorb.a==1 and
       actorb.woff==acwoff and
       actorb.yoff==acyoff then
     dooropen=true
    end
   end
   end
   
   if (acb==1 and wopen) dooropen=true
   if (acb==2 and eopen) dooropen=true
  
   if dooropen then
    if(aca==0)sfx(10)
    aca+=1
    if(aca>16)aca=16
   else
    if(aca==16)sfx(11)
    aca-=1
    if(aca<0)aca=0
   end
   
   
   if aca==16 then
    mset(flr8(acx),flr8(acy),0)
    mset(flr8(acx),flr8(acy)-1,0)
   else
    mset(flr8(acx),flr8(acy),97)
    mset(flr8(acx),flr8(acy)-1,97)
   end
  end
  
  --statue
  if actype==8 then
   lightnow = false
   if super then
    x=acx
    if(aca==0)x+=24
    if pbox(px,py,x,acy-32,8,8) and
       acb==0 then
     lightnow = true
     addtext("you light the statue fire")
    end
   end
   if (aca==0 and wlit) lightnow=true
   if (aca==1 and elit) lightnow=true
   
   x=0
   if(aca==0)x+=3
   if not actor.unlightable then
    mset(flr8(acx)+x,flr8(acy)-4,0)
   end
   
   if lightnow and not actor.unlightable then
    if aca==0 then
     wlit=true
    else
     elit=true
    end
    acb=1
   end
   
   
   if acb==1 then
    for k=0,5 do
     sparkcol=7
     if (rnd()>0.5) sparkcol=9
     if (rnd()>0.5) sparkcol=10
     spx=acx+2
     if(aca==0)spx+=24
     addpart(1,spx+(rnd()*4),acy-24,sparkcol,0)
    end
    mset(flr8(acx)+x,flr8(acy)-4,19)
   end
   
  end
  
  --keystone locks
  if actype==10 and aca==0 then
   for k=1,count(actors) do
    actorb=actors[k]
    if actorb.t==9 and
       actorb.a==0 and
       actorb.x>=acx-4 and
       actorb.x<acx+12 and
       actorb.y>=acy and
       actorb.y<acy+16 then
     addtext("the keystone slots in")
     actorb.x=9999
     aca=1
     if actor.east then
      eopen=true
     else
      wopen=true
     end
    end
   end
  end
 
 end
 
 if respawning then
  acx=actor.ch_x
  acy=actor.ch_y
  aca=actor.ch_a
  acb=actor.ch_b
  acc=actor.ch_c
  acwoff=actor.ch_woff
  acyoff=actor.ch_yoff
  
  --addtext(i)
  
 end
 
 actor.t=actype
 actor.x=acx
 actor.y=acy
 actor.a=aca
 actor.b=acb
 actor.c=acc
 actor.woff=acwoff
 actor.yoff=acyoff
 
 if checkpointing then
  actor.ch_x=acx
  actor.ch_y=acy
  actor.ch_a=aca
  actor.ch_b=acb
  actor.ch_c=acc
  actor.ch_woff=acwoff
  actor.ch_yoff=acyoff
  
  --addtext("ch")
  
  
 end
 
end
--keep these outside the loop!
respawning=false
checkpointing=false
end

function flr8(v)
 return flr(v/8)
end

 

function bucketpal(p)
 --if p==2 then
 -- pal(11,12) pal(4,12)
 --else
 -- pal(4,5) pal(11,13)
 --end
 --if p<=3 then
 -- pal(2,12) pal(14,12)
 --else
 -- pal(2,5) pal(14,13)
 --end
 --if p<=4 then
 -- pal(8,12) pal(3,12) pal(9,12)
 --else
 -- pal(8,1) pal(3,5) pal(9,13)
 --end
end

eyeflash={11,10,10,26,27,26,10,10}
function godraw()
for i=1,count(actors) do
 actor=actors[i]
 actype=actor.t
 acx=actor.x
 acy=actor.y
 aca=actor.a
 
 if actor.woff==woff and
    actor.yoff==yoff then
    
  --draw statues
  if actype==8 and
     actor.woff==woff and
     actor.yoff==yoff then
   flippit = false
   lit=false
   if(aca==1)flippit=true
   if(actor.b==1)lit=true
   drawstatue(acx,acy,flippit,lit)
  end
 
  --final door
  if actype==12 then
   
   y=acy
   x=acx
   
   clip(wrap(x,128),wrap(y,112),31,32)
   rectfill(x,y,x+31,y+31,7)
   if wlit and elit then
    if px>x+12 and px<x+20 then
     actor.a+=0.1
     if not cutscene then
      addtext("the door begins to open")
     end
     cutscene=true
     py+=(actor.y+32-py)*0.2
    end
    x-=1
    x+=rnd()*2
    for i=1,3 do
     addpart(1,x+rnd()*32,y+32-min(actor.a,32),-1,0,3-cpu)--+rnd()*2)
    end
    if actor.a>=38 then--38
     gameover=true
     fadeout=16
    end
   end
   y-=actor.a
   spr(71,x,y)
   spr(71,x+8,y,2,1)
   spr(71,x,y+8,1,2)
   spr(71,x+8,y+8,2,2)
   spr(87,x,y+24)
   spr(87,x+8,y+24,2,1)
   spr(72,x+24,y)
   spr(72,x+24,y+8,1,2)
   spr(88,x+24,y+24)
   clip()
   
  end
 
  --eyedol
  if actype==2 then
   eyespr=11
   if(aca==1)eyespr=10
   if aca==2 then
    eyespr=eyeflash[flr(actor.b)]
   end
   spr(eyespr,acx-4,acy-4)
  end
  
  --pullydoor
  if actype==6 then
    spr(102,acx,acy-aca)
    spr(102,acx,(acy-8)-aca)
    --if (actor.b==1) spr(3,acx,acy-aca)
  end
  
  --pullyshelf
  if actype==7 then
    spr(57,acx,acy-aca)
    if(aca==0)spr(41,acx,(acy-8))
  end
  
  --keystone lock
  if actype==10 and aca==1 then
   spr(9,acx+4,acy)
  end
  
  --bucket
  if actype==4 and aca==0 then
    --bucketpal(actor.b)
    spr(actor.b,acx,acy)
    --spr(2,acx,acy)
    pal()
  end
  
  --orb
  if actype==3 and aca==0 then
    spr(actor.b,acx,acy)
  end
  
  
  --keystone
  if actype==9 and aca==0 then
    spr(9,acx,acy)
  end
  
  --ancient tablet
  if actype==11 then
   if not cansuper then
    if aca==0 then
     if px>acx-4 and
        px<acx+4 then
      actor.a=1
      cutscene=true
      addtext("you look up at the tablet")
     end
    end
    
    if actor.a>0 then
     px+=(acx+2-px)*0.2
     py+=(acy+64-py)*0.2
     actor.b+=1
     if actor.b>60 then
      actor.a+=1
      range=actor.a*4
      range+=5
      if actor.a==3 then
       addtext("and are unable to look away")
       addpart(3,acx,acy,range,0,2,5)
       addpart(3,acx,acy,range,1.5,2,4)
      end
      if actor.a==5 then
       addtext("however, you are not afraid")
       addpart(3,acx,acy,range,0,2,4)
       addpart(3,acx,acy,range,1.5,2,3)
      end
      if actor.a==7 then
       addtext("the writing almost seems...")
       addpart(3,acx,acy,range,0,2,2)
       addpart(3,acx,acy,range,1.5,2,2)
      end
      if(actor.a==9)addtext("...familiar")
      
      if actor.a==12 then
       addtext("you feel different")
       addtext("awakened")
       cutscene=false
       cansuper=true
      end
      
      actor.b=0
     end
    end
   
   end
   
   for i=1,count(parts) do
   
    p=parts[i]
    if p and p.t==3 then
    if cutscene then
    
     if actor.a+p.d>12 then
      p.fx=px
      p.fy=py-7
      p.b=min(p.b+0.002,0.2)
      p.x+=(p.fx-p.x)*p.b
      p.y+=(p.fy-p.y)*p.b
     else
      p.fy+=0.002*actor.a
      rotness=(p.fy)
      p.x=acx+sin(rotness)*p.fx
      p.y=acy+cos(rotness)*p.fx
     end
     
    else
     del(parts,p)
    end
    end
   end
   
   if actor.a>10 then
    actor.c=max(0,actor.c-0.01)
   end
  
   if actor.c>0 then
    fadecirc(acx,acy,(8+(sin(time*0.8)*7))*actor.c,whitefade,1)
    fadecirc(acx,acy,(7+(cos(time*0.8)*6))*actor.c,blackfade,1)
    fadecirc(acx,acy,(6+(sin((time+2)*0.8)*5))*actor.c,whitefade,1)
   end
   
  end
  
  
  
 end
end
end


function getdist(ax,ay,bx,by)
 a=ax-bx
 b=ay-by
 a*=0.01
 b*=0.01
 a=a*a+b*b
 if (a==0) return 0--avoid crash
 a=sqrt(a)*100
 --clamp huge numbers
 if(a<0) return 32767
 
 return a--done!
end

function wipesprite(x,y)
 for pixx=0,7 do
 for pixy=0,7 do
  sset(pixx+x,pixy+y,0)
 end
 end
end

function _init()

 --music(0)

 --hide helper gfx
 wipesprite(24,8)
 wipesprite(32,8)
 wipesprite(8,48)

 --should instantiate gameobjects here
 for x=0,160 do
 for y=0,55 do
  tilenum=mget(x,y)
 
  if tilenum==50 then
   --add fire
   addactor(1,x,y,19)
  end
  if tilenum==52 then
   --add downwards fire
   addactor(-1,x,y,19)
  end
  if tilenum==103 then
   --add wlit fire
   addactor(100,x,y,0)
  end
  if tilenum==104 then
   --add elit fire
   addactor(-100,x,y,0)
  end
  
  if tilenum==10 then
   --add eyedol
   addactor(2,x,y,-1)
  end
  
  if tilenum==1 then
   --add orb
   addactor(3,x,y,0)
  end
  
  if tilenum==2 then
   --add bucket
   addactor(4,x,y,0)
   --mset(x,y,0)
  end
  
  if tilenum==3 then
   --add keystone
   addactor(9,x,y,0)
  end
  
  if tilenum==51 then
   --add sprinkler
   addactor(5,x,y,20)
  end
  if tilenum==121 then
   --add west sprinkler
   addactor(-5,x,y,20)
  end
  if tilenum==122 then
   --add east sprinkler
   addactor(-50,x,y,20)
  end
  
  if tilenum==102 then
   --add pullydoor
   addactor(6,x,y,0)
  end
  if tilenum==125 then
   --add west pullydoor
   addactor(-6,x,y,0)
  end
  if tilenum==126 then
   --add east pullydoor
   addactor(-66,x,y,0)
  end
  
  if tilenum==57 then
   --add pullyshelf
   addactor(7,x,y,0)
   mset(x,y-1,0)
  end
  
  if tilenum==96 then
   --add west keystonelock
   addactor(10,x,y,48)
  end
  
  if tilenum==26 then
   --add east keystonelock
   addactor(-10,x,y,48)
  end
  
  if tilenum==92 then
   --add statue
   mset(x,y,0)
   addactor(8,x,y,97)
  end
  if tilenum==91 then
   --add flipped statue
   mset(x,y,0)
   addactor(-8,x,y,97)
  end
  if tilenum==95 then
   --add statue(unlightable)
   mset(x,y,0)
   addactor(18,x,y,97)
  end
  if tilenum==94 then
   --add flipped statue(unlightable)
   mset(x,y,0)
   addactor(-18,x,y,97)
  end
  
  if tilenum==113 then
   --add ancient tablet
   addactor(11,x,y,56)
  end
  
  if tilenum==112 then
   --final door
   addactor(12,x,y,0)
  end
  
 end
 end
end

actors={}
function addactor(t,x,y,replacetile)
 a={}
 a.t=t
 a.x=x*8
 a.y=y*8
 --flags
 a.a=0
 a.b=0
 a.c=0
 
 --offset
 a.woff=flr((x*8)/128)
 a.yoff=flr((y*8)/112)
 
 --east/west pullydoors
 if t==-6 then
  a.b=1
  a.t=6
 end
 if t==-66 then
  a.b=2
  a.t=6
 end
 
 --sprinklers
 if t==-5 or t==-50 then
  a.t=5
  if(t==-5)a.b=1
  if(t==-50)a.b=2
 end
 
 --remote statue fires
 if t==100 or t==-100 then
  a.t=1
  if(t==100)a.wlit=true
  if(t==-100)a.elit=true
 end
 
 --downwardsfire
 if t==-1 then
  a.b=1
  a.t=1
 end
 
 --eyedol
 if t==2 then
  a.x+=4
  a.y+=4
  a.b=1
 end
 
 --east keystone lock
 if t==-10 then
  a.t=10
  a.east=true
 end
 
 --orb
 if t==3 then
  a.b=1--inv sprite
 end
 
 --bucket
 if t==4 then
  a.b=2
 end
 
 --keystone
 if t==9 then
  a.b=9--inv sprite
 end
 
 --pullyshelf
 if t==7 then
  a.a=8
 end
 
 --ancient tablet
 if t==11 then
  a.c=1
 end
 
 --statues
 if t==8 or t==-8 or t==18 or t==-18 then
  a.c=a.x
  if(t==-18 or t==18) a.unlightable=true
  if t==8 or t==18 then
   a.x-=24
   a.t=8
  else
   a.t=8
   a.a=1
  end
  a.y+=8*3
 end
 
 --checkpoint values
 a.ch_x=a.x
 a.ch_y=a.y
 a.ch_a=a.a
 a.ch_b=a.b
 a.ch_c=a.c
 a.ch_woff=a.woff
 a.ch_yoff=a.yoff
 
 add(actors,a)
 
 if (replacetile != -1) mset(x,y,replacetile)
end

--conditional mset
--only replaces blank tiles
function cmset(x,y,v)
 if(mget(x,y)==0)mset(x,y,v)
end

parts={}--particles
function addpart(t,x,y,a,b,c,d)
 p={}
 p.t=t
 p.x=x
 p.y=y
 p.a=a
 p.b=b
 p.c=c
 p.d=d
 p.life=10
 
 if t==1 then
  --spark
  p.fx=rnd()-0.5
  p.fy=(rnd()-1.5)*0.5
  if(b==1) then
   p.y-=8
   p.fy=(rnd()*1.5)*2.5
  end
  p.life=rnd()*15
 end
 if t==2 then
  --drop
  
  p.fx=(rnd()-0.5)*0.5
  p.fy=0
  p.life=50
  p.c=a
 end
 
 if t==3 then
  --glow
  p.fx=a
  p.fy=b
  p.a=c
  p.b=0
 end
 
 add(parts,p)
end

function doparticles()
clip(0,0,127,112)
for i=1,count(parts) do
part = parts[i]
if part then
  --sparks
 if part.t==1 then
  part.x+=part.fx
  part.y+=part.fy
  part.fy-=0.1
  part.fx*=0.9
  part.life-=1*(1+part.fx)
  if part.a>=0 then
   if(part.life<3)part.a=5
   pset(part.x,part.y,part.a)
  else
   fadecirc(part.x,part.y,part.c,whitefade,1)
  end
 end
 
 --drops
 if part.t==2 then
  lastx=part.x
  lasty=part.y
  part.x+=part.fx
  part.y+=part.fy
  
  if msget(part.x,part.y)>=64 then-- or
   --drop hit solid ground or player
   part.fy*=-0.3
   part.fx=(rnd()-0.5)*5*part.fy
   part.x=lastx
   part.y=lasty
   if msget(part.x,part.y+4)>=64 then
    while msget(part.x,part.y)<64 do-- and
     part.y+=1
    end
   else
    --probably a wall hit
    part.fx*=-0.8
   end
   part.y-=1
   part.life*=rnd()
  end
  
  part.fy+=0.1
  part.fx*=0.9
  part.life-=1
  
  line(lastx,lasty,part.x,part.y,part.a)
 end
 
 --glow
 if part.t==3 then
  fadecirc(part.x,part.y,part.c,whitefade,1)
  if cpu<0.8 then
   addpart(1,part.x,part.y,-1,0,2-cpu)--+rnd()*2)
  end
 end
 
 if part.life<0 then
  del(parts,part)
 end
  
end
end
clip()
end

inv=0--inventory

aniframe=1--current anim frame
anitime=0--timer for anim frames

idle={16}
walk={17,18}
duck={19}
crawl={19,20}
rise={21}
fall={22}

time=0

function _update()
 time+=0.033
 if(fadeout>=0)return
 
 if(gameover)return

 if gametitle then
  if btn(4) or btn(5) then
   --start game
   addtext(" ")
   addtext(" ")
   addtext("you finally arrive...")
   addtext("why were you drawn here?")

   --music(-1)
   sfx(1)
   fadeout=16
  end
  return
 end

 if(dead) respawnnow()
 
 goupdate()
 
 --input
 if (cutscene) return
 
 if(btn(0)) fx-=0.4 pf=true
 if(btn(1)) fx+=0.4 pf=false
 
 if collides(px,py+1)!=true then
  --not grounded
  pg=0
  fy+=0.2
  if(canstand())cring=false
 else
  --grounded
  if (pg!=1)sfx(5)
  pg=1
  
  if (canstand()) cring=false
  if (btn(3)) cring=true
  
  if btnp(2) and not cring then
   fy=-3.5--jump!
   sfx(4)
  end
 end
 
 --forces
 if fx>0 then
  fx=max(fx-0.2,0)
 else
  fx=min(fx+0.2,0)
 end
 fx=mid(-2,fx,2)
 fy=mid(-5,fy,2)
 if cring then
  fx=mid(-1,fx,1)
 end
 
 --move player
 moveplayer()
 
 
 ancl=true --action not claimed yet
 
 actionbtn=btnp(4)
 
 --pick up actors
 if actionbtn and pg==1 and ancl then
 for i=1,count(actors) do
  actor = actors[i]
 if pbox(px,py,actor.x,actor.y,8,16) then
  
  --orb
   if actor.t==3 and actor.a==0 and ancl then
    if (inv!=0) dropitem()
    addtext("you pick up the orb")
    inv=i
    actor.a=1
    ancl=false
   end
   
  --keystone
   if actor.t==9 and actor.a==0 and ancl then
    if (inv!=0) dropitem()
    addtext("you pick up the keystone")
    inv=i
    actor.a=1
    ancl=false
   end
   
  --bucket
   if actor.t==4 and actor.a==0 and ancl then
    if (inv!=0) dropitem()
    addtext("you pick up the bucket")
    if actor.c<=0 then
     addtext("it has a hole in the base")
    else
     addtext("water starts to leak from it")
    end
    inv=i
    actor.a=1
    ancl=false
   end
  
 end
 end
 
  --put down actors
 --inventory management
  if ancl and inv!=0 then
    dropitem()
  end
 end
 
 
 
 --map interactions
 ptile1=pmsget()
 ptile2=pmsget(9)
 if actionbtn and pg==1 and ancl then
  --signs
  if ptile1==62 then
   readsign(px,py)
   ancl=false
  end
  --spikes
  if ancl and
   (ptile1==30 or
      ptile1==31) then
    addtext("these look sharp...")
    ancl=false
  end
  --checkpoints
  if ancl and
     ptile2==47 then
   addtext("you see yourself reflected")
   ancl=false
  end
  --water
  if ancl and ptile1==20 then
    addtext("it's wet")
    ancl=false
  end
  --final door
  if ancl and ptile1==23 then
    addtext("a large stone door")
    ancl=false
  end
  --fire
  if ancl and ptile1==19 or
      ptile2==19 then
    addtext("the fire burns brightly")
    ancl=false
  end
  --bones
  if ancl and ptile1==15 then
    addtext("a pile of bones,")
    addtext("they look... human")
    ancl=false
  end
 end
 
 --static actors (switches etc)
 if actionbtn and pg==1 and ancl then
 for i=1,count(actors) do
  actor=actors[i]
 
  --examine statues
  if actor.t==8 and ancl then
   if pbox(px,py,actor.c,actor.y-32,8,8) then
    if actor.b==0 then
     addtext("a statue, it has some very")
     addtext("old burn marks on it's hands")
    end
    ancl=false
   end
  end
  
  --examine keystonelock
  if pbox(px,py,actor.x,actor.y,16,16) then
  if actor.t==10 and ancl then
   if actor.a==0 then
    addtext("a hole in the stone, looks")
    addtext("like something is missing")
   else
    addtext("the keystone is set")
    addtext("firmly in it's place.")
   end
   ancl=false
  end
  end
 
 if pbox(px,py,actor.x,actor.y,8,8) then

   --examine pullyshelf
   if actor.t==7 and ancl then
    addtext("a shelf attached to a pully")
    addtext("weighing it down may help?")
    ancl=false
   end
   
   
 
 end
 end
 end
 
 if actionbtn and ancl and pg==1 then
  addtext("there is nothing here")
 end
 
 --super power!
 if btnp(5) then
  if cansuper then
   super = not super
   if super then
    sfx(14)
   else
    sfx(13)
   end
  else
   addtext("?")
  end
 end
 
end

function  dropitem()
 invactor=actors[inv]
   invactor.x=px-4
   invactor.y=py-7
   invactor.a=0
   invactor.woff=woff
   invactor.yoff=yoff
   
   if (invactor.t==3) addtext("you put down the orb")
   if (invactor.t==9) addtext("you put down the keystone")
   if invactor.t==4 then
    addtext("you put down the bucket")
    if invactor.c>0 then
     addtext("sealing a hole in it's base")
    else
     --put down empty bucket
     for i=1,count(actors) do
     if actors[i].t==7 then
     if actoraabb(invactor,actors[i]) then
      addtext("it is too light when empty")
      invactor.y-=8
     end
     end
     end
    end
    
   end
   inv=0
   ancl=false
end

function readsign(x,y)
 addtext("it reads:")
 
 if yoff==0 then
  if woff==0 then
   addtext('"warning:')
   addtext('to step forward is to accept')
   addtext('that you may not return."')
  end
  if woff==5 then
   addtext('"keep your head down"')
   end
 end
 if yoff==2 then
  if woff==1 then
   addtext('"western temple')
   addtext('replace keystone to open"')
  end
  if woff==3 then
   addtext('"try jumping"')
  end
  if woff==4 then
   --addtext('"~ world door ~',55)
   addtext('we must leave,',55)
   addtext('but our exit stays.',55)
   addtext('...lost child, follow us!',55)
   addtext('your home must travel on,',55)
   addtext('but you may yet reach it"',55)
   
   --addtext('"we must leave this place',55)
   --addtext('but we do so with heavy',55)
   --addtext('hearts, for we also leave',55)
   --addtext('something most dear.',55)
   --addtext('so this door shall stay,',55)
   --addtext('that our lost child may',55)
   --addtext('follow us through it."',55)
  end
  if woff==6 then
   addtext('"eastern temple')
   addtext('replace keystone to open"')
  end
 end
 if yoff==3 then
  if woff==6 then
   addtext('"orbs pacify eyedols"')
  end
  if woff==7 then
   addtext('"vvvvvvery tricky, this one"')
   addtext("...?")
  end
 end
 
 --addtext(woff.."~"..yoff)
end


function moveplayer()
 fromx=px
 fromy=py
 
 px+=fx
 py+=fy
 
 --foot collision
 if collides(px,py) then
  if collides(fromx,py) then
   --collides even on old x
   --floor or ceiling collision
   px=fromx
   py=fromy
   fy=0
  else
   if collides(px,fromy) then
    --collides even on old y
    --wall collision
    fx *= -0.7
    px = fromx
   end
  end
  
  if collides(px,py) then
   --still collides, it was
   --a complete collision
   px=fromx
   py=fromy
   fx=0
   fy=0
  end
 end
 
 --checkpoint collision
 x=flr8(px)*8
 y=flr8(py)*8
 if (pmsget(8)==47) checkpointnow(x,y-8)
 if (pmsget()==47) checkpointnow(x,y)
 
 --spike collision
 if pmsget(7)==30 or
    pmsget(7)==31 then
  if fy>0 then
  
  spiketexts={"sharp and pointy, very hurty",
              "spikes? ouch.",
              "ouch!",
              "oh dear"}
  
  rndmsg()
  addtext(spiketexts[spheremsg])
 
   dienow()
  end
 end
 
 --fire collision
 if not dead and not super then
  if (not cring and pmsget(8)==19)
  or pmsget()==19 then
  
  if (inv!=0 and actors[inv].t==4 and actors[inv].c>0) addtext("the water evaporates...")
  
  firetexts={"fire: it's hot",
             "well... better to burn out?",
             "dont touch the flames!",
             "oooh, burn!"}
   
   rndmsg()
   addtext(firetexts[spheremsg])
 
   dienow()
  end
 end
 
 --water collision
 if not dead and super then
  if (not cring and pmsget(8)==20)
  or pmsget()==20 then
  
  watertexts={"made of fire? avoid water!",
              "your flame is not eternal",
              "extinguished",
              "fire vs water? water wins."}
   
   rndmsg()
   addtext(watertexts[spheremsg])
 
   dienow()
  end
 end
 
end

function rndmsg()
 spheremsg+=1+flr(rnd()*2)
 if(spheremsg>4)spheremsg=1
end

--set checkpoint
function checkpointnow(x,y)
 if cx!=x or cy!=y then
  sfx(6)
  
  checktexts={"the sphere glows warmly",
              "it glows upon your touch",
              "you feel protected",
              "the sphere will remember you"}
   
   rndmsg()
   addtext(checktexts[spheremsg])
 
 end
 
 
 checkpointing=true
 
 checkwopen=wopen
 checkwlit=wlit
 checkeopen=eopen
 checkelit=elit
 checkinv=inv
 
 cx=x
 cy=y
 
 addpart(1,x+rnd()*7,y+rnd()*7,-1,0,3-cpu)--+rnd()*2)
 
end

--death becomes her!
function dienow(k)
 killer=k
 
 fadeout=16
 sfx(0)
 fx=0
 fy=0
 kx=px
 ky=py
 dead=true
end

function respawnnow()
 px=cx+4
 py=cy+8
 --pg=0
 dead=false
 respawning=true
 
 wopen=checkwopen
 wlit=checkwlit
 eopen=checkeopen
 elit=checkelit
 inv=checkinv
end

--like mget, but you can
--enter screen/pixel xy
function msget(x,y)
 return mget(flr8(x),flr8(y))
end

--used msget so much just for player might as well
function pmsget(b)
 if (b)return msget(px,py-b)
 return msget(px,py)
end

--can we stand?
function canstand()
 if(collides(px,py-8))return false
 return true
end

--does xy overlap a map tile
function collides(x,y)
 if(x<1) return true--left edge of map
 if (mget(flr8(x),flr8(y))>=64) then
  return true
 else
  ycol=8
  if (cring) ycol=7
  if (mget(flr8(x),flr8(y-ycol))>=64) return true
  
  return false

 end
end

--order to fade pixels
whitefade={1,2,3,5,13,13,15,7,
            9,10,7,10,6,6,15,7,7}
blackfade={0,0,1,5,5,2,15,6,4,
            4,9,3,13,5,13,14}
function fadepix(col,lookup)
 return lookup[col+1]
end

--actor-actor collision
function actoraabb(a,b)
 if a.x+7>b.x and
    a.x<b.x+7 and
    a.y+7>b.y and
    a.y<b.y+7 then
  return true
 end
 return false  
end

--point-box collision
function pbox(x,y,bx,by,w,h)
 if bx>x or
     bx+w<x or
     by>y or
     by+h<y then
  return false
 end
 
 return true
end

--point-circle collision
function pcirc(x,y,rad,ax,ay)
 if(pbox(x,y,ax-rad,ay-rad,rad*2,rad*2)==false) return false
 distx=ax-x
 disty=ay-y
 distx*=distx
 disty*=disty
 if (distx+disty>rad*rad)return false
 return true
end

--adds message text to the first
--empty slot in the buffer
function addtext(text,delay)
 for i=1,count(texts) do
  if texts[i]=="" then
   texts[i]=text
   texttimes[i]=15
   if (delay) texttimes[i]=delay 
   return
  end
 end
end

--remove first text in buffer
--shuffles everything forward
function removetext()
 textscount=count(texts)
 for i=1,textscount-1 do
  texts[i]=texts[i+1]
  texttimes[i]=texttimes[i+1]
 end
 texts[textscount]=""
 texttimes[textscount]=0
end

--display game events as
--scrolling text on the bottom
function displayevents()
 if(gametitle)return
 
 rectfill(16,112,127,127,0)
 clip(16,112,127,35)
 
 if textscroll>0 then
  textscroll-=1
 else
  if(texttimes[1]>=0) texttimes[1]-=1
  if texttimes[1]<0 and texts[4]!="" then
   textscroll=7
   removetext()
  end
 end

 texty=121
 textcols={13,6,7}
 --textcol=7
 for i=3,1,-1 do
  print(texts[i],16,texty+textscroll,textcols[i])
  texty-=7
 end
 
 clip()
end



function drawstatue(x,y,f,l)
 if l then
  if rnd()>0.7 then
   pal(6,15)
   pal(15,10)
   pal(10,7)
  end
 else
  pal(6,6)
  pal(15,6)
  pal(10,6)
 end
 sx=16 sxx=24
 if(f)sx=0 sxx=0
 spr(89,x,y-24,4,3,f)
 spr(93,x+8,y-48,2,3,f)
 spr(103,x+sx,y-64,2,2,f)
 spr(95,x+sxx,y-48,1,1,f)
 pal()
end

function wrap(v,max)
 while v>max do v-=max end
 return v
end

function fadecirc(cx,cy,rad,lookup,strength)
 cx=flr(cx)
 cy=flr(cy)
 

 cxb=cx-rad
 cyb=cy-rad
 cyc=cyb
 yy=rad*2
 xx=rad*2
 fill=false
 clip(0,0,128,112)
 for x=cx-rad,cx do
 for y=cy-rad,cy do
  if fill or pcirc(x,y,rad,cx,cy) then
   fill=true
   
   pix=pget(cxb,cyb)
   for i=0,strength do
    pix=fadepix(pix,lookup)
   end
   pset(x,y,pix)
   
   if xx>0 then
   pix=pget(cxb+xx,cyb)
   for i=0,strength do
    pix=fadepix(pix,lookup)
   end
   pset(x+xx,y,pix)
   end
   
   if yy>0 then
   pix=pget(cxb,cyb+yy)
   for i=0,strength do
    pix=fadepix(pix,lookup)
   end
   pset(x,y+yy,pix)
   end
   
   if xx>0 and yy>0 then
   pix=pget(cxb+xx,cyb+yy)
   for i=0,strength do
    pix=fadepix(pix,lookup)
   end
   pset(x+xx,y+yy,pix)
   end
   
  end
  cyb+=1
  yy-=2
 end
 yy=rad*2
 fill=false
 cyb=cyc
 cxb+=1
 xx-=2
 end
 
 clip()
end

function _draw()

 --fadeout stuff
 camera()
 if fadeout>=0 then
  if(gametitle)rectfill(0,127,127,112,0)
  kx=wrap(kx,128)
  ky=wrap(ky,111)
  
  --draw whatever killed us
  if killer then
   --eyedol
   kkx=killer.x
   kky=killer.y
   ppx=px
   ppy=py-9
   if(cring)ppy=py-4
   kkx=wrap(kkx,128)
   kky=wrap(kky,111)
   ppx=wrap(ppx,128)
   ppy=wrap(ppy,111)
   spr(26,kkx-4,kky-4)
   line(kkx,kky,ppx,ppy,11)
   killer=false
  end
  
  fadeout-=1
  fadey=111
  fade=blackfade
  if gameover then
   fade=whitefade
   fadey=127
  end
  if(fadeout==0)gametitle=false
  for x=0,127 do
   for y=0,fadey do
   
    pix=pget(x,y)
    
    if fadeout<8 or gametitle or gameover then
     pix=fadepix(pix,fade)
    else
     if pcirc(x,y,20,kx,ky-10)==false then
      pix=fadepix(pix,fade)
     end
    end
    if(pix>=0) pset(x,y,pix)
   end
  end
  if (not gameover) displayevents()
  return
 end

 if gameover then
  
  print('"fear not child',35,54,0)
  print('your home awaits"',32,62,0)
  print("the end",49,100,6)
  
  return
 end

 cls()
 rectfill(0,0,127,111,1)
 
 
 woff=flr(px/128)--world offset
 yoff=flr(py/112)
 
 --draw stars using world offset as seed
 srand(73+(woff-3)*(yoff+58))
 for i=0,20 do
  if sin(time*rnd(1))>0 then
   pset(rnd(127),rnd(112),7)
  else
   pset(rnd(127),rnd(112),15)
  end
 end
 srand(time)
 
 if gametitle then
  --print("dusk child",68,19,7)
 -- print("by sophie houlden",54,38,6)
 
  print("by sophie houlden",54,37,13)
 	print("v1.4",112,106,2)
 
  if sin(time*2)>0 then
   print("press button",64,72,7)
  end
  
  woff=0 yoff=1
  map(0,14,0,0,16,14)
  drawstatue(8,72,false,true)
  camera(0,112)
  
  goupdate()
  doparticles()
  return
  
 else
  --draw stuff below game
  invspr=0
  if inv!=0 then
   invspr=actors[inv].b
   --if actors[inv].t==4 then
   -- invspr=2
   -- bucketpal(actors[inv].b)
   --end
  end
  
  spr(invspr,4,116)
  pal()
  line(3,114,12,114,6)
  line(2,115,2,124,6)
  line(3,125,12,125,6)
  line(13,115,13,124,6)
  
  displayevents()
 end
 
 
 camera(woff*128,yoff*112)
 
 --draw map
 map(woff*16,yoff*14,woff*128,yoff*112,16,14)
 
 
 
 
 --draw actors
  godraw()
  
 --draw checkpoint
 spr(46,cx,cy)
 
 --particles
 doparticles()
 
 --player animation
 curani={}--current animation
 if pg==0 then
  curani=fall
  if (fy<0) curani=rise
 else
  if btn(0) or btn(1) then
   curani=walk
   if (cring) curani=crawl
  else
   curani=idle
   if (cring) curani=duck
  end
 end
 
 if (cutscene) curani=idle
 
 lastframe=aniframe
 anitime+=0.5
 if (anitime>1) anitime=0 aniframe+=1
 if aniframe>count(curani) then
  aniframe=1
 end
 animsprite=curani[aniframe]
 
 --walk sfx
 if aniframe==1 and lastframe!=aniframe then
  if (curani==walk) sfx(2)
  if (curani==crawl) sfx(3)
 end
 
 
 
 
 --draw player
 if super then
  --flame pallete swap
  
  orange=9
  yellow=10
  if rnd()>0.4 then
   orange=9
   yellow=15
  end
  
  pal(1,yellow)
  pal(2,yellow)
  pal(3,orange)
  pal(4,7)
  pal(5,7)
  pal(6,orange)
  pal(7,yellow)
  pal(8,orange)
  pal(11,7)
  pal(13,7)
  pal(12,orange)
  pal(14,yellow)
  pal(15,yellow)
  pal(9,orange)
  
  
  
  for i=0,5 do
   sparkcol=7
   if (rnd()>0.5) sparkcol=9
   if (rnd()>0.5) sparkcol=10
    addpart(1,px+(rnd()*4)-2,py-(rnd()*16),sparkcol,0)
  end
  
 else
  --normal pallete swap
  pal(1,3)
  pal(2,4)
  pal(7,5)
  pal(9,4)
  pal(10,11)
  pal(12,5)
  pal(14,8)
  pal(15,13)
 end
 
 spr(animsprite,px-4,py-15,1,1,pf)
 spr(animsprite+16,px-4,py-7,1,1,pf)
 pal()
 
 cpu=stat(1)
 --print(cpu,woff*128,yoff*112,7)
 --print(wopen,woff*128,yoff*112+20,7)
 --print(eopen,woff*128,yoff*112+40,7)
end