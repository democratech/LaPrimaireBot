# encoding: utf-8

=begin
    Bot LaPrimaire.org helps french citizens participate to LaPrimaire.org
    Copyright (C) 2016 Telegraph.ai

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

module YouCandidat
	# is being called when the module is included
	# here you need to update the Bot with your Add-on screens and hook your entry point into the Bot's menu
	def self.included(base)
		messages={
			:fr=>{
				:you_candidat=>{
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
		screens={
			:you_candidat=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:finger_right]} Proposer un candidat",
					:text=>messages[:fr][:you_candidat][:you_candidat],
					:callback=>"you_candidat/menu",
				},
				:you_candidat_confirm=>{
					:answer=>"#{Bot.emoticons[:search]} Rechercher le candidat",
					:text=>messages[:fr][:you_candidat][:you_candidat_confirm],
					:kbd=>["you_candidat/you_candidat_yes","you_candidat/you_candidat_no"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:you_candidat_yes=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Oui, je confirme mon choix",
					:text=>messages[:fr][:you_candidat][:you_candidat_yes],
					:jump_to=>"home/menu"
				},
				:you_candidat_no=>{
					:answer=>"#{Bot.emoticons[:thumbs_down]} Non, ce n'est pas la bonne personne",
					:text=>messages[:fr][:you_candidat][:you_candidat_no],
					:jump_to=>"you_candidat/menu"
				},
				:you_candidat_not_found=>{
					:text=>messages[:fr][:you_candidat][:you_candidat_not_found],
					:jump_to=>"you_candidat/menu"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"you_candidat/menu"}}})
	end

	def you_candidat_menu(msg,user,screen)
		@users.update(
			user[:id],
			{
				:expected_input=>:free_text,
				:expected_input_size=>1,
				:callback=>"you_candidat/you_candidat_confirm"
			}
		)
		return self.get_screen(screen,user,msg)
	end

	def you_candidat_you_candidat_confirm(msg,user,screen)
		candidat=user[:buffer]
		user_update={
			:buffer=>"",
			:expected_input=>:answer,
			:expected_input_length=>-1,
		}
		@users.update(user[:id],user_update)
		img,type = @search.image(candidat)
		return self.get_screen(self.find_by_name("you_candidat/you_candidat_not_found"),user,msg) if img.nil?
		output_img='image'+user[:id].to_s+"."+type
		open(output_img,'wb') { |file| file << open(img.link).read }
		screen=self.find_by_name("you_candidat/you_candidat_confirm")
		screen[:text]=screen[:text] % {media:"image:"+output_img}
		return self.get_screen(self.find_by_name("you_candidat/you_candidat_confirm"),user,msg)
	end
end

include YouCandidat
