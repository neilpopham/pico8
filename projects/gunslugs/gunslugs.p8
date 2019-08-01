pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
screen={width=128,height=128,x2=127,y2=127}
dir={left=1,right=2}
drag={air=0.95,ground=0.65,gravity=0.7}

--[[ todo
get spiders working
show current gun in hud (2x1 sprites)
place new guns in map
try a grenade launch bullet type (angled and bouncing)
- can be used by an enemy and player gun
maybe take multiplier off camera and up values currently passed through
change medikit to white case?
check how many sprites we actually can use!
way to pick enemies:
- pick a number depending on the level
- create pool from all picked starting with most difficult
- limit pool so that easier ones slowly get missed out
- use that pool when setting map
use a counter to make enemies jump
- as counter ticks down simulate button press
create scene transition
{{7},nil,nil,{15,10},nil,{6},nil,nil,{9},{14},{11,12},nil,{13},nil,{4},{8},{3,5},nil,{2},nil,nil,{1}}
]]

#include functions.lua
#include particles.lua
#include camera.lua
#include objects.lua
#include button.lua
#include destructables.lua
#include weapons.lua
#include enemies.lua
#include player.lua
#include bullets.lua
#include pickups.lua
#include levels.lua
#include stages/intro.lua
#include stages/main.lua
#include stages/over.lua

function _init()
 enemies=collection:create()
 particles=collection:create()
 bullets=bullet_collection:create()
 destructables=collection:create()
 pickups=collection:create()
 stage=stage_intro
 stage:init()
end

function _update60()
 stage:update()
end

function _draw()
 cls()
 stage:draw()
end

__gfx__
0000000077777776aaaaaaa98e6e8822b6a6bb330000000000000000000000000000000000001111111000000000000011101111111011110000000000000000
000000007666666da999999428e822223b6b3333000000001d6d11111d6d11111d6d111100001111111000000000000011101111111011110000000000000000
000000007666666d944444448e6e8822b6a6bb33000000001d6d11111d6d11111d6d111100001111111000000000000011101111111011110000000000000000
000000007666666da999999482228822b333bb33000000001d6d11111d6d11111d6d111100000000000000000000000000000000000000000000000000000000
000000007666666da99999942e2e28223a3a3b330000000001d1111001d1111001d1111000000000111111101111111000000000111111100000000000000000
000000007666666daaaaaaa482228822b333bb330000000008800000000880000000088000000000111111101111111000000000111111100000000000000000
000000007666666da99999948e6e8822b6a6bb330000000000000000000000000000000000000000111111101111111000000000111111100000000000000000
000000006ddddddd9444444428e822223b6b33330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000011111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000
04444411111111111111111111444440111111111111111114444441000000000000000000000000667777660667777000d67700000dd00000776d0007777660
0141441104444411044444111144141011444440114444401414414100000000000000000000000067788776067788e000d6e800000dd000008e6d000e887760
04444411014144110141441111444440114414101144141014444441000000000000000000000000778888770678888000d68800000dd00000886d0008888760
04124410044444110444441101442140114444401144444014211241000000000000000000000000778888770678888000d68800000dd00000886d0008888760
6333333064124410641244100333366601442146014421466333333000000000000000000000000067788776067788e000d6e800000dd000008e6d000e887760
03344330044333300333442003311330033113300222133013333330000000000000000000000000667777660667777000d67700000dd00000776d0007777660
02202220000022200220000002220220022200000000022002200220000000000000000000000000000000000000000000000000000000000000000000000000
a7000000ba0000000990000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa000000bb00000099a9000082220000000000000000000000000000000000000888888000288800000280000002200000082000008882000550550002202200
00000000000000009999000088820000000000000000000000000000000000008887788802887880002288000002200000882200088788205ddddd5028888820
00000000000000000990000028820000000000000000000000000000000000008877778802877780002878000002200000878200087778205ddd6d502888e820
00000000000000000000000002200000000000000000000000000000000000008877778802877780002878000002200000878200087778205ddddd5028888820
000000000000000000000000000000000000000000000000000000000000000088877888028878800022880000022000008822000887882005ddd50002888200
0000000000000000000000000000000000000000000000000000000000000000088888800028880000028000000220000008200000888200005d500000282000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000020000
0f7fffff0000000000000000f7fffff00000000000000000ff7fffff0000000000000000000000000000000000000000000000000d0000000000d00000000000
0f7fffff0f7fffff0f7ffffff7fffff0f7fffff0f7fffff0ff7fffff000111100111100000011110011110000000000000000000666666660002666666666666
0171ffff0f7fffff0f7ffffff7ff1f10f7fffff0f7fffff0f1dff11f001112111121110000111211112111000000000000000000dddddddd4444dddddddddddd
0f7fffff0171ffff0171fffff7fffff0f7ff1f10f7ff1f10ff7fffff001121211212110000112121121211000000000000000000555060004444206044444000
0f7fffff0f7fffff0f7ffffff7fffff0f7fffff0f7fffff0ff7fffff371112111121117337111211112111730000000000000000ddd600004440060000000000
6dddddd06f7fffff6f7fffff0dddd666f7fffff6f7fffff665ddddd0331111311311113333111131131111330000000000000000ddd000000000000000000000
0dd11dd0011dddd00ddd11500dd11dd00dd11dd005551dd0d5ddddd0333111300311133333131113311131330000000000000000000000000000000000000000
05505550000055500550000005550550055500000000055005500550303030300303030303030303303030300000000000000000000000000000000000000000
__gff__
0003010101000000000000000000000000000000000000000000000000000000000000000000000001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000300502e0502c0502a0502905028050260402504025040240402404024040230402104020070200401f0401e0401d0401c0401b0401b0401a04019040140001000013000110000e0000b0000900007000
0001000038770367703477032770307702e7702d7702b7702977028770277702577024770237702277021770207701f7701e7701e7701d7701b7701a750187501674013740117300e7300c720097200771006710
0001000027640206401b6401464008640076300563005630066300562005620056200561004600036000360003600016000660005600046000460003600036000360003600026000430003300033000330003300
00050000366502d660246601b65017650146500e640086300662004610016100161001600016001d6001c6001b6001a6001a60019600186001760017600000000000000000000000000000000000000000000000
0004000038640246401d63015630116200e6200861003610036000360002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000205502355028550235501d550304003040030400304000b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
