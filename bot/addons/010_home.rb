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
		messages={
			:fr=>{
				:home=>{
					:welcome=><<-END,
Bonjour %{first_name} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
Mon rôle est de vous accompagner et de vous informer tout au long du déroulement de La Primaire.
A tout moment, si vous avez des questions n'hésitez à me les poser, j'essaierais d'y répondre au mieux de mes capacités.
Mais assez parlé, commençons !
END
					:menu=><<-END,
Que voulez-vous faire ?
	END
					:not_implemented=><<-END,
Désolée, je n'ai pas encore reçu les instructions pour vous guider dans ce choix #{Bot.emoticons[:crying_face]}
END
					:pas_compris=><<-END,
Aïe, désolé %{first_name} j'ai peur de ne pas avoir compris ce que vous me demandez #{Bot.emoticons[:crying_face]}
END
				}
			}
		}
		screens={
			:system=>{
				:dont_understand=>{
					:text=>messages[:fr][:home][:pas_compris],
					:jump_to=>"home/menu"
				}
			},
			:home=>{
				:welcome=>{
					:answer=>"/start",
					:text=>messages[:fr][:home][:welcome],
					:callback=>"home/welcome",
					:jump_to=>"home/menu"
				},
				:menu=>{
					:answer=>"#{Bot.emoticons[:home]} Accueil",
					:text=>messages[:fr][:home][:menu],
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:memo=>{
					:answer=>"#{Bot.emoticons[:memo]} Vous faire un retour",
					:text=>messages[:fr][:home][:not_implementerd],
					:jump_to=>"home/menu"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"home/memo"}}})
	end

	def home_welcome(msg,user,screen)
		@users.update(user[:id],{:new=>false})
		return self.get_screen(screen,user,msg)
	end
end

include Home
