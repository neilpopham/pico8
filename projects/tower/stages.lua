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
