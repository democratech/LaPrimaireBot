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

module Help
	def self.included(base)
		puts "loading Help add-on" if DEBUG
		messages={
			:fr=>{
				:help=>{
					:first_help_ok=><<-END,
Parfait, reprenons !
END
					:first_help=><<-END,
Désolé, je ne comprends pas ce que vous m'écrivez #{Bot.emoticons[:crying_face]}
Pour communiquer avec moi, il est plus simple d'utiliser les boutons qui s'affichent sur le clavier (en bas de l'écran) lorsque celui-ci apparaît.
De temps en temps, je vous demanderai d'écrire mais, le plus souvent, le clavier suffit #{Bot.emoticons[:smile]}
Si, par une fausse manipulation, vous faîtes disparaître les boutons du clavier, vous pouvez toujours le réafficher en cliquant sur l'icône suivante :
image:static/images/keyboard-button.png
Cliquez-sur le bouton "OK bien compris !" du clavier ci-dessous pour continuer.
END
				}
			}
		}
		screens={
			:help=>{
				:first_help_ok=>{
					:answer=>"Ok bien compris #{Bot.emoticons[:thumbs_up]}",
					:text=>messages[:fr][:help][:first_help_ok],
					:callback=>"help/first_help_cb",
				},
				:first_help=>{
					:text=>messages[:fr][:help][:first_help],
					:callback=>"help/first_help_cb",
					:save_session=>true,
					:kbd=>["help/first_help_ok"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true},
					:disable_web_page_preview=>true
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def help_first_help_cb(msg,user,screen)
		puts "help_first_help_cb" if DEBUG
		if screen[:save_session] then
			@users.next_answer(user[:id],'answer')
		else
			screen=@users.previous_state(user[:id])
			if !screen[:text].nil? then
				screen[:text]="Parfait, reprenons !\n"+screen[:text]
			else
				screen[:text]="Parfait, reprenons !"
			end
			@users.update_settings(user[:id],{'actions'=>{'first_help_given'=> true}})
		end
		return self.get_screen(screen,user,msg)
	end
end

include Help
