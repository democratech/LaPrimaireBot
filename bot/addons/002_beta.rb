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
		Bot.log.info "loading Beta add-on"
		messages={
			:fr=>{
				:beta=>{
					:welcome=><<-END,
Bonjour %{firstname} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
image:static/images/laprimaire-bienvenue.jpg
L'accès à LaPrimaire.org est actuellement restreint aux seuls beta-testeurs.
END
					:menu=><<-END,
Avez-vous un code de beta-testeur ?
END
					:check_code=><<-END,
Super ! Quel est votre code ?
END
					:code_wrong=><<-END,
Hmmmmm... apparemment ce code ne fonctionne pas #{Bot.emoticons[:disappointed]}
Reprenons du début !
END
					:come_back_later=><<-END,
Ok c'est bien noté ! Vous êtes actuellement %{position} sur la liste d'attente, je vous préviendrai dès que vous pourrez accéder à LaPrimaire.org. Cela ne devrait pas être très long, quelques jours tout au plus. Merci pour votre patience !
Pour être prévenu, je vous invite à installer l'appli Telegram sur votre téléphone ou sur votre PC : <a href='https://telegram.org/dl'>Télécharger Telegram</a>
Telegram est l'application de messagerie sécurisée utilisée pour organiser LaPrimaire.org.
END
					:check_position=><<-END,
Vous êtes actuellement %{position} sur la liste d'attente (et, pour info, il y en a %{behind} derrière vous). Encore un peu de patience #{Bot.emoticons[:smile]}
END
					:code_ok=><<-END,
Bienvenue ! Merci encore de nous aider à finaliser LaPrimaire.org #{Bot.emoticons[:thumbs_up]}
END
				}
			}
		}
		screens={
			:beta=>{
				:menu=>{
					:text=>messages[:fr][:beta][:menu],
					:disable_web_page_preview=>true,
					:kbd=>["beta/check_code","beta/come_back_later"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:welcome=>{
					:text=>messages[:fr][:beta][:welcome],
					:callback=>"beta/welcome",
					:jump_to=>"beta/menu"
				},
				:check_code=>{
					:answer=>"#{Bot.emoticons[:smile]} Oui j'ai un code",
					:text=>messages[:fr][:beta][:check_code],
					:callback=>"beta/enter_code"
				},
				:code_received=>{
					:answer=>"#{Bot.emoticons[:smile]} J'ai un code",
					:text=>messages[:fr][:beta][:check_code],
					:callback=>"beta/enter_code"
				},
				:code_wrong=>{
					:text=>messages[:fr][:beta][:code_wrong],
					:jump_to=>"beta/menu"
				},
				:come_back_later=>{
					:answer=>"#{Bot.emoticons[:halo]} Non mais je voudrais bien",
					:text=>messages[:fr][:beta][:come_back_later],
					:callback=>"beta/waiting_list",
					:disable_web_page_preview=>true,
					:parse_mode=>"HTML",
					:kbd=>["beta/code_received","beta/check_position"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:check_position=>{
					:answer=>"#{Bot.emoticons[:tongue]} Quelle est ma position actuelle ?",
					:text=>messages[:fr][:beta][:check_position],
					:callback=>"beta/check_position",
					:kbd=>["beta/code_received","beta/check_position"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:code_ok=>{
					:text=>messages[:fr][:beta][:code_ok],
					:disable_web_page_preview=>true,
					:jump_to=>"welcome/start"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def beta_welcome(msg,user,screen)
		Bot.log.info "beta_welcome"
		return self.get_screen(screen,user,msg)
	end

	def beta_enter_code(msg,user,screen)
		Bot.log.info "beta_enter_code"
		@users.next_answer(user[:id],'free_text',1,"beta/verify_code_cb")
		return self.get_screen(screen,user,msg)
	end

	def beta_verify_code_cb(msg,user,screen)
		code=user['session']['buffer']
		Bot.log.info "beta_verify_code : #{code}"
		@users.next_answer(user[:id],'answer')
		if (@users.beta_code_ok(code) or BETA_CODES.include?(code)) then
			screen=self.find_by_name("beta/code_ok")
			@users.remove_from_waiting_list(user)
			@users.update_settings(user[:id],{'roles'=>{'betatester'=> true}})
			Bot.log.event(user[:id],'user_enters_beta_test',{'with_code'=>code})
			Bot.log.people(user[:id],'append',{'betatest_code'=>code})
		else
			screen=self.find_by_name("beta/code_wrong")
		end
		return self.get_screen(screen,user,msg)
	end

	def beta_waiting_list(msg,user,screen)
		res=@users.get_position_on_wait_list(user[:id])
		pos=res['position'].to_i
		if (pos==0) then
			@users.add_to_waiting_list(user)
			res=@users.get_position_on_wait_list(user[:id])
			pos=res['position'].to_i
			Bot.log.event(user[:id],'user_added_to_waiting_list',{'position'=>pos.to_s})
		end
		pos= (pos==1) ? "1er" : "#{pos}ème"
		screen[:text] = screen[:text] % {position: pos}
		return self.get_screen(screen,user,msg)
	end

	def beta_check_position(msg,user,screen)
		res=@users.get_position_on_wait_list(user[:id])
		pos=res['position'].to_i
		tot=res['total'].to_i
		behind=(tot-pos).to_s
		nb_times=user['settings']['actions']['beta_nb_position_checked'].to_i+1
		@users.update_settings(user[:id],{'actions'=>{'beta_nb_position_checked'=>nb_times}})
		Bot.log.people(user[:id],'increment',{'beta_waiting_list_pos_checked'=>1})
		pos= (pos==1) ? "1er" : "#{pos}ème"
		screen[:text] = screen[:text] % {position: pos, behind: behind}
		return self.get_screen(screen,user,msg)
	end
end

#include Beta
