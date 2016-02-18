# encoding: utf-8

module Candidat
	def cb_you_candidat(msg,user,screen)
		puts "cb:you_candidat"
		@users.update(
			user[:id],
			{
				:expected_input=>:free_text,
				:expected_input_size=>1,
				:cb=>:you_candidat_confirm
			}
		)
		return self.get_screen(screen,user,msg)
	end

	def cb_you_candidat_confirm(msg,user,screen)
		puts "cb:you_candidat_confirm"
		candidat=user[:buffer]
		user_update={
			:buffer=>"",
			:expected_input=>:answer,
			:expected_input_length=>-1,
		}
		@users.update(user[:id],user_update)
		img,type = @search.image(candidat)
		return self.get_screen(self.find_by_name(:you_candidat_not_found),user,msg) if img.nil?
		output_img='image'+user[:id].to_s+"."+type
		open(output_img,'wb') { |file| file << open(img.link).read }
		screen=self.find_by_name(:you_candidat_confirm)
		screen[:media]="image:"+output_img
		return self.get_screen(self.find_by_name(:you_candidat_confirm),user,msg)
	end
end
