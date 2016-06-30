# encoding: utf-8

=begin
   LaPrimaire.org Bot helps french citizens participate to LaPrimaire.org
   Copyright 2016 Telegraph-ai

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
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
