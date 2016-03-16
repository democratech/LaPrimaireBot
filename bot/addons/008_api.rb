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

module Api
	def self.included(base)
		puts "loading Api add-on" if DEBUG
		messages={
			:fr=>{
				:api=>{
					:access_granted=><<-END,
Bonne nouvelle %{firstname}, vous avez désormais accès à LaPrimaire.org... c'est parti ! #{Bot.emoticons[:face_sunglasses]}
END
				}
			}
		}
		screens={
			:api=>{
				:access_granted=>{
					:text=>messages[:fr][:api][:access_granted],
					:disable_web_page_preview=>true,
					:jump_to=>"welcome/start"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def api_access_granted(msg,user,screen)
		puts "api_access_granted" if DEBUG
		@users.remove_from_waiting_list(user)
		@users.next_answer(user[:id],'answer')
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'access_granted')
		return self.get_screen(screen,user,msg)
	end
end

include Api
