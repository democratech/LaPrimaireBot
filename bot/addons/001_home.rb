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

module Home
	def self.included(base)
		puts "loading Home add-on" if DEBUG
		messages={
			:fr=>{
				:home=>{
					:welcome=><<-END,
Bonjour %{firstname} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
Mon rôle est de vous accompagner et de vous informer tout au long du déroulement de La Primaire.
A tout moment, si vous avez des questions n'hésitez à me les poser, j'essaierais d'y répondre au mieux de mes capacités.
Mais assez parlé, commençons !
END
					:menu=><<-END,
Que voulez-vous faire ?
END
				}
			}
		}
		screens={
			:home=>{
				:welcome=>{
					:answer=>"/start",
					:text=>messages[:fr][:home][:welcome],
					:disable_web_page_preview=>true,
					:callback=>"home/welcome",
					:jump_to=>"home/menu"
				},
				:menu=>{
					:answer=>"#{Bot.emoticons[:home]} Accueil",
					:text=>messages[:fr][:home][:menu],
					:callback=>"home/menu",
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"home/menu"}}})
	end

	def home_welcome(msg,user,screen)
		puts "home_welcome" if DEBUG
		if user['betatester'].to_b and (not (user['email'] or user['city'] or user['country']) or not user['can_vote'].to_b)then
			screen=self.find_by_name("welcome/hello")
		elsif user['betatester'].to_b and user['can_vote'] and user['email'] and user['city'] and user['country'] then
			screen=self.find_by_name("home/menu")
			screen[:kbd_del]=["home/menu"]
		else
			screen=self.find_by_name("beta/welcome")
		end
		return self.get_screen(screen,user,msg)
	end

	def home_menu(msg,user,screen)
		puts "home_menu" if DEBUG
		screen[:kbd_del]=["home/menu"]
		@users.next_answer(user[:id],'answer')
		@users.clear_session(user[:id],'candidate')
		@users.clear_session(user[:id],'delete_candidates')
		return self.get_screen(screen,user,msg)
	end
end

include Home
