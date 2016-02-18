# encoding: utf-8

module Welcome
	def cb_welcome(msg,user,screen)
		puts "cb:welcome"
		@users.update(user[:id],{:new=>false})
		return self.get_screen(screen,user,msg)
	end
end
