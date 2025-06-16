pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

function _init()
 vertexes = {
   {x=100, y=20},
   {x=40, y=40},
   {x=60, y=60}
 }
 c = 7
 vertex = 1
end

function _update60()
 cls(1)
 print(vertex,0,0,9)

 if btn(0) then
  vertexes[vertex].x -= 1
 elseif btn(1) then
  vertexes[vertex].x += 1
 end

 if btn(2) then
  vertexes[vertex].y -= 1
 elseif btn(3) then
  vertexes[vertex].y += 1
 end

 if btnp(5) then
  vertex += 1
  if vertex == 4 then vertex = 1 end
 end

end

function _draw()
 line(vertexes[1].x, vertexes[1].y, vertexes[2].x, vertexes[2].y, c)
 line(vertexes[2].x, vertexes[2].y, vertexes[3].x, vertexes[3].y, c)
 line(vertexes[3].x, vertexes[3].y, vertexes[1].x, vertexes[1].y, c)
end