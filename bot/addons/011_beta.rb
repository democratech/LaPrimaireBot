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
		puts "loading Beta add-on" if DEBUG
		messages={
			:fr=>{
				:beta=>{
					:welcome=><<-END,
Bonjour %{firstname} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
L'accès à LaPrimaire.org est actuellement restreint aux seuls beta-testeurs.
END
					:menu=><<-END,
Avez-vous reçu un code de beta-testeur ? 
END
					:check_code=><<-END,
Super ! Quel est votre code ?
END
					:code_wrong=><<-END,
Hmmmmm... apparemment ce code ne fonctionne pas #{Bot.emoticons[:disappointed]}
Reprenons du début !
END
					:come_back_later=><<-END,
Désolé, il va vous falloir patienter encore un peu pour pouvoir accéder à LaPrimaire.org #{Bot.emoticons[:disappointed]}
Si cela peut vous réconforter, l'ouverture est prévue dans les tous prochains jours !
END
					:code_ok=><<-END,
Code correct ! Bienvenue et merci encore de nous aider à mettre au point LaPrimaire.org #{Bot.emoticons[:thumbs_up]}
Une dernière petite question : Nous allons avoir besoin d'un coup de main pour pré-valider la pertinence des candidats qui nous seront proposés par les citoyens.
Est-ce que vous nous autorisez à vous solliciter de temps en temps pour valider des candidats qui nous sont proposés ?
END
					:no_pb=><<-END,
Super, merci beaucoup !
END
					:nah=><<-END,
Ok, pas de souci, je comprends #{Bot.emoticons[:smile]} C'est déjà sympa de nous faire vos retours sur l'application en tout cas !
END
				}
			}
		}
		screens={
			:home=>{ 
				:welcome=>{
					:answer=>nil
				}
			},
			:beta=>{
				:menu=>{
					:text=>messages[:fr][:beta][:menu],
					:disable_web_page_preview=>true,
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
					:text=>messages[:fr][:beta][:code_wrong],
					:jump_to=>"beta/menu"
				},
				:come_back_later=>{
					:answer=>"#{Bot.emoticons[:confused]} Non je n'ai pas de code",
					:text=>messages[:fr][:beta][:come_back_later],
					:disable_web_page_preview=>true,
					:kbd=>["beta/code_received"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:code_ok=>{
					:text=>messages[:fr][:beta][:code_ok],
					:disable_web_page_preview=>true,
					:callback=>"beta/tester",
					:kbd=>["beta/no_pb","beta/nah"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:no_pb=>{
					:answer=>"Oui, n'hésitez pas à me demander #{Bot.emoticons[:little_smile]}",
					:text=>messages[:fr][:beta][:no_pb],
					:callback=>"beta/reviewer",
					:jump_to=>"welcome/start"
				},
				:nah=>{
					:answer=>"Désolé, je n'ai pas vraiment envie #{Bot.emoticons[:confused]}",
					:text=>messages[:fr][:beta][:nah],
					:jump_to=>"welcome/start"
				},

			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def beta_welcome(msg,user,screen)
		puts "beta_welcome" if DEBUG
		#screen=self.find_by_name("welcome/start") if true
		return self.get_screen(screen,user,msg)
	end

	def beta_enter_code(msg,user,screen)
		puts "beta_enter_code" if DEBUG
		@users.next_answer(user[:id],'free_text',1,"beta/verify_code")
		return self.get_screen(screen,user,msg)
	end

	def beta_verify_code(msg,user,screen)
		code=user['session']['buffer']
		puts "beta_verify_code : #{code}" if DEBUG
		@users.next_answer(user[:id],'answer')
		if BETA_CODES.include?(code) then
			screen=self.find_by_name("beta/code_ok")
		else
			screen=self.find_by_name("beta/code_wrong")
		end
		return self.get_screen(screen,user,msg)
	end

	def beta_tester(msg,user,screen)
		@users.set(user[:id],{:set=> 'betatester',:value=> true})
		return self.get_screen(screen,user,msg)
	end

	def beta_reviewer(msg,user,screen)
		@users.set(user[:id],{:set=>'reviewer',:value=>true})
		return self.get_screen(screen,user,msg)
	end
end

include Beta
