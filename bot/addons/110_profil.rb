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

module Profile
	def self.included(base)
		Bot.log.info "loading Profile add-on"
		messages={
			:fr=>{
				:profile=>{
					:menu=>"Que souhaitez-vous mettre à jour ?",
					:invalid_email=><<-END,
Hmmm... il semblerait que votre email (%{email}) soit erroné car je n'arrive pas à vous envoyer un email #{Bot.emoticons[:crying_face]}
Pour que votre vote soit pris en compte, il est <b>nécessaire</b> que votre email soit validé.
Souhaitez-vous mettre à jour votre email maintenant ?
END
					:update_email=><<-END,
Votre email est %{email}, souhaitez-vous le mettre à jour ?
END
					:update_email_no=><<-END,
Ok pas de souci mais n'oubliez pas que votre vote ne sera pas pris en compte tant que votre email ne sera pas validé...
END
					:update_email_yes=><<-END,
Quelle est votre adresse email ?
END
					:update_email_ok=><<-END,
Parfait ! Je viens de vous envoyer un email à %{email}. Merci de cliquer sur ce lien inclus dans cet email pour mettre à jour votre adresse email.
END
					:email_error=><<-END,
Hmmm... cet email ne semble pas valide #{Bot.emoticons[:rolling_eyes]}
Réessayons, quel est votre email ?
END
					:email_used=><<-END,
Hmmm... cet email est déjà utilisé #{Bot.emoticons[:rolling_eyes]}
Réessayons, quel est votre email ?
END
				}
			}
		}
		screens={
			:profile=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:memo]} Mon profil",
					:text=>messages[:fr][:profile][:menu],
					:kbd=>["profile/update_email","profile/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:update_email=>{
					:answer=>"#{Bot.emoticons[:envelope]} Mon email",
					:text=>messages[:fr][:profile][:update_email],
					:kbd=>["profile/update_email_yes","profile/update_email_no"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true},
					:callback=>"profile/update_email_cb"
				},
				:invalid_email=>{
					:text=>messages[:fr][:profile][:invalid_email],
					:parse_mode=>"HTML",
					:kbd=>["profile/update_email_yes","profile/update_email_no"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true},
					:callback=>"profile/invalid_email_cb"
				},
				:update_email_yes=>{
					:answer=>"#{Bot.emoticons[:envelope]} Oui",
					:text=>messages[:fr][:profile][:update_email_yes],
					:callback=>"profile/update_email_yes_cb"
				},
				:update_email_no=>{
					:answer=>"#{Bot.emoticons[:hourglass]} Plus tard",
					:text=>messages[:fr][:profile][:update_email_no],
					:jump_to=>"home/menu"
				},
				:update_email_ok=>{
					:text=>messages[:fr][:profile][:update_email_ok],
					:jump_to=>"home/menu"
				},
				:retour=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"profile/retour_cb"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"profile/menu"}}})
	end

	def profile_invalid_email_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		email= user['email'].nil? ? 'aucun email' : user['email']
		screen[:text]=screen[:text] % {:email=>email}
		return self.get_screen(screen,user,msg)
	end

	def profile_update_email_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		email= user['email'].nil? ? 'inconnu' : user['email']
		screen[:text]=screen[:text] % {:email=>email}
		return self.get_screen(screen,user,msg)
	end

	def profile_update_email_yes_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		@users.next_answer(user[:id],'free_text',1,"profile/reset_email_cb")
		return self.get_screen(screen,user,msg)
	end

	def profile_reset_email_cb(msg,user,screen)
		email=user['session']['buffer']
		Bot.log.info "#{__method__}: #{email}"
		if email.match(/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/).nil? then
			screen=self.find_by_name("profile/email_error")
			return self.get_screen(screen,user,msg) 
		end
		email=email.downcase
		res=@users.search({:by=>'email',:target=>email})
		if res.num_tuples > 0 and res[0]['user_id']!=user[:id] then
			screen=self.find_by_name("profile/email_used")
			return self.get_screen(screen,user,msg) 
		end
		@users.next_answer(user[:id],'answer')
		@users.reset_email(user[:id],email)
		screen=self.find_by_name("profile/update_email_ok")
		screen[:text]=screen[:text] % {:email=>email}
		return self.get_screen(screen,user,msg)
	end

	def profile_retour_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		from=user['session']['previous_session']['current']
		case from
		when "profile/menu"
			screen=self.find_by_name("home/menu")
		else
			screen=self.find_by_name("profile/menu")
		end
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end
end

include Profile
