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

module Beta
	def self.included(base)
		messages={
			:fr=>{
				:beta=>{
					:welcome=><<-END,
Bonjour %{first_name} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
L'accès à LaPrimaire est actuellement restreint aux seuls beta-testeurs.
END
					:menu=><<-END,
Avez-vous reçu un code de beta-testeur ? 
END
					:check_code=><<-END,
Super ! Quel est votre code ?
END
					:yes_bis=><<-END,
Ok réessayons ! Quel est le code beta-testeur que vous avez reçu ?
END
					:code_wrong=><<-END,
Hmmmmm... apparemment ce code ne fonctionne pas #{Bot.emoticons[:disappointed]}
Reprenons du début !
END
					:come_back_later=><<-END,
Désolé, il va vous falloir patienter encore un peu pour pouvoir accéder à LaPrimaire #{Bot.emoticons[:disappointed]}
Si cela peut vous réconforter, l'ouverture est prévue dans les tous prochains jours !
END
					:code_ok=><<-END,
Parfait ! Merci encore de nous aider à mettre au point LaPrimaire.org #{Bot.emoticons[:thumbs_up]}
Une dernière petite question : Nous allons avoir besoin d'un coup de main pour pré-valider la pertinence des candidats qui seront proposés.
Est-ce que cela vous dérangerait que nous vous sollicitions de temps en temps pour valider des candidats qui nous sont proposés ?
END
					:no_pb=><<-END,
Super, merci beaucoup !
END
					:nah=><<-END,
Ok, pas de souci, je comprends #{Bot.emoticons[:smile]} C'est déjà sympa de nous faire vos retours sur l'application en tout cas !
END
					:pas_compris=><<-END,
Désolé je n'ai pas compris ce que vous vouliez me dire #{Bot.emoticons[:disappointed]}
END
				}
			}
		}
		screens={
			:system=>{
				:dont_understand=>{
					:text=>messages[:fr][:beta][:pas_compris],
					:jump_to=>"beta/menu"
				}
			},
			:home=>{ 
				:welcome=>{
					:answer=>nil
				}
			},
			:beta=>{
				:menu=>{
					:text=>messages[:fr][:beta][:menu],
					:kbd=>["beta/check_code","beta/come_back_later"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:welcome=>{
					:answer=>"/start",
					:text=>messages[:fr][:beta][:welcome],
					:callback=>"beta/welcome",
					:jump_to=>"beta/menu"
				},
				:check_code=>{
					:answer=>"#{Bot.emoticons[:smile]} Oui j'ai reçu un code",
					:text=>messages[:fr][:beta][:check_code],
					:callback=>"beta/enter_code"
				},
				:code_received=>{
					:answer=>"#{Bot.emoticons[:smile]} C'est bon j'ai reçu mon code !",
					:text=>messages[:fr][:beta][:check_code],
					:callback=>"beta/enter_code"
				},
				:code_wrong=>{
					:answer=>"#{Bot.emoticons[:confused]} Non",
					:text=>messages[:fr][:beta][:code_wrong],
					:jump_to=>"beta/menu"
				},
				:yes_bis=>{
					:answer=>"Oui, je me suis trompé de code #{Bot.emoticons[:grinning]}",
					:text=>messages[:fr][:beta][:yes_bis],
					:callback=>"beta/enter_code"
				},
				:come_back_later=>{
					:answer=>"#{Bot.emoticons[:confused]} Non",
					:text=>messages[:fr][:beta][:come_back_later],
					:kbd=>["beta/code_received"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:code_ok=>{
					:text=>messages[:fr][:beta][:code_ok],
					:kbd=>["beta/no_pb","beta/nah"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:no_pb=>{
					:answer=>"Oui, avec plaisir !",
					:text=>messages[:fr][:beta][:no_pb],
					:jump_to=>"home/welcome"
				},
				:nah=>{
					:answer=>"Non désolé",
					:text=>messages[:fr][:beta][:nah],
					:jump_to=>"home/welcome"
				},

			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def beta_welcome(msg,user,screen)
		@users.update(user[:id],{:new=>false})
		return self.get_screen(screen,user,msg)
	end

	def beta_enter_code(msg,user,screen)
		@users.update(
			user[:id],
			{
				:expected_input=>:free_text,
				:expected_input_size=>1,
				:callback=>"beta/check_code"
			}
		)
		return self.get_screen(screen,user,msg)
	end

	def beta_check_code(msg,user,screen)
		code=user[:buffer]
		user_update={
			:buffer=>"",
			:expected_input=>:answer,
			:expected_input_length=>-1,
		}
		@users.update(user[:id],user_update)
		puts code
		screen=self.find_by_name("beta/code_ok")
		screen=self.find_by_name("beta/code_wrong") if false
		return self.get_screen(screen,user,msg)
	end
end

include Beta
