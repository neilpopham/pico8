stage_intro={
 init=function(self)
  rooms=decompress()
 end,
 update=function(self)
  if btnp(4) then
   stages:update(stage_main)
  end
 end,
 draw=function(self)
  print("press \142 to start",30,61,7)
  print("\142",54,61,9)
 end
}
