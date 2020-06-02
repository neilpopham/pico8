stages={
 new=nil,
 update=function(self,new)
  self.new=new
 end,
 draw=function(self)
  if self.new then
   stage=self.new
   self.new=nil
   stage:init()
  end
 end
}

stage_main={
 init=function(self)

 end,
 update=function(self)
  p:update()
 end,
 draw=function(self)
  map()
  p:draw(2)
 end
}
