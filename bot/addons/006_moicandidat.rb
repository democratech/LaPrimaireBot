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

module MoiCandidat
	def self.included(base)
		Bot.log.info "loading MoiCandidat add-on"
		messages={
			:fr=>{
				:moi_candidat=>{
					:menu=><<-END,
Si vous souhaitez être candidat, merci de remplir le formulaire d'<a href="https://laprimaire.org/inscription-candidat/">inscription candidat(e)</a>, en vous assurant au  préalable que vous êtes en accord avec la <a href="https://laprimaire.org/charte/">charte du candidat</a>.
END
				}
			}
		}
		screens={
			:moi_candidat=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:raising_hand]} Etre candidat",
					:text=>messages[:fr][:moi_candidat][:menu],
					:parse_mode=>"HTML",
					:kbd=>["moi_candidat/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:retour=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"moi_candidat/retour_cb"
				},
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"moi_candidat/menu"}}})
	end

	def moi_candidat_retour_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		from=user['session']['previous_session']['current']
		case from
		when "moi_candidat/menu"
			screen=self.find_by_name("home/menu")
		else
			screen=self.find_by_name("home/menu")
		end
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end
end

#include MoiCandidat
