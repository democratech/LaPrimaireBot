# encoding: utf-8

module Candidat

	@@messages={
		:fr=>{
			:candidat=>{
				:you_candidat=><<-END,
Qui souhaitez-vous proposer comme candidat(e) ?
END
				:you_candidat_confirm=><<-END,
Ok, je recherche...
%{media}
Est-ce bien votre choix ?
END
				:you_candidat_yes=><<-END,
Parfait, c'est bien enregistré !
END
				:you_candidat_no=><<-END,
Hmmmm... réessayons !
END
				:you_candidat_not_found=><<-END,
Malheureusement, je ne trouve personne avec ce nom #{Bot.emoticons[:crying_face]}
END
			}
		}
	}

	@@screens={
		:candidat=>{
			:me_candidat=>{
				:answer=>"#{Bot.emoticons[:finger_up]} Etre candidat",
				:text=>Bot.messages()[:fr][:home][:not_implemented],
				:jump_to=>"home/intro"
			},
			:you_candidat=>{
				:answer=>"#{Bot.emoticons[:finger_right]} Proposer un candidat",
				:text=>@@messages[:fr][:candidat][:you_candidat],
				:callback=>"candidat/you_candidat",
			},
			:you_candidat_confirm=>{
				:answer=>"#{Bot.emoticons[:search]} Rechercher le candidat",
				:text=>@@messages[:fr][:candidat][:you_candidat_confirm],
				:kbd=>["candidat/you_candidat_yes","candidat/you_candidat_no"],
				:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
			},
			:you_candidat_yes=>{
				:answer=>"#{Bot.emoticons[:thumbs_up]} Oui, je confirme mon choix",
				:text=>@@messages[:fr][:candidat][:you_candidat_yes],
				:jump_to=>"home/intro"
			},
			:you_candidat_no=>{
				:answer=>"#{Bot.emoticons[:thumbs_down]} Non, ce n'est pas la bonne personne",
				:text=>@@messages[:fr][:candidat][:you_candidat_no],
				:jump_to=>"candidat/you_candidat"
			},
			:you_candidat_not_found=>{
				:text=>@@messages[:fr][:candidat][:you_candidat_not_found],
				:jump_to=>"candidat/you_candidat"
			}
		}
	}

	def self.included(base)
		screens=Bot.screens
		screens[:home][:intro][:kbd].unshift("candidat/me_candidat","candidat/you_candidat")
		screens=screens.merge(@@screens)
		Bot.updateScreens(screens)
		Bot.updateMessages(@@messages)
	end

	def candidat_you_candidat(msg,user,screen)
		@users.update(
			user[:id],
			{
				:expected_input=>:free_text,
				:expected_input_size=>1,
				:callback=>"candidat/you_candidat_confirm"
			}
		)
		return self.get_screen(screen,user,msg)
	end

	def candidat_you_candidat_confirm(msg,user,screen)
		candidat=user[:buffer]
		user_update={
			:buffer=>"",
			:expected_input=>:answer,
			:expected_input_length=>-1,
		}
		@users.update(user[:id],user_update)
		img,type = @search.image(candidat)
		return self.get_screen(self.find_by_name("candidat/you_candidat_not_found"),user,msg) if img.nil?
		output_img='image'+user[:id].to_s+"."+type
		open(output_img,'wb') { |file| file << open(img.link).read }
		screen=self.find_by_name("candidat/you_candidat_confirm")
		screen[:media]="image:"+output_img
		return self.get_screen(self.find_by_name("candidat/you_candidat_confirm"),user,msg)
	end
end
