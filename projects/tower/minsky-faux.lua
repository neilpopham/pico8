function minsky(x,y,r)
 local circs={
  {1},
  {1,3},
  {3,5,5},
  {3,5,7,7},
  {3,7,7,9,9},
  {5,7,9,11,11,11}
 }
 local cell,circ,o={},circs[r],0
 for row=#circ,1,-1 do
  local radius=circ[row]\2
  cell[y-o]={x1=max(0,x-radius),x2=min(24,x+radius)}
  cell[y+o]=cell[y-o]
  o+=1
 end
 return cell
end
