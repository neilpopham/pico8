pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- king
-- by neil popham

function txt(t,x,y)
 for i=1,#t do
  print(sub(t,i,i),x+i*4-4,y,rnd(2)+8)
  print(sub(t,i,i),x+i*4-4,y+8,8+i%2)
 end
end


cls()
txt("king of the world",40,40)


