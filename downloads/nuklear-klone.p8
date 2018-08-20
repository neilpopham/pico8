pico-8 cartridge // http://www.pico-8.com
version 8

__lua__
-- nuklear klone
-- by freds72
local a=0
local b=0
local c={}
local d={}
local e={}
local f=0
local g=0
local h=1
local i
local j=64
local k=32
local l,m,n=0x1,0x2,0x0
local o={
['true']=true,
['false']=false}
function p() end
local q={
l=l,
m=m,
n=n,
p=p}
local r={['{']="}",['[']="]"}
local function s(t,u)
for v=1,#u do
if(t==sub(u,v,v)) return true
end
return false
end
local function w(x,y,z,ba)
if sub(x,y,y)!=z then
if(ba) assert('delimiter missing')
return y,false
end
return y+1,true
end
local function bb(x,y,bc)
bc=bc or''
if y>#x then
assert('end of input found while parsing string.')
end
local bd=sub(x,y,y)
if(bd=='"') return q[bc] or bc,y+1
return bb(x,y+1,bc..bd)
end
local function be(x,y,bc)
bc=bc or''
if y>#x then
assert('end of input found while parsing string.')
end
local bd=sub(x,y,y)
if(not s(bd,"-xb0123456789abcdef.")) return tonum(bc),y
return be(x,y+1,bc..bd)
end
function bf(x,y,bg)
y=y or 1
if(y>#x) assert('reached unexpected end of input.')
local bh=sub(x,y,y)
if s(bh,"{[") then
local bi,bj,bk={},true,true
y+=1
while true do
bj,y=bf(x,y,r[bh])
if(bj==nil) return bi,y
if bh=="{"then
y=w(x,y,':',true)
bi[bj],y=bf(x,y)
else
add(bi,bj)
end
y,bk=w(x,y,',')
end
elseif bh=='"'then
return bb(x,y+1)
elseif s(bh,"-0123456789") then
return be(x,y)
elseif bh==bg then
return nil,y+1
else
for bl,bm in pairs(o) do
local bn=y+#bl-1
if sub(x,y,bn)==bl then return bm,bn+1 end
end
end
end
local bo,bp,bq={},{}
local br
local bs={}
local bt,bu,bv=8
local bw=bf('[{"ob":[[17,18,19,18,17],[17,33,34,33]]},{"ob":[[49,50,51,50,49],[49,56,57,56]],"palt":3}]')
local bx=0
local by,bz,ca,cb=0,0
q.cc=function(self,cd,ce)
local cf=self.cf or 1
palt(0,false)
palt(self.palt or 14,true)
local t=self.cg and self.cg[flr(self.ch)%#self.cg+1] or self.spr
spr(t,cd-4*cf,ce-4*cf,cf,cf)
end
q.ci=function(self,cd,ce)
local t=self.cg and self.cg[flr(self.ch)%#self.cg+1] or self.spr
local cj,ck=band(t*8,127),8*flr(t/16)
cl(cj,ck,cd-4,ce-4,1-self.cm)
end
q.cn=function(self,cd,ce)
local co=1.5*#self.cp
print(self.cp,cd-co+1,ce-2,0)
print(self.cp,cd-co,ce-2,7)
end
q.cq=function(self,cd,ce)
local t=self.cg[flr(self.ch)+1]
cd-=8
ce-=8
palt(0,false)
palt(14,true)
spr(t,cd,ce,1,1)
spr(t,cd+8,ce,1,1,true)
spr(t,cd,ce+8,1,1,false,true)
spr(t,cd+8,ce+8,1,1,true,true)
palt()
end
q.cr=function(self)
if flr(self.ch)==#self.cg-1 then
return false
end
if self.ch==0 then
bx=8
cs(rnd(),rnd(),5)
end
self.ch=self.ch+0.25
if self.ch>2 then
for ct,cu in pairs(e) do
local cv,cw=mid(self.cd,cu.cd-cu.cx,cu.cd+cu.cx)-self.cd,mid(self.ce,cu.ce-cu.cy,cu.ce+cu.cy)-self.ce
if cu.cz<a and abs(cv)<2 and abs(cw)<2 then
local da=cv*cv+cw*cw
if da<4 then
da=1-db(da/4)
local dc,dd=de(cv,cw,0.5*da)
cu.cv+=dc
cu.cw+=dd
cu:df(flr(8*da)+1)
end
end
end
end
if self.ch==3 then
for v=1,8 do
local cu=rnd()
dg(self.cd,self.ce,0,br.dh,cos(cu)/8,sin(cu)/8)
end
di(self)
end
dj(self)
return true
end
q.dk=function(self)
if(self.dl<a or self.da<0) return false
if bor(self.cv,self.ce)!=0 then
if dm(self.cd+self.cv,self.ce) then
self.cv=-self.cv
end
if dm(self.cd,self.ce+self.cw) then
self.cw=-self.cw
end
end
self.cd+=self.cv
self.ce+=self.cw
self.dn+=self.dp
self.cv=dq(self.cv,self.dr)
self.cw=dq(self.cw,self.dr)
self.dp=dq(self.dp,self.dr)
self.da+=self.ds
self.ch+=self.dt
dj(self)
return true
end
q.du=function(self,cd,ce)
circfill(cd,ce,8*self.da,self.bd)
end
br=bf('{"part_cls":{"dr":1,"da":1,"ds":0,"ch":0,"dt":0.01,"hc":"du","jb":"dk"},"ig":{"hv":8,"da":0.8,"bd":7,"ds":-0.1},"blood_splat":{"hu":"chunk_base","spr":129},"head":{"hu":"chunk_base","spr":201},"turret_splat":{"hu":"chunk_base","spr":165,"cf":2,"no":2},"goo_splat":{"hu":"chunk_base","spr":130},"nk":{"cw":-0.05,"rnd":{"da":[0.05,0.2],"hv":[24,32],"bd":[11,3,true]}},"el":{"sfx":37,"ha":3,"cv":0,"cw":0.04,"bd":7,"rnd":{"da":[0.1,0.2],"hv":[24,32]}},"df":{"ds":-0.02,"rnd":{"da":[0.3,0.4],"hv":[8,12],"bd":[9,10,true]}},"dh":{"dr":0.95,"ds":-0.03,"rnd":{"da":[0.8,1.2],"hv":[15,30]},"bd":1},"slash":{"cg":[196,197,198],"hc":"ci","hv":12},"candle":{"cx":0.1,"cy":0.1,"dr":0.9,"rnd":{"bd":[8,9,10],"da":[0.1,0.2],"ds":[-0.01,-0.02],"dp":[0.04,0.06],"hv":[12,24]}},"hy":{"hu":"chunk_base","rnd":{"spr":[202,203,204]}},"goo_chunks":{"hu":"chunk_base","rnd":{"spr":[199,200,199]}},"green_chunks":{"hu":"chunk_base","rnd":{"spr":[215,216,215]}},"fireimp_chunks":{"hu":"chunk_base","rnd":{"spr":[219,220,220]}},"notice":{"ha":3,"dr":0.91,"hv":72,"hc":"cn"},"blast_splat":{"hu":"chunk_base","cg":[212,213,214],"dt":0.20},"blast_chunks":{"hu":"chunk_base","rnd":{"spr":[217,218,217]}},"blast":{"sfx":51,"cx":1,"cy":1,"hv":30,"ib":0,"dr":0,"cg":[192,193,208,209,194,195,210,211],"rnd":{"hx":[2,4]},"jb":"cr","hc":"cq","hw":"blast_splat","hy":"blast_chunks"},"chunk_base":{"ha":1,"dr":0.85,"da":1,"ds":0,"ch":0,"dt":0.01,"rnd":{"hv":[600,900]},"hc":"cc","jb":"dk"}}')
local dv={}
q.dw=function(self,cd,ce)
local dx,dy,dz,ea=cd,ce,eb(self.ec,self.ed)
local cv,cw=shr(dz-cd,2),shr(ea-ce,2)
for v=1,8 do
circfill(cd,ce,1,12)
cd+=cv
ce+=cw
end
line(dx,dy,cd,ce,7)
end
q.ee=function(self,cd,ce)
local dz,ea=eb(0,self.ea)
local cx=self.cx-2*rnd()
rectfill(cd-cx-2,ce+5,cd+cx+2,ea,2)
rectfill(cd-cx,ce+3,cd+cx,ea,8)
rectfill(cd-cx/4,ce,cd+cx/4,ea,7)
circfill(cd,ce,2*cx,7)
end
q.ef=function(self)
if self.dl>a then
if(not self.eg) self.eg=0
self.eg+=1
self.cx=eh(0.5,5,db(self.eg/54))
local dx,dy,ea=self.cd,self.ce,self.ea or self.ce
ea+=self.cw
if ei(bu.cd,bu.ce,bu.cx,dx,dy,dx,ea,self.cx/8) then
bu:df(self.ej.ek)
bu.cw+=self.cw/2
self.ea=bu.ce
dg(bu.cd,bu.ce,0.25,br.df,0,1.5*self.cw)
elseif not dm(dx,ea) then
self.ea=ea
end
dg(dx+self.cx*(rnd(2)-1)/16,eh(dy,self.ea,rnd()),0,br.el)
dj(self)
return true
end
return false
end
local em=bf('{"base_gun":{"sfx":55,"cg":[42],"ek":1,"iu":0.05,"dd":0.1,"ja":[90,100],"hv":32},"goo":{"cg":[63],"ek":1,"iu":1,"dd":0,"ja":[120,300],"hv":64,"ha":1},"acid_gun":{"sfx":49,"cg":[26,27],"is":3,"ie":0.9,"iu":0.2,"ek":3,"dd":0.1,"xy":[1,0],"ja":[160,200],"hv":24},"oc":{"il":"uzi","sfx":63,"la":21,"cj":32,"ck":8,"cg":[10,11],"iu":0.04,"ek":1,"dd":0.4,"ja":[15,24],"hv":5,"iv":75,"oh":2,"ep":1},"minigun":{"il":"minigun","sfx":55,"la":25,"cj":64,"ck":8,"cg":[10,11],"iu":0.04,"ek":2,"dd":0.45,"ja":[25,35],"hv":3,"iv":250,"oh":2,"ep":4},"shotgun":{"il":"pump","ho":"l","la":37,"cj":32,"ck":16,"cg":[10],"iu":0.05,"is":3,"ek":3,"dr":0.97,"dd":0.35,"ie":1,"ja":[32,48],"hv":56,"iv":33,"oh":2,"ep":3},"glock":{"il":"g.lock","la":53,"sfx":50,"cj":32,"ck":24,"cg":[10,11],"iu":0.01,"ek":4,"dd":0.5,"ja":[30,30],"hv":32,"iv":17,"oh":2,"ep":2},"rpg":{"il":"rpg","ek":0,"la":23,"cj":48,"ck":8,"spr":58,"iu":0.02,"dd":0.2,"dr":1.01,"ii":true,"ja":[32,48],"hv":72,"iv":8,"oh":3,"ep":5,"hc":"ci"},"grenade":{"il":"grenade","la":55,"cj":48,"ck":24,"ek":0,"cg":[44],"iu":0.02,"dd":0.2,"dr":0.98,"ie":1,"ii":true,"ja":[60,70],"hv":72,"iv":12,"oh":2.1,"ep":4},"ni":{"cj":48,"ck":8,"cg":[43,28],"sfx":52,"ek":5,"iu":0.05,"dd":0.1,"ja":[50,55],"hv":32,"ik":"mega_sub","im":5},"mega_sub":{"cj":48,"ck":8,"cg":[26,27],"ek":5,"iu":0,"dd":0.1,"ja":[900,900],"hv":12,"iq":4},"rifle":{"sfx":50,"cj":64,"ck":16,"cg":[10,11],"ek":5,"iu":0,"dd":0.5,"ja":[90,90],"hv":80,"my":true},"nh":{"ha":3,"sfx":36,"ek":0.5,"hv":60,"dd":1,"cv":0,"cw":1,"iu":0,"ja":[90,90],"hc":"ee","jb":"ef"},"bite":{"sfx":37,"ek":1,"hv":30,"iu":0.02,"dd":0.1,"hc":"p","ja":[4,4],"ij":"slash"},"snowball":{"cg":[60],"ek":1,"iu":0.01,"dd":0.5,"dr":0.9,"ja":[70,90],"hv":80},"horror_spwn":{"ix":"horror_cls","iu":1,"dd":0.2,"hv":145,"iv":5},"zapper":{"il":"laser","ep":5,"ho":"n","ie":1,"iv":30,"sfx":53,"cj":48,"ck":16,"la":39,"ek":5,"iu":0.01,"dd":0.6,"ja":[90,100],"hv":12,"hc":"dw"},"turret_minigun":{"sfx":55,"cg":[10,11],"iu":0.25,"ek":1,"dd":0.1,"ja":[60,80],"hv":8,"is":5},"radiation":{"cg":[12],"iu":0.1,"ek":3,"dd":0.1,"dr":0.985,"sfx":52,"is":3,"ja":[200,240],"hv":120},"cop_spwn":{"ix":"cop_cls","iu":1,"dd":0.1,"hv":145,"iv":4}}')
local en=-1
for eo,dd in pairs(em) do
q[eo]=dd
if dd.ep then
dv[dd.ep]=dv[dd.ep] or{}
en=max(en,add(dv[dd.ep],dd).ep)
end
end
local eq={}
function er(v)
return sget(88+2*flr(v/8)+1,24+v%8)
end
for v=0,15 do
local es=er(v)
for et=0,15 do
eq[bor(v,shl(et,4))]=bor(es,shl(er(et),4))
end
end
local eu=bf("[[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[27],[25],[24],[23],[22],[21],[20],[19],[19,28],[18,26],[17,25],[17,24],[16,23],[16,22],[15,22],[15,21,28],[15,20,27],[14,20,25],[14,19,25],[14,19,24],[13,18,23],[13,18,23],[13,18,22],[13,17,22],[12,17,21],[12,17,21],[12,16,20],[12,16,20],[12,16,20],[11,16,19],[11,16,19],[11,15,19],[11,15,19],[11,15,19],[11,15,19],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[10,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,18],[11,15,19],[11,15,19],[11,15,19],[11,15,19],[11,16,19],[11,16,19],[12,16,20],[12,16,20],[12,16,20],[12,17,21],[12,17,21],[13,17,22],[13,18,22],[13,18,23],[13,18,23],[14,19,24],[14,19,25],[14,20,25],[15,20,27],[15,21,28],[15,22],[16,22],[16,23],[17,24],[17,25],[18,26],[19,28],[19],[20],[21],[22],[23],[24],[25],[27],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[27],[25],[24],[22],[21],[21],[20],[19],[18,29],[18,27],[17,25],[17,24],[16,23],[16,22],[15,22],[15,21,29],[14,20,27],[14,20,26],[14,19,25],[13,19,24],[13,18,23],[13,18,23],[12,18,22],[12,17,22],[12,17,21],[12,17,21],[12,16,20],[11,16,20],[11,16,20],[11,16,19],[11,15,19],[11,15,19],[11,15,19],[10,15,18],[10,15,18],[10,15,18],[10,15,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,15,18],[10,15,18],[10,15,18],[10,15,18],[11,15,19],[11,15,19],[11,15,19],[11,16,19],[11,16,20],[11,16,20],[12,16,20],[12,17,21],[12,17,21],[12,17,22],[12,18,22],[13,18,23],[13,18,23],[13,19,24],[14,19,25],[14,20,26],[14,20,27],[15,21,29],[15,22],[16,22],[16,23],[17,24],[17,25],[18,27],[18,29],[19],[20],[21],[21],[22],[24],[25],[27],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[27],[25],[24],[22],[21],[20],[20],[19],[18,30],[18,27],[17,25],[16,24],[16,23],[15,22],[15,22],[15,21,30],[14,20,28],[14,20,26],[13,19,25],[13,19,24],[13,18,23],[12,18,23],[12,17,22],[12,17,22],[12,17,21],[11,16,21],[11,16,20],[11,16,20],[11,16,20],[11,15,19],[10,15,19],[10,15,19],[10,15,19],[10,15,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,17],[10,14,17],[9,14,17],[10,14,17],[10,14,17],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,14,18],[10,15,18],[10,15,19],[10,15,19],[10,15,19],[11,15,19],[11,16,20],[11,16,20],[11,16,20],[11,16,21],[12,17,21],[12,17,22],[12,17,22],[12,18,23],[13,18,23],[13,19,24],[13,19,25],[14,20,26],[14,20,28],[15,21,30],[15,22],[15,22],[16,23],[16,24],[17,25],[18,27],[18,30],[19],[20],[20],[21],[22],[24],[25],[27],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]]")
q.ev=function()
local ew,da=0x6000,flr(rnd(#eu))+1
for ce=1,128 do
local co=eu[da][ce]
local dx,dz,ex=co[1] or 31,co[2] or 31,co[3] or 31
memset(ew,0,dx+1)
memset(ew+63-dx,0,dx+1)
for cd=dx+1,dz do
poke(ew+cd,eq[eq[peek(ew+cd)]])
poke(ew+63-cd,eq[eq[peek(ew+63-cd)]])
end
for cd=dz+1,ex do
poke(ew+cd,eq[peek(ew+cd)])
poke(ew+63-cd,eq[peek(ew+63-cd)])
end
ew+=64
end
end
local ey
local ez=bf('[{"ki":[68,64,65,67,111],"jv":[66],"jt":110,"ol":1,"cx":[8,12],"cy":[6,8],"jz":[1,3],"kd":{"cx":[3,4],"ke":[8,12]},"jk":[[8,12,"bandit_cls"],[5,8,"worm_cls"],[-5,-3,"scorpion_cls"],[2,3,"cactus"],[-9,-5,"cop_box_cls"]]},{"on":"ev","ki":[86,87,87,88],"jv":[90,89,91],"jt":94,"om":[10,11,3],"ol":3,"cx":[2,3],"cy":[2,3],"jz":[2,4],"kd":{"cx":[1,2],"ke":[10,12]},"jk":[[10,15,"slime_cls"],[5,10,"barrel_cls"],[-4,-2,"frog_cls"]]},{"cursor":93,"ki":[70,71,72,75],"jv":[74],"jt":95,"om":[5,1,7],"ol":7,"cx":[6,8],"cy":[5,6],"jz":[2,3],"kd":{"cx":[3,5],"ke":[10,12]},"jk":[[8,10,"dog_cls"],[5,8,"bear_cls"],[-2,-1,"turret_cls"]]},{"ki":[102,105],"jv":[103,104,106],"jt":107,"om":[6,7,5],"ol":5,"on":"ev","cx":[4,6],"cy":[3,5],"jz":[1,4],"kd":{"cx":[1,2],"ke":[8,12]},"jk":[[3,4,"cop_cls"],[5,8,"fireimp_cls"],[5,8,"barrel_cls"]]},{"ki":[96,100],"jv":[97,98,99,108],"jt":101,"om":[7,0,5],"ol":5,"cx":[8,10],"cy":[8,10],"jz":[1,3],"kd":{"cx":[2,3],"ke":[10,12]},"jk":[[4,8,"horror_cls"],[4,4,"horror_spwnr_cls"],[-4,-2,"slime_cls"],[2,3,"candle_cls"]]},{"music":0,"jj":true,"ol":0,"om":[7,0,5],"jn":103,"jo":0,"kg":13,"kh":31,"oj":[110,28],"jk":[{"cu":"throne_cls","cd":112,"ce":6},{"cu":"lb","cd":106,"ce":27},{"cu":"lb","cd":107,"ce":27},{"cu":"lb","cd":106,"ce":28},{"cu":"lb","cd":107,"ce":28},{"cu":"ld","cd":114,"ce":27},{"cu":"ld","cd":115,"ce":27},{"cu":"ld","cd":114,"ce":28},{"cu":"ld","cd":115,"ce":28}]}]')
local fa=bf('[false,false,false,true,true,true,false,false]')
function fb(fc)
fc=fc or c
for ct,fd in pairs(fc) do
if not coresume(fd) then
del(fc,fd)
end
end
end
function fe(ff,fc)
return add(fc or c,cocreate(ff))
end
local fg=bf("[[-1,0],[0,-1],[0,1],[-1,-1],[1,1],[-1,1],[1,-1]]")
local fh,fi,fj=false,-1,false
function fk(bd,t,fl)
fh=bd or false
fi=t or-1
fj=fl or false
end
function fm(x,cd,ce,fn)
if fh then
cd-=flr((4*#x)/2+0.5)
end
if fi!=-1 then
print(x,cd+1,ce,fi)
if fj then
for ct,dd in pairs(fg) do
print(x,cd+dd[1],ce+dd[2],fi)
end
end
end
print(x,cd,ce,fn)
end
function fo(cu)
if#cu>0 then
local fp=cu[#cu]
cu[#cu]=nil
return fp
end
end
function fq(cu,ff)
for ct,dd in pairs(cu) do
if not dd[ff](dd) then
del(cu,dd)
end
end
end
function fr(fs,ft)
ft=ft or{}
for eo,dd in pairs(fs) do
if(not ft[eo]) ft[eo]=dd
end
if fs.rnd then
for eo,dd in pairs(fs.rnd) do
if not ft[eo] then
ft[eo]=dd[3] and fu(dd) or fv(dd[1],dd[2])
end
end
end
return ft
end
function dq(cd,cv)
cd*=cv
return abs(cd)<0.001 and 0 or cd
end
function eh(cu,fl,dl)
return cu*(1-dl)+fl*dl
end
function fv(cu,fl)
return eh(fl,cu,1-rnd())
end
function db(dl)
dl=mid(dl,0,1)
return dl*dl*(3-2*dl)
end
function fw(fx)
return flr(fv(fx[1],fx[2]))
end
function fu(cu)
return cu[flr(rnd(#cu))+1]
end
function fy(cu,fp)
local bd,t=cos(cu),-sin(cu)
return{fp[1]*bd-fp[2]*t,fp[1]*t+fp[2]*bd}
end
function cl(cj,ck,cd,ce,cu)
local fz,ga=cos(cu),sin(cu)
local gb,gc,gd,ge=fz,ga
fz*=4
ga*=4
local gf,gg,bd=ga-fz+4,-fz-ga+4
for gh=0,7 do
gd,ge=gf,gg
for gi=0,7 do
if band(bor(gd,ge),0xfff8)==0 then
bd=sget(cj+gd,ck+ge)
if bd!=14 then
pset(cd+gh,ce+gi,bd)
end
end
gd-=gc
ge+=gb
end
gf+=gb
gg+=gc
end
end
function gj(dx,dy,dz,ea)
local cv,cw=dz-dx,ea-dy
if abs(cv)>128 or abs(cw)>128 then
return 32000
end
return cv*cv+cw*cw
end
function de(dc,dd,gk)
gk=gk or 1
local gl=sqrt(dc*dc+dd*dd)
if(gl>0) dc/=gl dd/=gl
return dc*gk,dd*gk
end
function gm(dl,ff)
local v=1
while v<=dl do
if ff then
if not ff(v) then
return
end
end
v+=b
yield()
end
end
function ei(cd,ce,da,dx,dy,dz,ea,cx)
local cv,cw=dz-dx,ea-dy
local gn,go=cd-dx,ce-dy
local dl,gl=gn*cv+go*cw,cv*cv+cw*cw
if gl==0 then
dl=0
else
dl=mid(dl,0,gl)
dl/=gl
end
local gh,gi=dx+dl*cv-cd,dy+dl*cw-ce
da+=(cx or 0.2)
return gh*gh+gi*gi<da*da
end
local gp={}
function gq()
gp={}
end
function dj(bi)
add(gp,bi)
end
function gr()
local gs={{},{},{}}
local gt,gu,gv={},256,-128
for ct,bi in pairs(gp) do
local gw,gx=eb(bi.cd,bi.ce)
local gy=bi.dn and 8*bi.dn or 0
local gz=bi.ha or 2
bi=add(gs[gz],{bi=bi,cd=gw,ce=gx-gy,bj=gx+gy})
if gz==2 then
local dn=flr(bi.bj)
gu,gv=min(gu,dn),max(gv,dn)
local hb=gt[dn] or{}
add(hb,bi)
gt[dn]=hb
end
end
for ct,dd in pairs(gs[1]) do
dd.bi:hc(dd.cd,dd.ce)
end
for v=max(-16,gu),min(144,gv) do
local hb=gt[v]
if hb then
for ct,dd in pairs(hb) do
dd.bi:hc(dd.cd,dd.ce)
end
end
end
for ct,dd in pairs(gs[3]) do
dd.bi:hc(dd.cd,dd.ce)
end
end
local hd={}
local he=bf('[0,1,129,128,127,-1,-129,-128,-127]')
function hf(bi,ff)
if bor(bi.cx,bi.cy)!=0 then
for cd=flr(bi.cd-bi.cx),flr(bi.cd+bi.cx) do
for ce=flr(bi.ce-bi.cy),flr(bi.ce+bi.cy) do
ff(bi,hd,cd+128*ce)
end
end
end
end
function hg(bi,hd,cy)
hd[cy]=hd[cy] or{}
add(hd[cy],bi)
end
function hh(bi,hd,cy)
if hd[cy] then
del(hd[cy],bi)
if#hd[cy]==0 then
hd[cy]=nil
end
end
end
local hi,hj,hk,hl,hm=0
function hn(cd,ce,ho)
hj,hk,hm=1,1,ho or n
hl=flr(cd)+128*flr(ce)
hi+=1
end
function hp()
while(hk<=9) do
local cy=hl+he[hk]
local hq=hd[cy]
if hq and hj<=#hq then
local bi=hq[hj]
hj+=1
if bi.hi!=hi and band(bi.ho,hm)==0 then
return bi
end
bi.hi=hi
end
hj=1
hk+=1
end
return nil
end
function cs(dc,dd,hr)
by,bz=min(4,by+hr*dc),min(4,bz+hr*dd)
end
function hs()
by*=-0.7-rnd(0.2)
bz*=-0.7-rnd(0.2)
if abs(by)<0.5 and abs(bz)<0.5 then
by,bz=0,0
end
camera(by,bz)
end
function ht(cd,ce)
ca,cb=flr(8*cd)-4,flr(8*ce)-4
end
function eb(cd,ce)
return 64+8*cd-ca,64+8*ce-cb
end
function dg(cd,ce,dn,fs,cv,cw,dp,cu)
local fp=fr(br[fs.hu or"part_cls"],
fr(fs,{
cd=cd,
ce=ce,
dn=dn,
cv=cv or 0,
cw=cw or 0,
dp=dp or 0,
cm=cu or 0}))
if(fp.sfx) sfx(fp.sfx)
fp.dl=a+fp.hv
return add(bs,fp)
end
function di(self)
dg(self.cd,self.ce,0,br[self.hw or"blood_splat"])
for v=1,self.hx do
local cu=rnd()
dg(self.cd+fv(-self.cx,self.cx),self.ce+fv(-self.cy,self.cy),0,br[self.hy or"hy"],cos(cu)/10+self.cv,sin(cu)/10+self.cw,0,cu)
end
end
function hz(fp,cd,ce)
local cv,cw=fp.dc,fp.dd
line(cd+2*cv,ce+2*cw,cd+80*cv,ce+80*cw,8)
end
function ia(self)
local dz,ea=self.cd,self.ce
if self.dl>a then
local dx,dy=self.cd,self.ce
dz,ea=dx+self.cv,dy+self.cw
if self.ej.dr then
self.cv*=self.ej.dr
self.cw*=self.ej.dr
end
hn(dz,ea,self.ho)
local cu=hp()
while cu do
if ei(cu.cd,cu.ce,cu.cx,dx,dy,dz,ea) then
if cu.ib!=0 then
cu.cv+=self.cv
cu.cw+=self.cw
end
cu:df(self.ej.ek+h-1)
goto ic
end
cu=hp()
end
local id,ie=false,self.ie or 0
if dm(dz,dy) then
dz=dx
self.cv*=-ie
self.dc=-self.dc
id=true
end
if dm(dx,ea) then
ea=dy
self.cw*=-ie
self.dd=-self.dd
id=true
end
if id then
if self.ie then
self.ho=self.ej.ho
dg(dz,ea,0.25,br.ig)
sfx(self.ej.ih or 58)
else
goto ic
end
end
self.ec,self.ed,self.cd,self.ce=dx,dy,dz,ea
dj(self)
return true
end
::ic::
if self.ej.ii then
dg(dz,ea,0,br["blast"])
else
dg(dz,ea,0.25,br[self.ej.ij or"df"],self.cv/4,self.cw/4,0,self.cm)
end
local ej=self.ej.ik
if ej then
ej=em[ej]
local ho,il=self.ho,self.ej.im
fe(function()
local io,ip=0,1/il
for eo=1,ej.iq do
io=0
for v=1,il do
ir({
cd=dz,ce=ea,
ho=ho,
cm=io},ej)
io+=ip
end
gm(ej.hv)
end
end)
end
return false
end
function ir(cu,ej)
local il=ej.is or 1
local io,it
if il==1 then
io,it=cu.cm+ej.iu*(rnd(2)-1),0
else
io,it=cu.cm-ej.iu/il,ej.iu/il
end
for v=1,il do
if cu.iv then
if cu==bu and cu.iv<=0 then
sfx(57)
return
end
cu.iv-=1
end
if ej.sfx then
sfx(ej.sfx)
end
local dc,dd=cos(io),sin(io)
local cd,ce=cu.cd+0.5*dc,cu.ce+0.5*dd
local fl={
dc=dc,dd=dd,
cv=ej.dd*dc,cw=ej.dd*dd,
ho=cu.ho,
cm=io,
iw=flr(8*(io%1))
}
if ej.ix then
iy(cd,ce,
fr(iz[ej.ix],fl))
else
fr({
cd=cd,ce=ce,
ej=ej,
ie=ej.ie,
ha=ej.ha,
ho=cu.ho,
dl=a+eh(ej.ja[1],ej.ja[2],rnd()),
ec=fl.cd,ed=fl.ce,
spr=ej.spr,
jb=ej.jb or ia,
hc=ej.hc or jc},fl)
add(bs,fl)
end
if(v==1) dg(cd,ce+0.5,0.5,br.ig)
io+=it
end
end
function jc(fl,cd,ce)
palt(0,false)
palt(14,true)
local cg=fl.ej.cg
if#cg==2 then
local jd,je=cd-2*fl.dc,ce-2*fl.dd
spr(cg[2],jd-4,je-4)
end
spr(cg[1],cd-4,ce-4)
end
local jf,jg
local jh=bf('[[0,0],[1,0],[0,1],[-1,0],[0,-1]]')
function ji()
ey=0
i=ez[g]
if i.jj then
for t in all(i.jk) do
iy(t.cd,t.ce,iz[t.cu])
end
else
while jl()<7 do
end
for jm in all(i.jk) do
local il=min(fw(jm)+h*h,15)
for v=1,il do
local da=jf[flr(rnd()*#jf)+1]
local cd,ce=da.cd+fv(1,da.cx-1),da.ce+fv(1,da.cy-1)
iy(cd,ce,iz[jm[3]])
end
end
end
end
function jl()
jf={}
jg={}
for v=0,k-1 do
memset(0x2000+v*128,127,j-1)
end
local jn,jo=j/2,k/2
jp(
jn,jo,0,13)
jq(0,j-1,0,k-2,true)
return#jf
end
function jr(cu)
return jg[flr(cu.cd)+shl(flr(cu.ce),8)] or 1
end
function js(jn,jo)
local bd=0
for v=0,#jh-1 do
local fp=jh[v+1]
local t=mget(jn+fp[1],jo+fp[2])
if t==0 or fget(t,7) then
bd=bor(bd,shl(1,v))
end
end
return bd
end
function jq(dx,dz,dy,ea,jt)
local ju,dl
local jv={}
for v=dx,dz do
for et=dy,ea do
ju=js(v,et)
if band(ju,1)!=0 then
ju=shr(band(ju,0xfffe),1)
dl=112+ju
mset(v,et,dl)
if band(ju,0x2)==0 then
if rnd()<0.8 then
dl=i.jv[1]
else
dl=fu(i.jv)
end
add(jv,{v,et+1,dl})
end
end
end
end
for cx in all(jv) do
mset(cx[1],cx[2],cx[3])
if(jt) mset(cx[1],cx[2]+1,i.jt)
end
end
function jp(cd,ce,cu,ja)
if(ja<0) return
if rnd()>0.5 then
local jw=fy(cu,{fw(i.cx),fw(i.cy)})
local da={
cd=cd-jw[1]/2,ce=ce-jw[2]/2,
cx=jw[1],cy=jw[2]}
da=jx(da,#jf+1)
if da then
add(jf,da)
end
end
local il,jy=fw(i.jz),flr(rnd(3))
local ka={-0.25,0,0.25}
for v=1,il do
local kb=cu+ka[(jy+v)%#ka+1]
kc(cd,ce,kb,ja-1)
end
end
function kc(cd,ce,cu,ja)
local jw=fy(cu,{fw(i.kd.ke),
fw(i.kd.cx)})
local bd={
cd=cd,ce=ce,
cx=jw[1],cy=jw[2]}
bd=jx(bd)
if bd then
local dc=fy(cu,{1,0})
jp(
cd+dc[1]*bd.cx,ce+dc[2]*bd.cy,
cu,ja-1)
end
end
function jx(da,kf)
local kg,kh=j-2,k-3
local dx,dy=mid(da.cd,1,kg),mid(da.ce,1,kh)
local dz,ea=mid(da.cd+da.cx,1,kg),mid(da.ce+da.cy,1,kh)
dx,dz=flr(min(dx,dz)),flr(max(dx,dz))
dy,ea=flr(min(dy,ea)),flr(max(dy,ea))
kg,kh=dz-dx,ea-dy
if kg>0 and kh>0 then
for v=dx,dz do
for et=dy,ea do
if rnd()<0.9 then
mset(v,et,i.ki[1])
else
mset(v,et,fu(i.ki))
end
if(kf) jg[v+shl(et,8)]=kf
end
end
return{cd=dx,ce=dy,cx=kg,cy=kh}
end
end
function dm(cd,ce)
return fget(mget(cd,ce),7)
end
function kj(cu,cv,cw)
local cd,ce,cx,cy=cu.cd+cv,cu.ce+cw,cu.cx,cu.cy
return
dm(cd-cx,ce-cy) or
dm(cd+cx,ce-cy) or
dm(cd-cx,ce+cy) or
dm(cd+cx,ce+cy)
end
function kk(dz,ea,ex,kl,km)
dz,ea=flr(dz),flr(ea)
ex,kl=flr(ex),flr(kl)
local cv=ex-dz
local gh=cv>0 and 1 or-1
cv=shl(abs(cv),1)
local cw=kl-ea
local gi=cw>0 and 1 or-1
cw=shl(abs(cw),1)
if(cv==0 and cw==0) return true,0
if cv>=cw then
kn=cw-cv/2
while dz!=ex do
if(kn>0) or(kn==0 and gh>0) then
kn-=cv
ea+=gi
end
kn+=cw
dz+=gh
km-=1
if(km<0) return false,-1
if(dm(dz,ea)) return false,km
end
else
kn=cv-cw/2
while ea!=kl do
if(kn>0) or(kn==0 and gi>0) then
kn-=cw
dz+=gh
end
kn+=cv
ea+=gi
km-=1
if(km<0) return false,-1
if(dm(dz,ea)) return false,km
end
end
return true,km
end
function ko(cu,cv,cw)
hn(cu.cd+cv,cu.ce+cw,cu.cx,cu.cx)
local kp=hp()
while kp do
if kp!=cu then
local cd,ce=(cu.cd+cv)-kp.cd,(cu.ce+cw)-kp.ce
if abs(cd)<(cu.cx+kp.cx)/2 and
abs(ce)<(cu.cy+kp.cy)/2
then
if kp.ek and cu.kq<a and band(cu.ho,kp.ho)==0 then
cu.kq=a+30
cu:df(kp.ek)
end
if cv!=0 and abs(cd)<
abs(cu.cd-kp.cd) then
local dd=cu.cv+kp.cw
cu.cv=dd/2
kp.cv=dd/2
return true
end
if cw!=0 and abs(ce)<
abs(cu.ce-kp.ce) then
local dd=cu.cw+kp.cw
cu.cw=dd/2
kp.cw=dd/2
return true
end
end
end
kp=hp()
end
return false
end
function kr(cu,cv,cw)
return kj(cu,cv,cw) or ko(cu,cv,cw)
end
local ks=0
function kt()
return btnp(4) or btnp(5)
end
function ku(self)
di(self)
fe(function()
bv=false
local dl=0
while not kt() do
local et=48*db(dl/90)
rectfill(0,0,127,et,0)
rectfill(0,127,127,128-et,0)
if dl==90 then
fk(true,2,true)
fm("game over",64,32,14)
fm(h.."-"..g,64,96,14)
end
dl=min(dl+b,90)
yield()
end
bq=bp
end,d)
end
q.kv=function(self)
di(self)
if self.kw then
ey-=1
if ey==0 then
iy(self.cd,self.ce,iz.kx)
return
end
local da=rnd()
if da>0.7 then
local ej=fu(dv[flr(rnd(min(en,g+h)))+1])
iy(self.cd,self.ce,
fr(iz.ky,{
kz=ej,
iv=ej.iv,
spr=ej.la,
cp=ej.il}))
elseif da>0.6 or bu.iv<2 then
iy(self.cd,self.ce,iz.lb)
elseif da>0.4 and bu.lc!=bt then
iy(self.cd,self.ce,iz.ld)
end
end
end
q.le=function(self,ek)
self.cz=a+8
self.lc-=ek
sfx(61)
if not self.lf and flr(self.lc)<=0 then
self.lf=true
self:ic()
hf(self,hh)
del(e,self)
end
end
local lg=bf('[[1,0],[0,1],[-1,0],[0,-1]]')
function lh(cd,ce,li)
local lj,lk=32000
for ct,dd in pairs(li) do
local ll=gj(dd.cd,dd.ce,cd,ce)
if ll<lj then
lk,lj=dd,ll
end
end
return lk
end
function lm(self)
::lr::
while self.lc>0 do
local dz,ea
if self.ln then
local lo,lp=jr(bu),jr(self)
local da=jf[flr(16*lo+8*lp+self.lq)%#jf+1]
dz,ea=fv(da.cd,da.cd+da.cx),fv(da.ce,da.ce+da.cy)
else
dz,ea=bu.cd,bu.ce
if gj(dz,ea,self.cd,self.ce)>96 then
yield()
goto lr
end
end
local cd,ce=self.cd,self.ce
local eo,lt=flr(cd)+96*flr(ce),flr(dz)+96*flr(ea)
local lu,lv={[eo]={cd=cd,ce=ce,eo=eo}},1
local lw,lx,ly={},{}
while lv>0 and lv<24 do
ly=lh(dz,ea,lu)
cd,ce,eo=ly.cd,ly.ce,ly.eo
if(eo==lt) break
lu[eo],lw[eo]=nil,true
lv-=1
for ct,gl in pairs(lg) do
local lz,ma=cd,ce
if not kj({cd=lz,ce=ma,cx=self.cx,cy=self.cy},gl[1],gl[2]) then
lz+=gl[1]
ma+=gl[2]
end
eo=flr(lz)+96*flr(ma)
if not lw[eo] and not lx[eo] then
lu[eo],lx[eo]={cd=lz,ce=ma,eo=eo},ly
lv+=1
end
end
end
local kd,mb={},ly
while ly do
add(kd,ly)
mb,ly=ly,lx[ly.eo]
end
self.kd=kd
local dl=a+self.mc
while#self.kd>0 do
if(dl<a) break
yield()
end
self.md=nil
end
end
function me(mf,mg)
gm(90,function(v)
local da=eh(mf,mg,1-db(v/90))
local mh=da*da
for et=0,127 do
local ce=64-et
local cd=sqrt(max(mh-ce*ce))
rectfill(0,et,64-cd,et,0)
rectfill(64+cd,et,127,et,0)
end
return true
end)
end
q.mi=function(self)
self.ch+=0.25
if(self.mj) return
local cv,cw=bu.cd-self.cd,bu.ce-self.ce
local gl=cv*cv+cw*cw
if gl<4 then
self.mj=true
fe(function()
me(16,96)
me(96,16)
end,d)
fe(function()
bv,gl,cu=false,sqrt(gl),atan2(cv,cw)
gm(90,function(v)
local km=eh(gl,0,v/90)
bu.cd,bu.ce=self.cd+km*cos(cu),self.ce+km*sin(cu)
cu+=0.1
return true
end)
bv=true
mk()
end)
end
end
q.ml=function(self)
if gj(bu.cd,bu.ce,self.cd,self.ce)<1 then
bu.lc=min(bt,bu.lc+2)
dg(self.cd,self.ce,0,br["notice"]).cp="heal!"
sfx(60)
del(e,self)
end
end
q.mm=function(self)
if gj(bu.cd,bu.ce,self.cd,self.ce)<1 then
local mn=flr(bu.ej.iv/2)
bu.iv=min(bu.ej.iv,bu.iv+mn)
dg(self.cd,self.ce,0,br["notice"]).cp="ammo!"
sfx(59)
del(e,self)
end
end
q.mo=function(self)
if(self.cz>a) return
if self.mp<a and#self.kd>0 then
local md=self.md
if not md or gj(self.cd,self.ce,md.cd,md.ce)<0.25 then
md=fo(self.kd)
self.md=md
end
if md then
local dc,dd=de(md.cd-self.cd,md.ce-self.ce,0.8*self.ib)
self.cv+=dc
self.cw+=dd
end
end
if self.lq==(a%ks) then
assert(coresume(self.mq,self))
end
if self.mr and self.ms<a then
self.mt=a+self.mr
self.ms=a+self.mr+self.mu
end
if self.ej and self.mv<a and self.mt<a then
self.mw=false
if kk(self.cd,self.ce,bu.cd,bu.ce,self.mx) then
local cv,cw=bu.cd-self.cd,bu.ce-self.ce
self.cm=atan2(cv,cw)%1
self.iw,self.mw=flr(8*self.cm),true
if self.ej.my then
self.mp,self.mt=a+45,a+30
if abs(cv)>0 and abs(cw)>0 then
cv,cw=de(cv,cw)
dg(self.cd,self.ce,0,{
dc=cv,dd=cw,
hv=30,
ha=3,
hc=hz
})
end
end
end
self.mv=a+self.ej.hv
end
if self.mw and self.mt<a then
ir(self,self.ej)
self.mt=a+self.ej.hv
end
end
q.mz=function(self,cd,ce)
local io=atan2(self.cv,self.cw)
cl(self.cj,self.ck,cd-4,ce-4,1-io)
end
q.na=function(self,cd,ce)
q.nb(self,cd,ce)
if self.nc>a then
q.cn(self,cd,ce-8)
end
end
q.nd=function(self)
if self.ne<a and gj(bu.cd,bu.ce,self.cd,self.ce)<4 then
self.nc=a+30
if btnp(5) or stat(34)==2 then
dg(self.cd,self.ce,0,br["notice"]).cp=self.cp
local ej,io=bu.ej,rnd()
iy(bu.cd,bu.ce,
fr(iz.ky,{
ne=a+30,
cv=0.2*cos(io),
cw=0.2*sin(io),
kz=ej,
iv=bu.iv,
spr=ej.la,
cp=ej.il}))
bu.ej=self.kz
bu.iv=self.iv
del(e,self)
end
end
end
q.nf=function(self)
self.cm=0.75
local ng=function()
return bu.lc>0 and self.lc>0
end
fe(function()
local lc=self.lc
while(abs(bu.ce-self.ce)>4 and lc==self.lc) do
yield()
end
gm(60,ng)
if not ng() then
return
end
ir(self,em.nh)
gm(60,ng)
local co=1
while ng() do
gm(90,ng)
if co%4==0 then
ir(self,em.nh)
else
local cv,cw=bu.cd-self.cd,bu.ce-self.ce
local cu,cm=eh(0,0.2,abs(cos(a/16))),atan2(cv,cw)%1
ir({cd=self.cd-2,ce=self.ce+1,cm=cm-cu,ho=m},em.ni)
ir({cd=self.cd+2,ce=self.ce+1,cm=cm+cu,ho=m},em.ni)
end
gm(20,function()
hf(self,hh)
self.ce+=0.025
hf(self,hg)
return ng()
end)
if self.ce>25 then
bu:df(bt)
break
end
co+=1
end
end)
end
q.nj=function(self)
local io=rnd()
local dc,dd=0.16*cos(io),0.15*sin(io)
dg(self.cd+dc,self.ce+dd-0.5,0,br.nk)
end
q.nl=function(cu,cd,ce)
cd,ce=cd-4*cu.kg,ce-4*cu.kh
palt(0,false)
rectfill(cd,ce+4,cd+8*cu.kg,ce+4+8*cu.kh,1)
local nm=cu.palt or 14
if cu.cz>a then
memset(0x5f00,0xf,16)
pal(nm,nm)
end
palt(nm,true)
map(cu.jn,cu.jo,cd,ce,cu.kg,cu.kh)
palt(nm,false)
pal()
palt(0,false)
end
q.nb=function(cu,cj,ck)
if cu.nn and cu.nn>a and band(a,1)==0 then
return
end
local cf,no=max(1,flr(2*cu.cx+0.5)),max(1,flr(2*cu.cy+0.5))
cj,ck=cj-4*cf,ck-4*no
palt(14,true)
sspr(0,8,8,8,cj,ck+7*no,8*cf,8)
palt(14,false)
local nm=cu.palt or 14
if cu.cz>a then
memset(0x5f00,0xf,16)
pal(nm,nm)
end
local t,np=cu.spr,false
if cu.cg then
np=fa[cu.iw+1]
t=cu.cg[flr(cu.ch%#cu.cg)+1]
end
palt(0,false)
palt(nm,true)
spr(t,cj,ck,cf,no,np,nq)
palt(nm,false)
pal()
local ej=cu.ej
if ej and ej.cj then
palt(14,true)
local dc,dd=cos(cu.cm),sin(cu.cm)
local fd=-mid(cu.mt-a,0,8)/4
cl(ej.cj,ej.ck,cj+4*dc+fd*dc,ck+4*dd+fd*dd,1-cu.cm)
palt()
end
end
iz=bf('{"ix":{"cv":0,"cw":0,"ib":0.02,"ch":0,"dr":0.6,"ie":1,"lc":1,"kq":0,"kd":[],"mp":0,"rnd":{"mc":[120,180],"mv":[50,80],"hx":[2,4]},"cz":0,"mw":false,"mt":0,"ms":0,"cx":0.4,"cy":0.4,"mx":8,"cm":0,"iw":0,"ho":"m","hc":"nb","df":"le","jb":"mo","ic":"kv"},"barrel_cls":{"ho":"n","spr":128,"dr":0.7,"hw":"blast","hy":"green_chunks","jb":"p"},"bandit_cls":{"lc":3,"ej":"base_gun","cg":[4,5,6],"ek":1,"kw":true,"rnd":{"mu":[90,120],"mr":[90,120]}},"scorpion_cls":{"rnd":{"mu":[180,220]},"ib":0.01,"ek":2,"mr":120,"cx":0.8,"cy":0.8,"lc":10,"ej":"acid_gun","palt":5,"cg":[131,133],"kw":true},"worm_cls":{"hx":0,"ln":true,"palt":3,"cx":0.2,"cy":0.2,"dr":0.8,"ek":1,"cg":[7,8],"kw":true},"slime_cls":{"cx":0.2,"cy":0.2,"ib":0.02,"dr":0.75,"ek":2,"cg":[31,29,30,29],"ej":"goo","kw":true,"hw":"goo_splat","hy":"goo_chunks"},"dog_cls":{"mx":1,"dr":0.2,"lc":5,"ib":0.06,"ej":"bite","cg":[61,62],"kw":true},"bear_cls":{"lc":8,"ln":true,"dr":0.2,"cg":[1,2,3],"ek":1,"kw":true,"ej":"snowball"},"throne_cls":{"ha":1,"cx":6,"cy":2,"lc":75,"palt":15,"dr":0,"ib":0,"jn":87,"jo":18,"kg":12,"kh":5,"jb":"nj","hc":"nl","nr":"nf","hw":"blast","hy":"blast","rnd":{"hx":[10,20]},"kw":true},"ld":{"spr":48,"cx":0,"cy":0,"jb":"ml","df":"p"},"lb":{"spr":32,"cx":0,"cy":0,"jb":"mm","df":"p"},"ky":{"cx":0,"cy":0,"ne":0,"nc":0,"hc":"na","jb":"nd","df":"p"},"cop_cls":{"lc":8,"ln":true,"ib":0.05,"cg":[13,14,15,14],"rnd":{"mu":[160,210],"mr":[120,160]},"ej":"rifle","kw":true},"fireimp_cls":{"lc":5,"ek":1,"cg":[45,46,47,46],"ib":0.05,"kw":true,"hw":"blast","hy":"fireimp_chunks"},"turret_cls":{"cx":1,"cy":1,"ej":"turret_minigun","lc":10,"ib":0,"ie":0,"cg":[163],"mu":180,"mr":120,"hw":"turret_splat","hy":"blast","kw":true},"horror_cls":{"lc":12,"ek":2,"cg":[160,161,162],"ej":"radiation","mu":180,"mr":120,"hw":"goo_splat","kw":true,"hy":"goo_chunks"},"kx":{"ha":1,"cx":0,"cy":0,"ib":0,"mj":false,"cg":[69,82,81,80],"hc":"cc","jb":"mi","df":"p"},"cactus":{"lc":5,"ib":0,"spr":83,"jb":"p","hw":"goo_splat","hy":"green_chunks"},"candle_cls":{"nt":"candle","nv":4,"nu":0,"ib":0,"spr":178,"ic":"p","jb":"p"},"frog_cls":{"lc":18,"rnd":{"mu":[160,180]},"mr":120,"cx":0.8,"cy":0.8,"ej":"acid_gun","cg":[231,233,235,233],"kw":true},"horror_spwnr_cls":{"cg":[84],"ib":0,"kw":true,"lc":10,"ej":"horror_spwn","hy":"green_chunks"},"cop_box_cls":{"cx":0.8,"cy":0.8,"cg":[237],"ib":0,"kw":true,"lc":20,"ej":"cop_spwn","hw":"turret_splat","hy":"blast"}}')
function iy(cd,ce,fs)
local cu=fr(iz.ix,
fr(fs,{
lq=ks,
cd=cd,
ce=ce}))
if(cu.nr) cu:nr()
if(cu.kw) ey+=1 ks+=1 cu.mq=cocreate(lm)
if(cu.mu) cu.mu+=33*h
hf(cu,hg)
return add(e,cu)
end
function ns(cu)
if cu.jb then
cu:jb()
if cu.lf then
hf(cu,hh)
return
end
end
if cu.nt and cu.nu<a then
dg(
cu.cd+fv(-cu.cx,cu.cx),cu.ce-0.5,0,
br[cu.nt])
cu.nu=a+cu.nv
end
hf(cu,hh)
local nw=cu==bu and kr or kj
if not nw(cu,cu.cv,0) then
cu.cd+=cu.cv
else
cu.cv*=-cu.ie
end
if not nw(cu,0,cu.cw) then
cu.ce+=cu.cw
else
cu.cw*=-cu.ie
end
cu.cv=dq(cu.cv,cu.dr)
cu.cw=dq(cu.cw,cu.dr)
cu.ch+=abs(cu.cv)*4
cu.ch+=abs(cu.cw)*4
hf(cu,hg)
dj(cu)
end
function nx()
bv=true
local ny=fu(bw)
bu=iy(18,18,{
nz=0,oa=0,
ib=0.045,
lc=bt,
ho=l,
ob=ny.ob,
cg=ny.ob[2],
ej=em["oc"],
iv=em.oc.iv,
nn=a+30,
od=a+30,
palt=ny.palt or 14,
ic=ku,
jb=p,
hw="head"
})
return bu
end
function oe()
if bv then
local ej,cm,of,cv,cw=bu.ej,bu.cm,false,0,0
if(btn(0)) bu.cv-=bu.ib cv=-1 cm=0.5
if(btn(1)) bu.cv+=bu.ib cv=1 cm=0
if(btn(2)) bu.cw-=bu.ib cw=-1 cm=0.25
if(btn(3)) bu.cw+=bu.ib cw=1 cm=0.75
if f==1 then
of=stat(34)==1
cv,cw=stat(32),stat(33)
bu.nz,bu.oa=cv,cw
cm=(0.5+atan2(64-cv,64-cw))%1
else
of=btn(4)
if(bor(cv,cw)!=0) cm=atan2(cv,cw)
end
if of and bu.mt<a then
if bu.iv>0 then
bu.mt=a+ej.hv
bu.og=a+8
ir(bu,ej)
local dc={cos(cm),sin(cm)}
bu.cv-=0.05*dc[1]
bu.cw-=0.05*dc[2]
cs(dc[1],dc[2],ej.oh or 0)
end
end
if f==1 or bu.og<a then
bu.cm,bu.iw=cm,flr(8*cm)
end
end
if abs(bu.cv)+abs(bu.cw)>0.1 then
bu.cg=bu.ob[1]
bu.od=a+30
end
if bu.od<a then
bu.cg=bu.ob[2]
if a%8==0 then
bu.ch+=1
end
end
end
function mk()
a=0
ks=0
g+=1
local oi
if g>#ez then
h+=1
g=1
oi=true
end
bt=8*h
hd,e={},{}
bs={}
ji()
add(e,bu)
if i.jj then
bu.cd,bu.ce=i.oj[1]+0.5,i.oj[2]+0.5
else
local da=jf[1]
bu.cd,bu.ce=da.cd+da.cx/2,da.ce+da.cy/2
end
bu.cv,bu.cw,bu.cz,bu.mt,bu.og=0,0,0,0,0
bu.nn=a+30*h
bv=true
if oi then
dg(bu.cd,bu.ce,0.5,br["notice"]).cp="i feel stronger!"
end
music(-1,250)
music(i.music or 14)
end
local ok=false
bp.jb=function()
if not ok and kt() then
ok=true
fe(function()
me(16,96)
me(96,16)
end,d)
fe(function()
gm(90)
g,h=0,1
bt=8
bu=nx()
mk()
ok=false
bq=bo
gm(90)
end)
end
end
bp.hc=function()
cls(2)
fillp(0xa5a5)
local cu,da,cd,ce=a/32,0
for v=1,196 do
cd,ce=da*cos(cu),da*sin(cu)
circfill(64+cd,64-ce,da/8,0x10)
cu+=0.02
da+=0.5
end
fillp()
cd,ce=cos(a/64),sin(-a/64)
cl(8,8,64+12*cd,64+12*ce,atan2(cd,ce))
palt(0,false)
palt(14,true)
sspr(0,112,56,16,10,12,112,32)
palt()
fk(true,3)
if a%32>16 then
fm("press start",64,108,11)
end
fm(f==1 and"[keyb.+mouse]"or"[keyboard]",64,116,7)
fk(true,0,true)
fm("freds72 presents",64,3,6)
end
bo.jb=function()
bx-=1
if(bx>0) return
bx=0
gq()
oe(bu)
for ct,dd in pairs(e) do
ns(dd)
end
fq(bs,"jb")
hs()
end
bo.hc=function()
ht(bu.cd,bu.ce)
cls(i.ol)
local jn,jo=i.jn or 0,i.jo or 0
local cj,ck=64-ca+8*jn,64-cb+8*jo-4
pal()
palt(0,false)
map(jn,jo,cj,ck,j,k,1)
gr()
pal()
palt()
if i.om then
pal(10,i.om[1])
pal(9,i.om[2])
pal(1,i.om[3])
end
map(jn,jo,cj,ck,j,k,2)
pal()
if(i.on) i.on()
if f==1 then
spr(i.cursor or 35,bu.nz-3,bu.oa-3)
end
if bv then
rectfill(1,1,34,9,0)
rect(2,2,33,8,6)
local lc=max(flr(bu.lc))
rectfill(3,3,3+flr(29*lc/bt),7,8)
fk(false,0)
fm(lc.."/"..bt,12,3,7)
palt(14,true)
palt(0,false)
spr(bu.ej.la,2,10)
fm(bu.iv,14,12,7)
end
end
function _update60()
a+=1
b+=1
local dl=stat(1)
fb(c)
bq.jb()
end
function _draw()
local dl=stat(1)
bq.hc()
fb(d)
b=0
end
function _init()
poke(0x5f2d,1)
if cartdata("freds72_nuklear_klone") then
f=dget(0)
end
menuitem(1,"mouse on/off",function()
f=bxor(f,1)
dset(0,f)
end)
bq=bp
music(0)
end