stage_intro={

 init=function()

 end,

 update=function()
  if btnp(pad.btn1) or btnp(pad.btn2) then
   stage=stage_main
   stage:init()
  end
 end,

 draw=function()
  print("press \142 or \151 to start",18,110,7)
 end
}
