pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--init
--todo:---------------done:-----
                        --fruta
       --witch
       --puff
       																	--timer
       --new level/score screen
                   					--fly higher jump
       
--extra:
							--luciernaga
							--bird
       --powerup
       --level srands
--------------------sprite flags
--1:solid
--2:cloud platform
snd=-------------------------sfx
{
	jump=0,
	die=1,
	fruit=2,
	fly=3,
	witch=4,
	witch2=5,
	witch3=6,
	fall=7,
	gover=8,
	score=9,
	score2=10,
}
mus=---------------music tracks
{
 intro=20,
 main=30
}
function _init()
 --timer tab b = 12
 music(11)
 cartdata("frog")
-- dset(0)--reset
--dset(1,nil) 
 best=dget(0) or 0
 bestlvl=dget(1)
 if(bestlvl==nil)bestlvl=1 lvl=1
 startlvl=bestlvl\5*5
 printh("--------------------")
 --poke(0x5f2d,1)--mouse
 poke(0x5f2e,1)--set perma pal
 palr()--modify 2 darker palette
	mapw=1024
	maph=256+128
	ticks=0
 player=m_frog(4,32)
 witch=m_witch(22,96)--320+16)
 witch:say("HELLO, LITTLE ONE")
 witch:say("I SUMMONED YOU")
 witch:say("I NEED YOUR HELP")
 --witch:say("MAGIC USES INGREDIENTS")
 --witch:say("THEY RE ON THE TREES")
	cam=m_cam(player)
	--game timer variables in restart
	gfruits={}

 --fruit variables	
	jigid=0--who s jiggling b4 falling
 stkid=0--stick 1 fruit to player

	score=0
	lvl=startlvl--+1 on restart
	--_fade_i,_fade_d,_fading=14,-1,true--for fade()
	_fade_i,_fade_d,_fading=13,-1,true--for fade()
	_upd,_drw=upd_intro,drw_intro
	if(lvl<1)startlvl,lvl=1,1
	timer:reset(lvl)
	--upd,_drw=upd_play,drw_play _restart()
end
function _restart()
 music()
 music(1)
 
 stkid=0--soltar lo que traigas
 --fids=0--fruitid
 jigid=0
 lvl+=1
	ticks=0

 for s in all(gfruits)do del(gfruits,s)end
	for s in all(enemies)do s:destroy()end
	for s in all(fruits)do s:destroy()end
	for s in all(fxs)do s:destroy()end
-- m_fruit(40,320,1)
-- m_fruit(50,320,2)
-- m_fruit(60,320,3)
-- m_fruit(70,320,4)
-- m_fruit(80,320,1)
-- m_fruit(90,320,2)
-- m_fruit(100,320,3)
-- m_fruit(110,320,4)

	genmap(mapw/8,maph/8)
	witch:restart()
	player.x,player.y=14,320-18
end
function genmap(w,h)
 local trees,x,y,top={},0,0,10
 local fruit_typs={}--univ de typs
 for x=0,w do for y=0,h do
  mset(x,y,0)
  if(y+rnd{1,2}<top)mset(x,y,rnd{22,23,24,25})
 end end
 --srand(3) --aqui para randomizar
 local level,lastlevel,chlevel,
       samelevel=
       h-4,h-4,false,0
 for x=0,w-3 do
  --chlevel tiene bug
  --si se tiene que usar mid()
  --se reinicia samelevel
	 if (chlevel)then
	  lastlevel=level
	  level+=rnd({-3,-2,-2,-1,-1,-1,1,1,1,2,2,3})
	  level=mid(h-1,level,h-16)
	  -- --todo:no cambiar el nivel si se corrigio
   chlevel=false
   samelevel=0
	 else
	  samelevel+=1
	  if(rnd()<.03*samelevel)then
 	  chlevel=true
 	  if samelevel>4 then--addtree
 	   local typt
 	   typt=gentree(x,level-1,samelevel)
 	   if(typt!=0)add(fruit_typs,typt)
 	   add(trees,x)
 	  else--addweed
 	   mset(x-rnd(3)+1,level-1,26)
 	  end--samelevel>4
	  end--rnd
  end
  mset(x,level,rnd{16,16,17,17,18,18,19,19,20,21})
	 mset(x,level+1,rnd{32,33,34,35,52})
	 for y=level+2,h+10 do
 	 mset(x,y,rnd{36,48,48,49,49,50,50,51,51,52,52,52,52,52,52,52,52,52,52})
	 end
 end
 mset(w-1,level,17)--top
	mset(w-1,level+1,35)

 mset(w-2,level,18)--top
	mset(w-2,level+1,32)

 mset(w-2,level-2,76)--sign
 mset(w-1,level-2,77)--sign
 mset(w-2,level-1,92)--sign
 mset(w-1,level-1,93)--sign
	for y=level+2,h+10 do--below
 	 mset(w-2,y,52)
 	 mset(w-1,y,52)
 end 
 printh("trees:"..#trees)
 for t in all(fruit_typs)do
  printh("typo "..t)
 end 
 
 for i=1,2+lvl\5 do--el objetivo
  local t=rnd(fruit_typs)
  printh(t)
  add(gfruits,t)
 end
 printh("..")
 
 for f in all(gfruits) do
  printh("f"..f)
 end  
end
function gentree(x,y,w)
 local maxfruit=3
 if(lvl>5) maxfruit=4
 if(lvl>10) maxfruit=5
 if(lvl>15) maxfruit=6
 local i,j,tile,top,typ
        =x,y,0,8,
         flr(rnd(maxfruit))+1
        
 local how_many_fruits=0
 --typ es el tipo de fruta
 if(w>12)w=12--maximo 12 de ancho
 if(typ>0)then
  for i=x-w,x do
   if rnd()>.7 then
    m_fruit(i*8,rnd(8)*8+16,typ)
    how_many_fruits+=1
   end
  end
 end
 printh("tree "..x..","..y.."-"..w.." ●"..typ.." #"..how_many_fruits)
 for i=x-w+1,x-1 do--
  if i==x-w+1 then
   tile=42
  elseif i==x-1 then
   tile=43
  else
   tile=37
   if(rnd()>.75)tile=rnd{38,39,40,41}
  end
  mset(i,j,tile)
 end
 if w>7 then--si grueso + raices
  mset(x-1,j,37)
  mset(x-w+1,j,37)
  mset(x,j,43)
  mset(x-w,j,42)
  j=y-1
	 for i=x-w+1,x-1 do
	  if i==x-w+1 then
	   tile=42
	  elseif i==x-1 then
	   tile=43
	  else
	   tile=37
	   if(rnd()>.75)tile=rnd{38,39,40,41}
	  end
	  mset(i,j,tile)
	 end
 end
 j-=1
 bottom=j
 for j=0,bottom do
  for i=x-w+2,x-2 do
   tile=37
   if(j<10+rnd{0,0,0,0,1,1,2})then
    if(rnd()>.5 or (j>0 or j<7+rnd{0,1}))tile=rnd{53,54,53,54,22}--,22}
   else
    if(rnd()>.65)tile=rnd{38,39,40,41}
   end
   mset(i,j,tile)
  end--i
 end--j
 --branchesleft
 j=top+rnd{-1,1}
 repeat
  local len,start=rnd{1,2,3},x-1
  for i=start,start+len do
   if i==start then
    tile=44
   else
    tile=rnd{55,56,57}
   end
   mset(i,j,tile)--este y 2 arriba
   local leaves=rnd{26,27,28,29}
   if(j<top+4) leaves=rnd{27,28,29,23,24,25}
   if(mget(i,j-1)==0)mset(i,j-1,rnd{26,27,28,29})
   if(rnd()>.5 and mget(i,j-2)==0) mset(i,j-2,leaves)
  end
  local leaves=rnd{26,27,28,29}
  if(j<top+4) leaves=rnd{27,28,29,23,24,25}
  mset(start+len+1,j-1,leaves)
  mset(start+len+1,j,leaves)
  j+=rnd{6,5,4,4,4,3,3,2}
 until j>=bottom
 --branchesright
 j=top
 repeat
  local len,start=rnd{1,2,3},x-w+1
  for i=start-len,start do
   if i==start then
    tile=45
   else
    tile=rnd{55,56,57}
   end
   mset(i,j,tile)--este y 2 arriba
   if(mget(i,j-1)==0)mset(i,j-1,rnd{26,27,28,29})
   local leaves=rnd{26,27,28,29}
   if(j<top+4) leaves=rnd{27,28,29,23,24,25}
   if(rnd()>0.5 and mget(i,j-2)==0) mset(i,j-2,leaves)
  end
  local leaves=rnd{26,27,28,29}
  if(j<top+4) leaves=rnd{27,28,29,23,24,25}

  if(mget(start-len-1,j-1)==0)mset(start-len-1,j-1,leaves)
  if(mget(start-len-1,j)==0)mset(start-len-1,j,leaves)
  j+=rnd{6,5,4,4,4,3,3,2}
 until j>=bottom
 if(how_many_fruits>1)return typ
 return 0
end
-->8
--updates
function _update60()
 ticks+=1
 
  _upd()
end
function upd_gover()
 cam:upd()--shake
 if(btnp(⬅️))startlvl-=5
 if(btnp(➡️))startlvl=(startlvl+5)\5*5
 startlvl=mid(1,startlvl,bestlvl\5*5)
 
 if(btn(❎) and ticks>120)then
  fade_to(upd_play,drw_play,function()
   score=0
   timer:reset(max(0,startlvl-1))
   _restart()
  end)
 end
end
function upd_score()
 cam:upd()--shake
 if(btn(❎) and ticks>120)then
  fade_to(upd_play,drw_play,function()
   --lvl=0
   --timer:reset()
   _restart()
  end)
 end
end
function upd_play()
 --timer
 timer:upd()
-- if(t()*1.5%1==0)then--spawn fly
 --como 80 obj simultaneos con 35
 if(ticks%30==0 and #enemies<48)then--spawn fly
  if(rnd()>.65)then
  	m_enemy(0,rnd(maph*.7)+20,rnd{.55,.75,.75})
  else
  	m_enemy(mapw,rnd(maph*.7)+20,-rnd{.55,.75,.75})
  end
 end
	for s in all(objs)do s:upd()end
 cam:upd()
end
function upd_instr()
	if btnp(🅾️) or 
	   (player.x>124 and _fading==false)
	then
	 fade_to(upd_play,drw_play,function()
   timer:reset(max(0,startlvl-1))
	  _restart() 
	 end)
	end
	player:upd()
	fruits[1]:upd()
	if(enemies[1])enemies[1]:upd()
end
function upd_intro()
 if(t()<.3)then
  for i=0,24 do
   local r,r2=rnd(),rnd(.5)+.25
   m_dust(64,107,cos(r)*r2,sin(r)*r2,30,{1,10,10,10,10,6,6,6,7,7,7})
  end
 end
 
 if(btnp(⬅️))startlvl-=5
 if(btnp(➡️))startlvl=(startlvl+5)\5*5
 
 if(startlvl<1)startlvl=1
 if(startlvl>bestlvl\5*5)startlvl=bestlvl\5*5
 --startlvl=mid(1,startlvl,bestlvl\5*5)
-- lvl=max(startlvl-1,0)

 if(btnp(❎))then --init fadeout
  fade_to(upd_instr,drw_instr,function()
  	m_fruit(46,86,3)
  	m_enemy(120,90,-.25)
  	lvl=startlvl-1--theres a +1 on restart
--  	_restart()
   timer:reset(lvl)  	
  end)
 end
 witch:upd()
end

-->8
--draws
function _draw()
 _drw()
 if(_fading) then
	 if(_fade_i>13)then
	  _fade_d=-1
	  _upd,_drw=_n_upd,_n_drw
	  _n_upd,_n_drw=nil,nil
	  if(_n_gs_init)_n_gs_init()
	 end
	 if(_fade_i<0)then
	  _fade_i,_fade_d=nil,nil--fin
	  _fading=false
	  --return
	 end
  if(_fading)then
   fade(_fade_i)
   _fade_i+=_fade_d
  end--fade_i
	end
end
function drw_intro()
 cls(0)parallax(t()*16)map()
 local y=min(t()*120-24,40)
 spro(128,15,42,y-16,6,4)
 witch:drw()
 if(t()>.5)spro(1+(t()*4)%2,0,60,104,1,1,true)
	for s in all(fxs)do s:drw()end
--palt()
if(startlvl>0)then
 printo("sTARTING lEVEL: ",20,64,5,15)
 printo(startlvl,93,64,9,15)
 if(startlvl>1)printo("⬅️",82,64,13,15)
 if(startlvl<(bestlvl\5)*5)printo("➡️",103,64,13,15)
end
 if(t()*2%1>.4)printoc("pRESS ❎ TO sTART",76,5,15)
end
function drw_instr()
 cls(1)
 spro(174,15,110,96,2,2)
 color(6)
 print("fetch the fruits in the order\nrequested before times run out",6,1)
 spr(166,9,14,2,1)print("press ❎ to jump",32,17)
 spr(137,9,27,2,2)print("touch a fruit on the\nground to pick it up",32,50)
 spr(139,9,45,2,2)print("touch a fruit twice to\nmake it fall",32,30)
 spr(135,9,67,2,2)print("squash bugs to get more\ntime",32,70)
 map(16,0,0,0,16,16) 
	fruits[1]:drw()
	if(enemies[1])enemies[1]:drw()
 for s in all(fxs)do s:drw()end
 player:drw()
 if(t()*2%1>.4)printoc("pRESS 🅾️ TO sKIP",120,5,0)
end
function drw_play()
	cls(0)--V` moon
	circfill(64,48-t()/5-player.y*.05,20,14)
	parallax(player.x)
	camera(cam:cam_pos())
	map(0,0,0,0,mapw/8,maph/8)
	for s in all(enemies)do s:drw()end
	for s in all(witches)do s:drw()end
	for s in all(fruits)do s:drw()end
	for s in all(frogs)do s:drw()end
	for s in all(fxs)do s:drw()end
 --todo:hud
 camera(0,0)
 timer:drw()--timer and score
 --?#objs,1,10
 --?stkid,1,20
 --?#enemies,1,20
 --?stat(0),1,30
 --?stat(1),1,40
end
function drw_gover() 
 --local wwin,ywin=64,34  --hwin en upd
 local wwin,ywin=64,34  --hwin en upd
 if(hwin<75)drw_play()hwin+=2 camera(rnd(2),rnd(2))
 draw_rwin2(32,ywin,wwin,hwin,14,13,1,9)
 local y=6
 printoc("time's up!",ywin-1,14,0) 
 if(hwin>9)printoc("level",ywin+8,6,10)
 if(hwin>17)printoc(lvl,ywin+16,7,0)
 if(lvl>4)then
	 if(ticks>40) printoc("start in level",82,6,10)
	 if(ticks>50)then
		 printoc(startlvl,90,7,10)
		 if(startlvl>1)printo("⬅️",50,90,14,15)
		 if(startlvl<bestlvl)printo("➡️",72,90,14,15)
	 end
	else
	 spro(10,0,64-16,82,4,1)
	end--lvl<4
	if(ticks>60 and t()*2%1>.4)printoc("❎ to retry",100,6,10)
 
 if(score>=best)then

  if(hwin>26)printoc("best score!",ywin+25,(ticks%10>5) and 9 or 13,10)
	 if(hwin>34)printoc(score,ywin+33,7,0)

 else
	 if(hwin>26)printoc("final score",ywin+25,6,10)
	 if(hwin>34)printoc(score,ywin+33,7,0)
 
 end
 
end
function drw_score()
 drw_play()
 local wwin,ywin=64,34  --hwin en upd
 if(hwin<56)drw_play()hwin+=2 camera(rnd(2),rnd(2))
 draw_rwin2(32,ywin,wwin,hwin,14,13,2,9)
 local y=6
 printoc("level up!",ywin-1,7,0) 
 if((lvl+1)%5==0)printoc("pROGRESSED sAVED",ywin+40)
 if(hwin>9)printoc("level",ywin+9,6,10)
 if(hwin>17)printoc(lvl,ywin+17,7,0)
 if(hwin>26)printoc("score",ywin+26,6,10)
 if(hwin>34)printoc(score,ywin+34,7,0)
 if(ticks>90 and t()*2%1>.4)printoc("❎ to continue",ywin+45,6,10)
end
function parallax(px)
 local i,x
 srand(5)
 fillp(0b0001001101111111)
 x=px*.075--*.05*2
	for i=0,128*2 do
	 if i%48==0 then
	  rectfill(i-x,rnd(5),-x+i+8+rnd(16),maph,10)
	 end
	end
	x=px*.05--*.025*2
 fillp(0b1111100011001110)
	for i=0,128*2 do
	 local edge=true
	 if i%72==0 then
	  rectfill(i-x,rnd(5)+1,-x+i+16+rnd(16),maph,1)
	 end
	end--back
 srand(t())
 fillp()
end

-->8
--objs
objs={}
function m_obj(x,y,w,h)
 s={x=x,y=y,w=w or 8,h=h or 8,x0=x,y0=y,
 dx=0,dy=0,ax=0,ay=0,flipx,flipy,
 t=0,tst=rnd{0,1,2,3},prevtst=-1,st="idl",
 hit=false,lives=1,
 oob=false,
 upd=u_obj,drw=d_obj,
 col=col,destroy=x_obj,
 out_of_bounds=function(s)
  if(  s.y-s.h>maph or s.y+s.h*5<0
    or s.x-s.w>mapw or s.x+s.w<0)
     then
      s.oob=true--if oob no sfx
      s:destroy() return true
  end
  return false--inside screen
 end
 }
 add(objs,s) return s
end
function x_obj(s)
 del(objs,s)
 return
end
function u_obj(s)
 s.t+=1
 s.tst+=1
 local frames=15
 s.anim2f1=s.tst\frames%2
 s.anim2f2=s.tst\(frames/2)%2
 s.anim2f3=s.tst\(frames/3)%2
 s.anim3f1=s.tst\frames%3
 s.anim3f2=s.tst\(frames/2)%3
 s.anim3f3=s.tst\(frames/3)%3
 s.anim3f4=s.tst\(frames/4)%3
 s.anim4f1=s.tst\frames%4
 s.anim4f2=s.tst\(frames/2)%4
 s.anim4f3=s.tst\(frames/3)%4
 s.anim4f4=s.tst\(frames/4)%4
 s.anim6f1=s.tst\frames%6
 s.anim6f2=s.tst\(frames/2)%6
 s.anim6f3=s.tst\(frames/3)%6
 s.anim8f1=s.tst\frames%8
 s.anim8f2=s.tst\(frames/2)%8
 s.anim8f3=s.tst\(frames/3)%8
 s:out_of_bounds()
end
function d_obj(s)--hitbox
d_hitbox(s)
end
function d_hitbox(s)--hitbox
  rectfill(s.x-s.w/2,s.y-s.h/2,s.x+s.w/2,s.y+s.h/2,8)
-- rectfill(s.x,s.y,
--          s.x+s.w-1,s.y+s.h-1,10)
end
function col(s,o)
  return s.x < o.x+o.w and
         o.x < s.x+s.w and
         s.y < o.y+o.h and
         o.y < s.y+s.h
end
-->8
--frog
frogs={}
function m_frog(x,y)
 s=m_obj(x or rnd(120)+4,y or 8,8,8)
 s.acc,s.dcc,s.air_dcc,
 s.max_dx,s.max_dy,
 s.jump_speed,s.grav =.0325,.8,1,
 1.25
 ,3,1.75,0.15--accel,deccel,airdeccel,etc
	s.jump_hold_time=0--how long jump is held
	s.max_jump_press=15--max time jump can be held
	s.jump_btn_released=true--can we jump again?
	s.grounded=false
	s.airtime=0--time since grounded
 s.tx,s.ty=nil,nil--tongue pos
 s.chst,s.upd,s.drw,s.destroy=
 function(s,nst)--change state
  if(nst!=s.st)then
   s.prevtst=s.tst--cuanto en el st previo
   s.tst=0 s.pst=s.st s.st=nst
  end
 end,
 function(s)--upd
  u_obj(s)
	 ------------collides	in update
	 local e
	 for e in all(enemies) do 
	  if intersects_box_box(
				s.x,s.y,
				s.w,s.h,
				e.x,e.y,
				e.w,e.h)
			then
 	  if (s.dy>0) then--cayendole
 	   timer:addt(10)
     m_points(s.x,s.y,10)
 	   e:destroy()--8 frames press
 	   s.dy-=10--s.jump_speed*30--jump
 	   sfx(3)
 	   cam:shake(5,2)
 	  end
  	end--intersect 
 	end--for enemies  
		--track button presses
		local i
		local bl=btn(⬅️) --left
		local br=btn(➡️) --right
		local bo=btn(🅾️)--
		local bd=btn(⬇️)--drop fruit
		if(bd or bo)and stkid!=0 then
		 stkid=0--stick2none
		 sfx(snd.fruit)
		end
		--move left/right
  if bl==true then
			s.dx-=s.acc
			br=false--handle double press
		elseif br==true then
			s.dx+=s.acc
		else --no bo bl br
			if s.grounded then
				s.dx*=s.dcc
			else
				s.dx*=s.air_dcc
			end
		end--/move left/right
		--limit walk speed
--		if(abs(s.dx)<0.001)s.dx=0--redondear a 0 por que hay error flotante
		if(abs(s.dx)<0.01)s.dx=0--redondear a 0 por que hay error flotante
		s.dx=mid(-s.max_dx,s.dx,s.max_dx)
		--move in x
		s.x+=s.dx
		s.x=mid(0,s.x,mapw)
		--hit walls
		collide_side(s)
		--jump buttons
		s.jump_button:update()
		--we allow jump if:
		--	on ground
		--	recently on ground
		--	pressed btn right before landing
		--also, jump velocity is
		--not instant. it applies over
		--multiple frames.
		if s.jump_button.is_down then
			--is player on ground recently.
			--allow for jump right after
			--walking off ledge.
			local on_ground=s.grounded 
			       or (s.dy>0 and s.airtime<10)
			--was btn presses recently?
			--allow for pressing right before
			--hitting ground.
			local new_jump_btn=s.jump_button.ticks_down<10
			--is player continuing a jump
			--or starting a new one?
			if s.jump_hold_time>0 or (on_ground and new_jump_btn) then
				if(s.jump_hold_time==0)then
				 sfx(snd.jump)--new jump snd
				 local sign=s.flipx and 1 or -1
				 for i=0,7 do
				  m_dust(s.x+s.w/2*sign,
			 	        s.y+s.w/2-2,
			 	        rnd()*sign,
				         rnd(.5),
				         7,{7,6,6,5,5,3,7})
				 end--new jump
				end
				s.jump_hold_time+=1
				--keep applying jump velocity
				--until max jump time.
				if s.jump_hold_time<s.max_jump_press then
					s.dy=-s.jump_speed--keep going up while held
				end
			end
		else
			s.jump_hold_time=0
		end--/jmpbtn down
		--move in y
		s.dy+=s.grav
		s.dy=mid(-s.max_dy,s.dy,s.max_dy)
		s.y+=s.dy
		--floor
		if not collide_floor(s) then
			if(s.dy<0)then
			 s:chst("jmp")--s:set_anim("jump")
			else
				s:chst("fal")--s:set_anim("fall")
			end
			s.grounded=false
			s.airtime+=1
		end--/col floor
		--roof
		--collide_roof(s)
		--handle playing correct animation when
		--on the ground.
		if s.grounded then
			if br then
				if s.dx<0 then
					--pressing right but still moving left.
					s:chst("sld")--s:set_anim("slide")
				else
					s:chst("wlk")--s:set_anim("walk")
				end
			elseif bl then
				if s.dx>0 then
					--pressing left but still moving right.
					s:chst("sld")--s:set_anim("slide")
				else
					s:chst("wlk")--s:set_anim("walk")
				end
			else
				s:chst("idl")--s:set_anim("stand")
			end--/br bl else
		end--/grounded
		--flip
		if br then
			s.flipx=false
		elseif bl then
			s.flipx=true
		end--➡️
 end,--/upd---------------------
 function(s)-----------------drw
  local st,tst,x,y,w,xc,yc,
   f2,f3,f4=
   s.st,flr(s.tst),s.x,s.y,s.w,
   s.x-s.w/2+.5,s.y-s.h/2+.5,
   flr(s.anim2f1),flr(s.anim3f4),
   s.anim4f4
  local sprite=1
  if(s.pst=="fal" and tst==0)then
   --cuando aterriza
   if(s.prevtst>50)cam:shake(10,2*s.prevtst/50)sfx(snd.fall)
   for i=1,s.prevtst/5 do --landing dust
   			m_dust(s.x+rnd(s.w)-s.w/2,
			 	     s.y+s.h/2+1,
			 	     rnd(2)-1,
			       rnd(.4),
	         12,{5,6,7,6,5,3,3})
		 end
		end--pst fal
		if st=="idl" then
   spro(1+f2,0,xc,yc,1,1,s.flipx)
  elseif st=="wlk" then
   if(f4==3)spro(2,0,xc,yc,1,1,s.flipx)
   if(f4==0)spro(3,0,xc,yc,1,1,s.flipx)
   if(f4==1)spro(4,0,xc,yc-2,1,1,s.flipx)
   if(f4==2)spro(5,0,xc-w/2,yc,2,1,s.flipx)
  elseif st=="jmp" then
   spro(3,0,xc,yc,1,1,s.flipx)
  elseif st=="fal" then
   if(s.tst<6)then
    spro(4,0,xc,yc,1,1,s.flipx)
   else
    spro(5,0,xc-w/2,yc,2,1,s.flipx)
   end
  elseif st=="sld" then
   spro(7,0,xc,yc,1,1,s.flipx)
			m_dust(s.x+s.w*s.dx,
			 	     s.y+s.h/2-2,
			 	     rnd(2)*s.dx,
			       rnd(.5),
	         7,{4,7,6,6,4,7})
  end
  
--  ?s.tst,s.x,s.y-30,8
--  ?s.tx,s.x,s.y-24,2
--  ?stkid,s.x,s.y-18,2
--  if(stkid!=0)print(fruits[stkid].typ,s.x,s.y-10,8)
 end,--/drw
 function(s)--destroy
  x_obj(s) del(frogs,s)
 end--/destroy
 --/functions
		--helper for more complex
		--button press tracking.
		--todo: generalize button index.
	s.jump_button=
	{
			update=function(s)
				--start with assumption
				--that not a new press.
				s.is_pressed=false
				if btn(2)or btn(5)then--modeado
					if not s.is_down then
						s.is_pressed=true
					end
					s.is_down=true
					s.ticks_down+=1
				else
					s.is_down=false
					s.is_pressed=false
					s.ticks_down=0
				end
			end,--fin update
			--state
			is_pressed=false,--pressed this frame
			is_down=false,--currently down
			ticks_down=0,--how long down
	}--jmpbtn helper
	s.getx=function(s)
		return s.x
	end
 add(frogs,s)return s
end
-------------------------------
-->8
--fruit
fruits={}
function m_fruit(x,y,typ)
	s=m_obj(x,y,8,8)
	s.typ=typ or 1
	s.st="idl"
	s.delay=0
	s.ddy=.1
	s.maxdy=2
	s.enable=true
	s.id=#fruits+1--fids
	s.upd,s.drw,s.destroy=
	 u_fruit,d_fruit,x_fruit
 add(fruits,s)return s
end
function u_fruit(s)
 if(not s.enable)return
 u_obj(s)
 if(s.delay>0)s.delay-=1
 if jigid==s.id then
  s.st="jig"
 elseif(s.st=="jig")then
  s.st="idl"
 end
 if s.st=="idl" then
  if intersects_box_box(s.x,s.y,s.w,s.h,
       player.x,player.y,player.w,player.h)
  then
    s.st="jig"
    sfx(snd.fruit)
    jigid=s.id
    s.delay=45--dont double tap
  end
 elseif s.st=="jig" and s.delay<1 then
  if intersects_box_box(s.x,s.y,s.w,s.h,
       player.x,player.y,player.w,player.h)
  then
    s.st="fal"
    timer:addt(3)
    m_points(s.x,s.y,3)
    sfx(snd.fruit)
    jigid=0--none selected
  end
 elseif s.st=="fal" then
  s.dy=min(s.maxdy,s.dy+s.ddy)
  s.y+=s.dy
  if(collide_floor(s,true))then
   s.st="dwn"
   sfx(snd.fruit)
   for i=1,16 do --landing dust
   			m_dust(s.x+rnd(s.w)-s.w/2,
			 	     s.y+s.h/2+1,
			 	     rnd(2)-1,
			       rnd(.4),
	         8,{5,6,7,6,5,3,3})
		 end
  end
 elseif s.st=="dwn"then--suelo
  if intersects_box_box(s.x,s.y,s.w,s.h,
       player.x,player.y,player.w,player.h)
  then
   sfx(snd.fruit)
   s.st="stk"
   stkid=s.id
  end--intersect
 elseif s.st=="stk" then
  if(stkid==s.id)then
   s.x,s.y=player.x+.5,
           player.y-3.5+s.anim2f2
  else
   s.st="fal"
   s.dy=-2--propel
  end
 end
end
function d_fruit(s)
 if(not s.enable)return
 --d_obj(s)
 local jig=0
 --print(s.id,s.x,s.y-10,6,2)
 --print(s.typ,s.x,s.y-20,6,2)
 if(s.st=="jig")jig=s.anim2f3
 spro(9+s.typ,0,jig+s.x-s.w/2,s.y-s.w/2)
end
function x_fruit(s)
 del(fruits,s)
 x_obj(s)
end
-->8
--witch
witches={}
--if msg=="need" show fruitsNEEDED
function m_witch(x,y)
 s=m_obj(x,y,24,32)
 s.msgs,s.msg,s.delay={},"",0
 s.collided=true
 s.upd,s.drw,s.destroy,s.restart,
 s.say,s.speaking=
 function(s)--update
  u_obj(s)
  s:speaking()--print msgs[1]
  if intersects_box_box(s.x,s.y,s.w,s.h,
       player.x,player.y,player.w,player.h)
  then
   if s.collided==false then
    if(stkid!=0 and
       gfruits[1]==fruits[stkid].typ)       
    then
     s:say("THANK YOU")
     s:say("JUST WHAT I NEEDED")
     for i=0,1,.07 do
      m_heart(player.x,player.y,cos(i),sin(i),60)
     end
     m_points(s.x,s.y,30,60)
     --fruits[stkid]:destroy()--bug
     fruits[stkid].enable=false--bug
     del(gfruits,gfruits[1])--ok
     stkid=0
     --s.collided=false
     if(#gfruits<1)then
      _upd,_drw=upd_score,drw_score
      sfx(snd.score2)
      hwin=0--para el dialog
      timer:addt(100)
     else
      timer:addt(30)
     end
    else--!stkid
     s.collided=true
		   s:say("I NEED THIS FRUITS")--show needs
		   s:say("need")--show needs
		   --s:say("DID YOU FIND 'EM?")
	   end--stkid!=0 and typ
	   
	  end
	 else
	  s.collided=false
  end
 end,function(s)--draw
  local f3=s.anim3f1
--  ?s.collided,s.x,s.y-24,8
  --body
  spro(96+f3*3,
          0,s.x-s.w/2,
            s.y,3,2,false,false,8)
  --head
  spro(64+f3*2,0,s.x-s.w/2+4,
        f3+s.y-16,2,2,false,false,8)
  --speaking:
  if(s.msg=="")then--null
 
  elseif(s.msg=="need" and #gfruits)then
   --if say "need" show fruits
   local len=#gfruits
   for i=.05,.2,.03 do
    line(s.x+3,s.y-6,-- <balloon
         s.x+3+cos(i)*6,
         s.y-6+sin(i)*6,6)
   end
   draw_rwin(s.x+4,s.y-20,
             6+len*8,12,7,6)
   for i=1,len do
    spro(57+gfruits[i],0,
					    s.x+1+i*8,s.y-16)
   end
   spr(126,s.x-4,s.y+2+s.anim2f1)
  elseif(#gfruits>0) then--not null not "need"
   local hand=126
   local len=#s.msg
   if(len>15)hand+=1
   if(len>22)hand-=1
   palr()
   spr(hand,s.x-4,s.y+2+s.anim2f1)
   
   for i=.05,.2,.03 do
    line(s.x+3,s.y-6,-- <balloon
         s.x+3+cos(i)*6,
         s.y-6+sin(i)*6,6)
   end
   draw_rwin(s.x+4,s.y-20,
             6+len*4,12,7,6)
   print(s.msg,s.x+8,s.y-16,0,6)
  end--msg not null
  palt()
 end,function(s)--destroy
  del(witches,s) x_obj(s)
 end,function(s,x,y)--restart
  s.x=x or 12
  s.y=y or 320+16
  s.msgs,s.msg={},""
 end,function(s,msg)--say
  --if say "need" show fruits
  add(s.msgs,msg)
 end,function(s)--speaking
  if(s.delay>0)s.delay-=1
  if(s.delay==0)then
   s.msg=""
   if(#s.msgs>0)then--inactivo
    sfx(snd.witch+rnd{0,1,2})
    s.msg=s.msgs[1]
 
    s.delay=7*#s.msg
    if(s.msg=="need")s.delay=120
    del(s.msgs,s.msgs[1])
   else
    s.collided=false
   end--#msg>0

  end--delay
 end--speaking 
 u_obj(s)--bug:invoca drw antes de upd
 add(witches,s) return s
end
-->8
--enemies
enemies={}
function m_enemy(x,y,dx)
 s=m_obj(x,y,4,4)
 s.dx=dx or rnd{1,1.25,-1,-1.25}
 s.a=0
 s.enable=true
 s.upd,s.drw,s.destroy=
 function(s)
  if(not s.enable)return
 	u_obj(s)
 	s.a+=.1
 	s.dy=cos(s.a)*4
 	if(s.dx<0)s.flipx=true
 	s.x+=s.dx
 end,function(s)--drw
  if(not s.enable)d_hitbox(s)--return
--  local f3,f4=s.anim3f2
  --d_hitbox(s)palt()
  palt(8,true)palt(0,false)
  spr(121+s.anim3f2,s.x-3,s.y-3+s.anim3f4)--+f4)
  palt()
--  if(f3==2)then
--   sspro(0,0,6,4,2,
--         s.x-2,s.y-2+f4,4,3)
--  else
--   sspro(0,0,f3*3,4,3,
--         s.x-2,s.y-2+f4,4,3)
--  end
 end,function(s)--destroy
   for i=1,6 do --landing dust
 			m_dust(s.x+rnd(s.w)-s.w/2,
	 	     s.y+s.h/2+1,
	 	     rnd(2)-1,
	       rnd(.4),
        8,{5,6,7,6,5,3,3})
		 end
 	del(enemies,s) x_obj(s)
 end,
 add(enemies,s)return s
end
-->8
--fxs
fxs={}
function m_fx(x,y,dx,dy,life,c)
 s={x=x,y=y,dx=dx,dy=dy,
    life=life,c=c or {},ci=0,
    drw=function(s)
     u_fx(s)
--     circ(s.x,s.y,2.5,s.cnow)
    end,
    destroy=x_fx
   }
 add(fxs,s) return s
end
function x_fx(s)
 del(fxs,s)
end
function u_fx(s)
 s.cnow=s.c[ceil(s.ci)%#s.c+1]
 s.cnow2=s.c[ceil(s.ci+2)%#s.c+1]
 s.ci+=.25
 if(s.life<0
--   or s.y>127 or s.y<0
--   or s.x>128 or s.x<0
   )then
   s:destroy()
   return
 end
 s.x=s.x+s.dx
 s.y=s.y+s.dy--+1--grav
 s.life-=1
end
dusts={}
function m_dust(x,y,dx,dy,life,c)
	local s=m_fx(x,y,dx,dy,life,c)
	s.drw,s.destroy=function(s)
		u_fx(s) pset(s.x,s.y,s.cnow)
	end,function(s)--destroy
		del(dusts,s) x_fx(s)
	end
	add(dusts,s) return s
end
points={}
function m_points(x,y,txt,life)
 local s=m_fx(x,y,0,-.3,life or 45,{14})
 s.txt=txt
 s.drw,s.destroy=function(s)
 	u_fx(s) printo(s.txt,s.x,s.y,s.cnow,0)
 end,function(s)--destroy
 	del(points,s) x_fx(s)
 end
 add(points,s)return s
end
hearts={}
function m_heart(x,y,dx,dy,life)
	local s=m_fx(x,y,dx,dy,life,{8})
	s.drw,s.destroy=function(s)
		u_fx(s) printo("♥",s.x,s.y,s.cnow,1)
	end,function(s)--destroy
		del(hearts,s) x_fx(s)
	end
	add(hearts,s) return s
end
-->8
-----libs
--adv platf kit
--------------------------------
--make the camera.
function m_cam(target)
	local c=
	{
		tar=target,--target to follow.
		pos=m_vec(target.x,target.y),
		--how far from center of screen target must
		--be before camera starts following.
		--allows for movement in center without camera
		--constantly moving.
		pull_threshold=16,
		x_treshold=4,y_treshold=16,
		--min and max positions of camera.
		--the edges of the level.
		pos_min=m_vec(64,64),
		pos_max=m_vec(mapw-64,maph-64),--64
		shake_remaining=0,
		shake_force=0,
		upd=function(self)
			self.shake_remaining=max(0,self.shake_remaining-1)
			--follow target outside of
			--pull range.
			if self:pull_max_x()<self.tar.x then
				self.pos.x+=min(self.tar.x-self:pull_max_x(),self.x_treshold)
			end
			if self:pull_min_x()>self.tar.x then
				self.pos.x+=min(self.tar.x-self:pull_min_x(),self.x_treshold)
			end
			if self:pull_max_y()<self.tar.y then
				self.pos.y+=min(self.tar.y-self:pull_max_y(),self.y_treshold)
			end
			if self:pull_min_y()>self.tar.y then
				self.pos.y+=min(self.tar.y-self:pull_min_y(),self.y_treshold)
			end
			--lock to edge
			if(self.pos.x<self.pos_min.x)self.pos.x=self.pos_min.x
			if(self.pos.x>self.pos_max.x)self.pos.x=self.pos_max.x
			if(self.pos.y<self.pos_min.y)self.pos.y=self.pos_min.y
			if(self.pos.y>self.pos_max.y)self.pos.y=self.pos_max.y
		end,
		cam_pos=function(self)
			--calculate camera shake.
			local shk=m_vec(0,0)
			if self.shake_remaining>0 then
				shk.x=rnd(self.shake_force)-(self.shake_force/2)
				shk.y=rnd(self.shake_force)-(self.shake_force/2)
			end
			return round(self.pos.x-64+shk.x),
			       round(self.pos.y-64+shk.y)
		end,
		pull_max_x=function(self)
			return self.pos.x+self.pull_threshold
		end,
		pull_min_x=function(self)
			return self.pos.x-self.pull_threshold
		end,
		pull_max_y=function(self)
			return self.pos.y+self.pull_threshold
		end,
		pull_min_y=function(self)
			return self.pos.y-self.pull_threshold
		end,
		shake=function(self,ticks,force)
			self.shake_remaining=ticks
			self.shake_force=force
		end
	}
	return c
end
--point to box intersection.
function intersects_point_box(px,py,x,y,w,h)
	if flr(px)>=flr(x) and flr(px)<flr(x+w) and
				flr(py)>=flr(y) and flr(py)<flr(y+h) then
		return true
	else
		return false
	end
end
--box to box intersection
function intersects_box_box(
	x1,y1,
	w1,h1,
	x2,y2,
	w2,h2)
	local xd=x1-x2
	local xs=w1*0.5+w2*0.5
	if abs(xd)>=xs then return false end
	local yd=y1-y2
	local ys=h1*0.5+h2*0.5
	if abs(yd)>=ys then return false end
	return true
end
--check if pushing into side tile and resolve.
--requires self.dx,self.x,self.y, and
--assumes tile flag 0 == solid
--assumes sprite size of 8x8
function collide_side(self)
	local offset,i=self.w/3
	for i=-(self.w/3),(self.w/3),2 do
	--if self.dx>0 then
		if fget(mget((self.x+(offset))/8,(self.y+i)/8),0) then
			self.dx=0
			self.x=(flr(((self.x+(offset))/8))*8)-(offset)
			return true
		end
	--elseif self.dx<0 then
		if fget(mget((self.x-(offset))/8,(self.y+i)/8),0) then
			self.dx=0
			self.x=(flr((self.x-(offset))/8)*8)+8+(offset)
			return true
		end
--	end
	end
	--didn't hit a solid tile.
	return false
end
--check if pushing into floor tile and resolve.
--requires self.dx,self.x,self.y,self.grounded,self.airtime and
--assumes tile flag 0 or 1 == solid
function collide_floor(self,nocloud)
	--only check for ground when falling.
	if self.dy<0 then
		return false
	end
	local landed,i=false
	--check for collision at multiple points along the bottom
	--of the sprite: left, center, and right.
	for i=-(self.w/3),(self.w/3),2 do
		local tile=mget((self.x+i)/8,(self.y+(self.h/2))/8)
		if fget(tile,0) or (fget(tile,1) and self.dy>=0 and not nocloud and not btn(⬇️)) then
			self.dy=0
			self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h/2)
			self.grounded=true
			self.airtime=0
			landed=true
		end
	end
	return landed
end
--check if pushing into roof tile and resolve.
--requires self.dy,self.x,self.y, and
--assumes tile flag 0 == solid
function collide_roof(self)
	--check for collision at multiple points along the top
	--of the sprite: left, center, and right.
	for i=-(self.w/3),(self.w/3),2 do
		if fget(mget((self.x+i)/8,(self.y-(self.h/2))/8),0) then
			self.dy=0
			self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
			self.jump_hold_time=0
		end
	end
end
--make 2d vector
function m_vec(x,y)
	local v=
	{
		x=x,
		y=y,
  --get the length of the vector
		get_length=function(self)
			return sqrt(self.x^2+self.y^2)
		end,
  --get the normal of the vector
		get_norm=function(self)
			local l = self:get_length()
			return m_vec(self.x / l, self.y / l),l;
		end,
	}
	return v
end

--square root.
function sqr(a) return a*a end

--round to the nearest whole number.
function round(a) return flr(a+0.5) end
-->8
--libs mine
function palr(transparent)
 pal()
 if(transparent!=0)then
  palt(0,false)
  palt(transparent,true)
 end
 pal(10,128+1,1)
 pal(13,9,1)
 pal(12,128+13,1)
 pal(11,128+11,1)
 pal(14,128+7,1)
 pal(15,128+0,1)
 --pal(6,128+6,1)
 pal(5,128+10,1)
-- pal(6,128+13,1)
-- pal(4,128+4,1)
pal(9,128+9,1)
end
fadetable={
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {1,1,129,129,129,129,129,129,129,129,0,0,0,0,0},
 {2,2,2,130,130,130,130,130,128,128,128,128,128,0,0},
 {3,3,3,131,131,131,131,129,129,129,129,129,0,0,0},
 {4,4,132,132,132,132,132,132,130,128,128,128,128,0,0},
 {138,138,138,138,5,5,5,5,133,133,128,128,128,128,0},
 {6,6,134,13,13,13,141,5,5,5,133,130,128,128,0},
 {7,6,6,6,134,134,134,134,5,5,5,133,130,128,0},
 {8,8,136,136,136,136,132,132,132,130,128,128,128,128,0},
 {137,137,4,4,4,4,132,132,132,132,128,128,128,128,0},
 {129,129,129,129,129,129,129,0,0,0,0,0,0,0,0},
 {139,139,3,3,3,3,3,131,129,129,129,129,0,0,0},
 {141,141,5,133,133,133,130,130,130,128,128,128,128,0,0},
 {9,9,9,4,4,4,4,132,132,132,128,128,128,128,0},
 {135,135,135,134,134,134,134,5,5,5,133,133,128,128,0},
 {128,128,128,128,128,128,128,0,0,0,0,0,0,0,0}
}
function fade_to(u,d,funct)
 ticks=0
 _fading=true
 _fade_i,_fade_d=0,1
 _n_upd,_n_drw=u,d
 _n_gs_init=funct
end
function fade(_i)
 if (not _i)return
 for c=0,15 do
  if flr(_i+1)>=16 then
   pal(c,23,1)
  else
   pal(c,fadetable[c+1][flr(_i+1)],1)
  end
 end
end

--------------------------------
--            MINE            --
--------------------------------
function spro(sp,outline,x,y,a,b,h,v,transparent)
 local a=a or 1
 local b=b or 1
 local h=h or false
 local v=v or false
 local transp=transparent or 0

 palr(transp)
 for i=0,15 do pal(i,outline) end
 for i=-1,1 do for j=-1,1 do
  spr(sp,x+i,y+j,a,b,h,v)
 end end
 palr(transp)
 spr(sp,x,y,a,b,h,v)
end
function sspro(outline,sx,sy,sw,sh,dx,dy,dw,dh)
 local i,j
 for i=0,15 do if(i!=outline)pal(i,outline) end
 for i=-1,1 do for j=-1,1 do
  sspr(sx,sy,sw,sh,dx+i,dy+j,dw,dh)
 end end
 palr()
 sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end

function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end
function printoc(str,y,c0,c1)
 local xs=0
 local str=tostr(str)
 for i=0,#str do
  if(sub(str,i,i)=="❎")xs+=1
 end
 local x=(128-(#str*4+xs*4)+2)/2

 printo(str,x,y,c0,c1)
end

function printc(str,y,c0)
 local xs=0
 for i=0,#str do
  if(sub(str,i,i)=="❎")xs+=1
 end
 local x=(128-(#str*4+xs*4)+2)/2

 print(str,x,y,c0)
end


-------------------------------
function draw_rwin2(_x,_y,_w,_h,_c1,_c2,_c3,_c4)
 draw_rwin(_x,_y,_w,_h,_c1,_c2)
 draw_rwin(_x+2,_y+2,_w-4,_h-4,_c3,_c4)
end
function draw_rwin(_x,_y,_w,_h,_c1,_c2)
 -- would check screen bounds but may want to scroll window on?
 if (_w<12 or _h<12) return(false) -- min size
 -- okay draw inside
 rectfill(_x+3,_y+1,_x+_w-3,_y+_h-1,_c1) -- x big middle bit
 line(_x+2,_y+3,_x+2,_y+_h-3,_c1) -- x left edge taller
 line(_x+1,_y+5,_x+1,_y+_h-5,_c1) -- x left edge shorter
 line(_x+_w-2,_y+3,_x+_w-2,_y+_h-3,_c1) -- x right edge taller
 line(_x+_w-1,_y+5,_x+_w-1,_y+_h-5,_c1) -- x right edge shorter
 --now the border left side
 line(_x,_y+5,_x,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+1,_y+3,_x+1,_y+4,_c2) -- x 2 left top
 line(_x+1,_y+_h-4,_x+1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+2,_y+2,_c2)  -- x 1 top dot
 pset(_x+2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+3,_y+1,_x+4,_y+1,_c2)  -- x 2 top curve
 line(_x+3,_y+_h-1,_x+4,_y+_h-1,_c2)  -- x 2 btm curve
 --now the border right side
 line(_x+_w,_y+5,_x+_w,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+_w-1,_y+3,_x+_w-1,_y+4,_c2) -- x 2 left top
 line(_x+_w-1,_y+_h-4,_x+_w-1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+_w-2,_y+2,_c2)  -- x 1 top dot
 pset(_x+_w-2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+_w-3,_y+1,_x+_w-4,_y+1,_c2)  -- x 2 top curve
 line(_x+_w-3,_y+_h-1,_x+_w-4,_y+_h-1,_c2)  -- x 2 btm curve
 -- top and bottom!
 line(_x+5,_y,_x+_w-5,_y,_c2) -- x top
 line(_x+5,_y+_h,_x+_w-5,_y+_h,_c2) -- x bottom
end

-->8
 timer={
   lvl=1,t=100,delta=.05,
   barcols={8,9,13,14,11,5},
   upd=function(s)
   	if s.t<1 then
   	 if s.lvl>1 then-- lvl>red
   	  s.lvl-=1 s.t=100
   	 else--time s up
			   _upd,_drw=upd_gover,drw_gover
			   if(score>best)best=score dset(0,score)
			   if(lvl>bestlvl)bestlvl=lvl dset(1,bestlevel)
			   ticks=0
			   hwin=0--min height
--			   startlvl=lvl
			   cam:shake(15,8)sfx(snd.gover)   	  
   	 end
   	end
   	s.t-=s.delta
   end,drw=function(s)  --drw
    local x,y,w,h,i=18,123,84,2,0
    printo("tIME",1,y-2,6,15)
--    spro(90,15,1,120,15)
    local pw=s.t/100*w--perc
    --timebar:border,back,front%
 			rectfill(x-1,y-1,x+w+1,y+h+1,15)--border
 			if(s.lvl>1)then
 			 rectfill(x,y,x+w,y+h,
 			     s.barcols[s.lvl-1])--back bar
 			end
 		 rectfill(x,y,x+pw,y+h,--per%
         s.barcols[s.lvl])
    printoc(flr(s.t),y-2,6,15)
    --bars done
    x=103 --brackets[●]
    local fruit_t=0--la que cargo
			 if(stkid!=0)then--carrying fruit
			  fruit_t=fruits[stkid].typ
			 end
			 if(gfruits[1]==fruit_t)then
			  --si es la misma no mostrar			 
			  printo("gIVE!",x+3,y-2,(ticks%10>5) and 9 or 13,0)
			 else
			  printo("gET",x+3,y-2,6,15)
     spro(78,15,x+14,y-6,2,2)--[]
			  if(gfruits[1])spro(57+gfruits[1],0,x+17,y-4)
			 end
 			printoc("score: "..score,1,6,0)
 			printo("level: "..lvl,92,1,6,15)
 			printo("best: "..best,1,1,6,15)
   end,reset=function(s,_lvl)--reset
    lvl=_lvl or (bestlvl\5)*5-1
    s.lvl=3
    s.delta,s.t=.04+s.lvl*0.0075,100
   end,addt=function(s,n)
			 score+=n
			 s.t+=n
			 if(s.t>100)then 
			  if(s.lvl<#s.barcols)then
				  s.t=s.t%100 
				  s.lvl+=1
			  else
			   s.t=100 s.lvl=#s.barcols
			  end
			 end
   
   end--addtime
 }--timer
__gfx__
771c000000000000000000000000bbbb000bbbb003330b0000000000000000000000000000000000000c00000003000000020000000c00000001000000010000
011000000000000000000000000bb1b100bb1b10000333bb0000000000000000000000000000000000dd900000ee50000099900000eee00000cc200000bbb000
000000000000000000000000000b3ddd00b3ddd0000033bbb000000000000000000000000000000000ddd00000eee000099998000eeeed0000ccc0000bbbb300
07c00000000000000000000000bb3dd00bb3dd03000000abbb00000000000bb300000000000000000dd999000eeee50099988820eeeeddc00cccc200bbbbb310
711c000000bbbb000b30330000b3d330b33dd330000000dabbbb00000030b1b10000000000000000dd9999c0eeee553099888820eeedddc0cccc2210bbbb3310
700c00003b31b1000bbbbb300b3d3030bdd030000000000db1b100000303dddb0000000000000000dd999cc0eee5533099888220eedddcc0ccc22110bbb33110
07c00000bbdddd30bb31b1300b030000b003000000000000dbbb00000bbddd0b00000000000000000999cc000e553300088822000eddcc000c2211000b331100
01100000b33dd333b3dddd33b030000000000000000000000dd0d000b30330b0000000000000000000ccc000003330000022200000ccc0000011100000111000
5555555b5255555b5555525555555555299999d999999992bbbbb333333b3033333333003bb3bbbb000000000000333000003000000300003333333300300303
bbbbbbb3b4bbbbb3bbbbb5bbbbbbbbbb44444dd4444444443bbbb33333bb333b33333330bbb3bbbb300000000003333330003333000330003303030000300303
bbbbbbb333bbbb33bbbbb3bbbbbbbb334444ddd44d44444d33bbb3333bbb33bb333333b3bbb3bbb3330000030033333333003333000333003303030000303003
3b3bbd33443bb333bbbb3bbb33bbb33d444dddd44dd4444d333bb333bbbb3bbbb333bbbb3bb3bb33333000330333333333303333300333300300030000330030
333bbd334433333f33333bbb44bb33dd44ddddd44ddd444d333333333333bbbbbb3bbbbb33b3b333333303333333333333303333330033330300030000330030
33dddd334ddd334fdd33443344333ddd4dddddd44dddd44d3333bb33333bbbbbbbbbbbbb33333333033303303333303303303333333033330000030000330300
444ddd44fdd4344fdddddddd4443ddd4ddddddd44ddddddd3333bbb333333333bbbbbbbb33333330003303000333300300003330033033330000030000333300
4444dd44fd44444fdddddddd4444444444444444444444443333bbbb303333330bbbbbbb03333300000300000033300000003300003033330000000000033000
ffffffdffffff4ffffffffffffffffffed4fffff44444444444444444444444449444999944444440000000440000000000dddddddddd0000000000000033000
fffffddfffff4df4dddfffff4fddddffdd4fffff44444444499999949999444949944499994444440000004444000000ddd4444444444ddd0000000000033000
4444dddffff4ddf44dd0ffff44dddfff444fffff4444444449999944999444994999444944444444000004444440000044444444444444440000000000033000
444ddddfff4dddf444d0ffff44ddffffffffffff4444444449999444994449994999944444444444000044444444000044444444444444440000000000003000
44dddddff4ddddf44440dfff44d4fdffffffffff4444444449994444944499994999994444449444000444444444400044440000000044440000000000003000
4ddddddf4dddddf44444ddff4444ddfffffffff44444444449944444444999994999999444449944004444444444440044400000000004440000000000003000
444fffffddddddf44444dddf444ddd4fffffff444444444449444444449999994999999944449994044444444444444044000000000000440000000000003000
44ffffffffffffffffffddddfffffffffffff4444444444444444444499999994444444444449999444444444444444440000000000000040000000000003000
ffffffffffffffffffffffffffffffffffffffffbbbbb3344333b3330000dddd0ddd00003b3dd3b300c00000003000000020000000c000000010000000100000
fff4fffff4444444f44444fffffff444ffffffff3bbbb344b433bb33dddd4444d444ddddb344443b0ddd00000eee0000099900000eee00000ccc00000bbb0000
ff44fffff444444ff4444ffffffff44fffffffff33bbb444bb43bbb34444444444444444344444430dd900000ee5000099988000eeedd0000cc20000bbb33000
f444fffff44444fff444fffffffff4ffffffffff333bb444bbb4bbbb444400004404444430000003dd99c000ee55300099882000eeddc000cc221000bb331000
4444fffff4444ffff44fffffffffffffffffffff33344444bbbb4333000000000000000030000003d99cc000e553300098822000eddcc000c2211000b3311000
fffffff4f444fffff4fffffff444ffffffffffff3344bb44bbbbb4330000000000000000300000000ccc000003330000022200000ccc00000111000001110000
ffffff44f44ffffffffffffff44fffffffffffff3444bbb444444443000000000000000030000000000000000000000000000000000000000000000000000000
fffff444f4fffffffffffffff4ffffffffffffff4444bbbb44444444000000000000000000000000000000000000000000000000000000000000000000000000
8888cc88888888888888ccc88888888888888888888888888888cc888888888800000000000000000ddddd000000000000000999999999990000000000000000
888cccc888888888888ccccc888888888888ccc888888888888cccc8888888880000000000000000d00000d00000000000009444444444440990000099000000
888ccccc88888888888ccc2222888888888cccccc8888888888ccccc888888880000000000000000d00000d00000000000094224442244440900000009000000
888ccc222288888888cc22fffff88888888ccc2222288888888ccc222288888800000000000000000d666d000000000000942ff242ff24420000000000000000
88cc22fffff8888888c2fff0000f288888cc22fffff2888888cc22fffff88888000000000000000000d6d000000000000944f99f4f99f9400000000000000000
88c2fff0000f2888882ff00ccccccc288cc2fff0000f288888c2fff0000f288800000000000000000d060d00000000009444f4224f44f4200000000000000000
882ff00ccccccc2888f00cc2222222288c2ff00cccccccc8882ff00ccccccc280000000000000000d66666d0000000004994f4ff4f44f4000000000000000000
88f00cc222222228880cc2200000088888f00cc22222222288f00cc22222222800000000000000000ddddd00000000002444f49f4f44f2000000000000000000
880cc220000000888cc2200fffff0088880cc22000000088880cc220000000880000000000000000eeeeeeee000000000244f44f4f44f4000900000009000000
8cc2200bbbff00888c200ffbbbfff0088ccc200bbbfff0888cc2200bbbff0088000000000000000000e000000000000000240220402204400990000099000000
8c20bbbbbbbbfff8880fbbbbbbbbfff8c2220bbbbbbfff888c20bbbbbbbbfff8000000000000000000e0e0ee0ee00ee000029009490094440000000000000000
880b5a5555a5fff88ffb5a5555a5ffff0000ba5555abfff8880b5a5555a5fff8000000000000000000e000eeeee0e0e000004994449944490000000000000000
8ff555555555fffffff555555555ffff8f0555555555ffff8ff555555555ffff000000000000000000e0e0e0e0e0e0000000000fffff00000000000000000000
ffff55555555fffffff055555555fffffff055555555ffffffff55555555ffff000000000000000000e0e0e0e0e00ee000000002222200000000000000000000
fffff555555fffffffff05555550fff8ffff05555550fffffffff555555fffff000000000000000000e000000000000000000002444400000000000000000000
8888fff55fff888888fff005500fff88fffff005500fffff8888ff5555ff88880000000000000000000000000000000000000002444400000000000000000000
888888882c2002c28888888888888888888888888888888888888888888888888888888800000000000000000000000000000000000000000000000000000000
88888888c200002c88888888888888882c2002c28888888888888888222002228888888800000000000000000000000000000000000000000000000000000000
8888888c20000002c888888888888888c200002c8888888888888888c200002c8888888800000000000000000000000000000000000000000000000000000000
888888cc20ffff022c8888888888888c20000002c88888888888888c20000002c888888800000000000000000000000000000000000000000000000000000000
88888cc220ffff0022c88888888888cc200ff002cc888888888888cc200fff002c88888800000000000000000000000000000000000000000000000000000000
8888cc2200fffff022c8888888888cc220ffff002cc8888888888cc200fffff02cc8888800000000000000000000000000000000000000000000000000000000
8888c2200fffffffb22c88888888cc2200ffffff22c888888888cc200fffffff02cc888800000000000000000000000000000000000000000000000000000000
888cc2000fffffff5b2c8888888cc2200fffffffb2cc8888888cc2000ffffffffb2cc88800000000000000000000000000000000000000000000000000000000
888c2200f0fffff00b22c888888c220000fffff05b2cc88888cc2200fffffffff5b2cc8888888888800008888888888800000000000000000000000000500000
88cc2200ff00000f0022c88888cc2200ff00000f0b22c8888cc2200f00fffff005b22c8800000088007c00880000008800000000000000000f500000ff500000
88c22000fffffffff002c88888c2200fffffffff000228888c22200fff00000ff00222880771c0880711c0880700c08800000000555000000555500055550000
8822200ffffffffff00228888822200ffffffffff0022888822220ffffffffffff022288001100880700c088007c00880000000055500000055b0000555b0000
8822200fffffffffff022888882220ffffffffffff022888882200fffffffffffff2288880000888000000888011088800000000bb00000005b00000bbb00000
88880000ffffffff000088888888800ffffffffffff0888888880ffffffffffffff0888888888888888888888000088800000000000000000000000000000000
888888888bb00bb888888888888888000bb00bb00008888888888000bb0000bb0008888888888888888888888888888800000000000000000000000000000000
888888888ff88ff888888888888888888ff88ff888888888888888888ff88ff88888888888888888888888888888888800000000000000000000000000000000
00000099099900000000000000000009900000000000000000000000000000000000066606660000000006660000000000066000000000066000000000000000
00000009999990999009099009990099990999000000000000000000000000000000666660066060000066660000066000660000000000660000000000000000
00000000990990000909999900009009900000900000000000000000000000000006666000600600000666600000666606666000000006666000000000000000
00000009900990099900990900999009900099900000000000000000000000000006660606006060000666060006666606666000000006666000000000000000
00000009900990990990900909909909900990990000000000000000000000000066600066660000006660000066666006666000000006666000000000000000
00000009999990999990900999999909900999990000000000000000000000000060600000000000006060000606006600660000000000660000000000000000
00000009999900099090900090990909900099090000000000000000000006000606000000000660060600006666666666006666000000000000000000000000
00000009909990000000000000000000999000000000000000000000000000000000000000006600000000000000000000000000000000600000000000000000
00000099900999000999900e00e00000000000000000000000000000000600060000000000066660600000000000000000660000000000000000000000000000
00000099900099009999990e00e000eee00000000000000000000000000000000000000000066660000000000000000006600000000000600000000000000000
0000009900000990990000eee0eee0e0e00000000000000000000000000000600600000000066660000000000000000066660660000000000660000000000000
00000990000000009900000e00e0e0e0000000000000000000000000060000066000000000006600000000000000000066606666000000006666000000000000
00000000000000099999900e00e0e00ee09990900000000000000000000000066000000000000000000000000000000006066666000000066666000000000000
0000000b0b0000999999900000000000099099900000000000000000000000000000000000600000000000000000000000666660000000666660000000000000
000000b0b0b000009900099900009990090009000000000000000000000000000000000000000000000000000000000006060066000006060066000000000000
00000bb0b0bb00009900009999099099099099000000000000000000600000000000000060000000000000006666666666666666666666666666666600000000
00000bbbbbbb00009900009009090009009999000000000000000060060000000000000000000000000000000000000000000000000000009999999999900000
0000099bbb9900009900099000099099000009000000000000060000000000000000000000000000000000000000000000000000000000004444224442240000
00000099999000009900099000099999099099000000000000000000060600000000000000000000000000000000000000000000000000004442ff242ff29000
0000000000000009990009900000999009999900000000000600000000666600000000000000000000000000000000000000000000000000244f99f4f99f4900
0000000000000099900000000000000000099000000000000000000000066660000000000000000000000000000000000000000000000000049f4224f44f4490
0bb0000b00b000000000b00000000000b0000000000000000000000000006660000000000000000000000000000000000000000000000000024f4ff4f44f4449
b0b0000b00b000bbb000b000b0000b00b0b0bbb0bbb000006000000000006006000000000000000000000000000000000000000000000000004f49f4f44f4994
0b0000bbb0bbb0b0b000bbb0bbb0b0b0bb00b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000002f44f4f44f4442
b0b0000b00b0b0b00000b0b0b0b0b0b0b0b0b000b0b0000000000000000000000000000000000000000000000000000000000000000000000040220402204420
b00b000b00b0b00bb000bbb0b000bbb0b0b00bb0b0b0000000000000000000000000000000000000000000000000000000000000000000000449009490094200
0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444994449942000
00000000000044000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000009444444444420000
000000000004000040040004440044004000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffff0000000
00000000000440040404440404040004440000000000000000000000000000000000000000000000000000000000000000000000000000000000022220000000
00000000000400040404000400004400400000000000000000000000000000000000000000000000000000000000000000000000000000000000044420000000
00000000000400044404000044044400400000000000000000000000000000000000000000000000000000000000000000000000000000000000044420000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b5b5b5b5b525b5b55b5b5b2b5b5b5b5b0000000000000000333bbbbb3303b33300333333bbbb3bb3000000000333000000030000000030000000000000000000
3bbbbbbb3b4bbbbbbbbbbb5bbbbbbbbb0000000000000000333bbbb3b333bb3303333333bbbb3bbb000000033333300033330003000330000000000000000000
3bbbbbbb333bbbb3bbbbbb3b3bbbbbb30000000000000000333bbb33bb33bbb33b3333333bbb3bbb300000333333330033330033003330000000000000000000
33b3bbd33443bb33bbbbb3bbd33bbb330000000000000000333bb333bbb3bbbbbbbb333b33bb3bb3330003333333333033330333033330030000000000000000
3333bbd3f4433333b33333bbd44bb33d000000000000000033333333bbbb3333bbbbb3bb333b3b33333033333333333333330333333300330000000000000000
333dddd3f4ddd3343dd33443d44333dd000000000000000033bb3333bbbbb333bbbbbbbb33333333033033303303333333330330333303330000000000000000
4444ddd4ffdd4344dddddddd44443ddd00000000000000003bbb333333333333bbbbbbbb03333333003033003003333003330000333303300000000000000000
44444dd4ffd44444dddddddd444444440000000000000000bbbb333333333303bbbbbbb000333330000030000003330000330000333303000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddd0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444440000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444440000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444440000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440000000044440000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044000000000000440000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000040000000000000000
00000000000000000000000000000000000000004444444444444444000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000bbbbb3344333b333dddddddddddddddd3b3dd3b3000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003bbbb344b433bb334444444444444444b344443b000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033bbb444bb43bbb3444444444444444434444443000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000333bb444bbb4bbbb000000000000000030000003000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033344444bbbb4333000000000000000030000003000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003344bb44bbbbb433000000000000000030000003000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003444bbb444444443000000000000000030000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011101110111011101110111011101110000000000000000000000000000000000000000000000000000000000000000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000000000000000000000000000000000000000000000000000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000pp0ppp0000000000000000000pp000000111011101110000hh00hh00hh0000000000000000000000
0011001100110011001100110011001100000000000000000pppppp0ppp00p0pp00ppp00pppp0ppp0011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000pp0pp0000p0ppppp0000p00pp00000p00100010001000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000pp00pp00ppp00pp0p00ppp00pp000ppp000000000000000hhh0hhh0hh0000000000000000000000
0111011101110111011101110111011100000000000000000pp00pp0pp0pp0p00p0pp0pp0pp00pp0pp01011101110000hh00hh00hh0000000000000000000000
0011001100110011001100110011001100000000000000000pppppp0ppppp0p00ppppppp0pp00ppppp01001100110000h000h000h00000000000000000000000
0001000100010001000100010001000100000000000000000ppppp000pp0p0p000p0pp0p0pp000pp0p0100010001000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000pp0ppp0000000000000000000ppp0000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000ppp00ppp000pppp00n00n000000000110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000ppp000pp00pppppp0n00n000nnn000110011001100110000h000h000h00000000000000000000000
000100010001000100010001000100010000000000000000pp00000pp0pp0000nnn0nnn0n0n00001000100010001000000000000000000000000000000000000
00000000000000000000000000000000000000000000000pp000hh0000pp00000n00n0n0n00000000000000000000000hhh0hhh0hh0000000000000000000000
01110111011101110111011101110111000000000000000000000h000pppppp00n00n0n00nn0ppp0p011011101110000hh00hh00hh0000000000000000000000
0011001100110011001100110011001100000000000000000r0r0000ppppppp000000000000pp0ppp011001100110000h000h000h00000000000000000000000
000100010001000100010001000100010000000000000000r0r0r00000pp000ppp0000ppp00p000p000100010001000000000000000000000000000000000000
00000000000000000000000000000000000000000000000rr0r0rr00h0pp0h00pppp0pp0pp0pp0pp0000000000000000hhh0hhh0hh0000000000000000000000
01110111011101110111011101110111000000000000000rrrrrrr00h0pp0h00p00p0p000p00pppp0111011101110000hh00hh00hh0000000000000000000000
00110011001100110011001100110011000000000000000pprrrpp00h0pp000pp0000pp0pp00000p0011001100110000h000h000h00000000000000000000000
000100010001000100010001000100010000000000000000ppppp00000pp000pp0000ppppp0pp0pp000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000h00ppp0h0pp0h000ppp00ppppp0000000000000000hhh0hhh0hh0000000000000000000000
01110111011101110111011101110111000000000000000000000000ppp000000000h00000000pp00111011101110000hh00hh00hh0000000000000000000000
0011001100110011001100110011001100000000000rr0000r00r0000000h0r0h000h00000r000000000001100110000h000h000h00000000000000000000000
000100010001000100010001000100010000000000r0r0000r00r000rrr000r000r0000r00r0r0rrr0rrr0010001000000000000000000000000000000000000
0000000000000000000000000000000000000000000r0000rrr0rrr0r0r0h0rrr0rrr0r0r0rr00r0r0r0r00000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000r0r0000r00r0r0r000h0r0r0r0r0r0r0r0r0r000r0r01101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000r00r000r00r0r00rr0h0rrr0r000rrr0r0r00rr0r0r01100110000h000h000h00000000000000000000000
0001000100010001000100010001000100000000000r000000000000000000000000000000000000000000010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh000440000000000000000004000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh0004000040040004440044004001110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h00004400404044404040400044400110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000400040404000400004400400001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh004000444040000440444004000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00000000000000h0000000000001110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100110011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
00010001000100010001000100010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
000000000000000000000000000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111011101110111011101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
001100110011001100000011001100110000000000000000h000h000h000h000h000h001001100110011001100110000h000h000h00000000000000000000000
000100010001000100ttt00000010001000000000000000000000000000000000000000100010001000100010001000000000000000000000000000000000000
00000000000000000tttttt0000000000000000000000000hhh0hhh0hhh0hhh0hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
01110111011101100ttt2222200101110000000000000000hh00hh00hh00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
0011001100110000tt22ggggg20000110000000000000000h000h000h000h000h000h061001100110011001100110000h000h000h00000000000000000000000
000100010001000tt2ggg0000g200001000000000000000000000000000060000000000100010001000100010001000000000000000000000000000000000000
000000000000000t2gg00tttttttt0000000000000000000hhh0hhh0hhh6hhh6hhh0h000000000000000000000000000hhh0hhh0hh0000000000000000000000
0111011101110100g00tt222222222010000000000000000hh00h6006h00hh00hh00h001011101110111011101110000hh00hh00hh0000000000000000000000
00110011001100000tt22000000000010000000000000000h000h600h000h000h600h001001660110011001100110000h000h000h00000000000000000000000
000100010001000ttt200rrrggg00001000000000000000000000000000000600000000100010001000100010001000000000000000000000000000000000000
00000000000000t2220rrrrrrggg00000000000000000000hhh0hhh0hhh0hh60hhh6h000000000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111000000rhqqqqhrggg0010000000000000000hh00hh00hh066600h600h601061101110111011101110000hh00hh00hh0000000000000000000000
001100110011000g0qqqqqqqqqgggg010000000000000000h060h660h000h000h000h601661100610011001100110000h000h000h00000000000000000000000
00010001000100ggg0qqqqqqqqgggg01000000000000000060000000000060006600000660010001000100010001000000000000000000000000000000000000
00000000000000gggg0qqqqqq0gggg000000000000000000hhh0hhh0hhh0hhh0hhh0h606000000000000000000000000hhh0hhh0hh0000000000000000000000
01110111011100ggggg00qq00ggggg010000000000000000hh00h666hhh6hhhhh606h606611101110111011101110000hh00hh00hh0000000000000000000000
001100110011000000000000000000010000000000000000h000h006h066606hh00h6661606100110011001100110000h000h000h00000000000000000000000
00010001000100000t20000002t0000100000000000000600000000000h06hh66600h00106010061000100010001000000000000000000000000000000000000
0000000000000000tt200ggg002t00000000000000000000hhh0hhh66hhhhhh6hhh6h00000h000000000000000000000hhh0hhh0hh0000000000000000000000
011101110111000tt200ggggg02tt0010000000000000000hh00hhh66h006h60h60hh0610h1101110111011101110000hh00hh00hh0000000000000000000000
00110011001100tt200ggggggg02tt000000000000000000h066h06h600h6h6h60h0h6660h1h00160011001100110000h000h000h00000000000000000000000
0001000100000tt2000ggggggggr2tt00000000000000600006000h6606h00000000060100010601000100010001000000000000000000000000000000000000
000000000000tt2200gggggggggqr2tt0000000000000000hhh0hhh6h6hhhhh0hhh06h00060600060000000000000000hhh0hhh0hh0000000000000000000000
01110111010tt2200g00ggggg00qr22t00000000000006006h06hh606h0hhh00hh006661611161610111011101110000hh00hh00hh0000000000000000000000
00110011000t22200ggg00000gg002220000000000000000h000h6066600h000h000hh61061600160011001100110000h000h000h00000000000000000000000
0001000100022220gggggggggggg0222000000000000000000000660h6h000000000h00660610601000100010001000000000000000000000000000000000000
0000000000002200ggggggggggggg2200000000000000006hh66h6h0hhh0h0rrrr00hhhhh0h600000000000000000000hhh0hhh0hh0000000000000000000000
011101110110000gggggggggggggg00000000000000000606h00hh00hh00001r13r30061h16h01110116011101110000hh00hh00hh0000000000000000000000
001100110011000000rr0000rr0000010000000000000000h000hh60h000039h9hrr06h1006160110011001100110000h000h000h00000000000000000000000
0001000100010000000gg00gg000000100000000000000060606060h0066h33h933r060666060001000100010001000000000000000000000000000000000000
qqqqq2qqqqqqqqqrq200000000qqqqqrqqqqqqqrq2qqqqqrqq6qq66q6qq6h66000h00hqrhqqqq2qqqqqqq2qqqqqqqqqrq2qqqqqrqqqqqqqrq2qqqqqrppppppp2
rrrrrqrrrrrrrrr3r4rrrrr3rrrrrrr3rrrrrrr3r4rrrrr3rrrrrq6hrr6r66r6r66rhrr3r6r6r6r6rrrrrqrrrrrrrrr3r4rrrrr3rrrrrrr3r4rrrrr344444444
rrrrr3rrrrrrrrr333rrrr33rrrrrrr3rrrrrrr333rrrr33rrr6r3r6rr6r6rh6366r6r666rrrr3rrrrrrr3rrrrrrrrr333rrrr33rrrrrrr333rrrr3349444449
rrrr3rrr3r3rr933443rr3333r3rr9333r3rr933443rr333rrrr3rrr666rr9336hh6r363rrrr3rrrrrrr3rrr3r3rr933443rr3333r3rr933443rr33349944449
33333rrr333rr9334433333g333rr933333rr9334433333g33333rrr66hr66364633633633333r6r33333rrr333rr9334433333g333rr9334433333g49994449
99334433339999334999334g33999933339999334999334g99334433336699336969h34g6633443399334433339999334999334g339999334999334g49999449
9999999944499944g994344g4449994444499944g994344g99999999446996h66694364g669699999999999944499944g994344g44499944g994344g49999999
9999999944449944g944444g4444994444449944g944444g9999999944449944g964444g699969999999999944449944g944444g44449944g944444g44444444
gggggggggggggggggggggg9gggggggggggggggggggggggggggggg6gg6666g46g6ggggg6ggggggg9ggggggggggggggggggggggggggggggg9gggggggggggggg4gg
999ggggg4g9999ggggggg99ggggggggggggggggggggggggg4g9999ggg6g646g4ggggg6g6ggggg99g4g9999gg999gggggggggggggggggg99ggggggggggggg49g4
4991gggg44999ggg4444999ggggggggggggggggggggggggg44999gggggg696g4g6gggggg4444999g44999ggg4991gggggggggggg4444999gggggggggggg499g4
4491gggg4499gggg4449999ggggggggggggggggggggggggg4499gggggg4999g4gggggggg4449999g4499gggg4491gggggggggggg4449999ggggggggggg4999g4
44409ggg4494g9gg4499999ggggggggggggggggggggggggg4494g9ggg49999g46ggggg6g4499999g4494g9gg44409ggggggggggg4499999gggggggggg49999g4
444499gg444499gg4999999ggggggggggggggggggggggggg444499gg49969964gggggggg4999999g444499gg444499gggggggggg4999999ggggggggg499999g4
4444999g4449994g444ggggggggggggggggggggggggggggg4449994g999999g46ggggg6g444ggggg4449994g4444999ggggggggg444ggggggggggggg999999g4
gggg9999gggggggg44ggggggggggggggggggggggggggggggggggggggggggggggg6gggggg44gggggggggggggggggg9999gggggggg44gggggggggggggggggggggg

__gff__
0000000000000000000000000000000041414141010140404040404040400000010101010100000000000000424200000101010101404042424200000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020000000000000000000000000000000000000000000000000000000000000000818181810000808080808080808000000000000000000000000000008282000000000000008080828282000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1210111010111210111212101110111512101110101112101112141511101115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223203434342321342023223420342122232034343423213420232234203421000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3421342324223434233434242320223434213423242234342334342423202234000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000343400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010600001a3300f320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000634000330003101430011300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000100700a070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001f25018250162501140010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001a613256202163500000166431c65324640176350000000000106231e63018645000000000016643246331f62022635000000000000000066000f6001460000000000000000000000000000000000000
00020000176231e630186150000000000000001f6131a6301464500000000000a6000660019623166301d625156000f6000b6000a600000002563326630216501c64519635000000000000000216531f65023655
01020000166531f6531c650176551a65500000000001465319653156501b6551165500000000000000014653196531b65015655000000000000000136530f6501765500000000000000000000000000000000000
010200000625315253062531464306630132250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001425214262142751706417070170701307013072130720907209062090520905200000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001b5501d5502253028530285552f0002f0002e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000f75514755187551b755147552475511755167551a7551d75522755277551375500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018754187551c7501c7551d7501d75518755000001a7550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110002018755000001875500000187551c75500000187551875500000187551c755000001875500000187551c7551a755187550000000000000001875500000187551c75500000187551c755000001875500000
01100000187551a755187551c7551d3001d300147001c700187551a7550f75518755183001a3000c700207001a30012700183001a3001d300000001d30000000183001a3001d3000170000700027000370004700
0110001f120500c550000001c050120501c5001c5500c210120500c55000000120500c5500c5001c00000000120500c550000001c05012050000001c5500c210120500c550120000c550120200c5300000000000
010f00200c0430040000000000002b615000003e315000000c0430040000000000002b6153e31500000000000c0430040000000000002b6150c043000003e3150c0430040000000000002b615000003e31500000
001000200c0730000000000000000c0630000000000000000c0730000000000000000c0630000000000000000c0730000000000000000c0630000000000000000c0730000000000000000c063000000000000000
011000200214002130021200211002140021300212002110021400213002120021100214002130021100210002140021300212002110021400213002140021300214002130021200211002140021300211002100
011000000c0000000000000000000c0430000000000000000c0000000000000000000c0530000000000000000c0000000000000000000c0430000000000000000c0000000000000000000c053000000000000000
001000000c0730000000000000000c0630000000000000000c0730000000000000000c0630000000000000000c0730000000000000000c0630000000000000000c0730000000000000000c063000000000000000
01100000000000000000000135541355016550000001355413550165500000013554125521555215552155551155013550000000d5540d5520f5500f5500f5550000000000135001250015500000000000000000
011000000f75514755187551b755147552475511755167551a7551d75522755277551375500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000214002130021200211002140021300212002110021400213002120021100214002130021100214002130021100214002120021400213002120021100214002130021200211002140021300212002110
011000000214002130021200214002130021200214002120021400213002120021100214002130021200211002140021300212002140021300212002140021200214002130021200211002140021300212002110
011000000214002130021200211002140021300212002140021300212002140021300212000000021400213002120021400213002120021400213002140021300214002130021200211002140021300211000000
01100000237251a725237251a7251a7251a71500000000000000000000000001c7251d7251d7251c7251d715237251a725237251a7251a7251a7150000000000000001d7251c7251d7251f715000000000000000
011000001c7251e7251a7251e7251d7251e7251a72500000207251a725207251a725207250000000000000001c7251e7251a7251e7251d7251e7251a725000002372522725237252272523725000000000000000
__music__
01 17584344
01 1a185b44
00 1a1d5b44
00 1a182144
00 1a1e2044
00 1a182044
00 1a1e2144
00 1a1f2044
02 1a182044
00 41424344
00 41424344
03 13174344

