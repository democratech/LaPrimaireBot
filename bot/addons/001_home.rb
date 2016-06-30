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

module Home
	def self.included(base)
		Bot.log.info "loading Home add-on"
		messages={
			:fr=>{
				:home=>{
					:welcome=><<-END,
Bonjour %{firstname} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
Mon rôle est de vous accompagner et de vous informer tout au long du déroulement de La Primaire.
Mais assez discuté, commençons !
END
					:menu=><<-END,
Que voulez-vous faire ? Utilisez les boutons du menu ci-dessous pour m'indiquer ce que vous souhaitez faire.
END
					:abuse=><<-END,
Désolé votre comportement sur LaPrimaire.org est en violation de la Charte que vous avez acceptée et a entraîné votre exclusion  #{Bot.emoticons[:crying_face]}
END
					:not_allowed=><<-END,
Désolé mais au vu des informations que vous nous avez fournies, vous ne remplissez pas les conditions pour pouvoir participer à LaPrimaire.org #{Bot.emoticons[:crying_face]}
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
					:parse_mode=>"HTML",
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:abuse=>{
					:text=>messages[:fr][:home][:abuse],
					:disable_web_page_preview=>true
				},
				:not_allowed=>{
					:text=>messages[:fr][:home][:not_allowed],
					:disable_web_page_preview=>true
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"home/menu"}}})
	end

	def home_welcome(msg,user,screen)
		Bot.log.info "#{__method__}"
		betatester=user['settings']['roles']['betatester'].to_b
		can_vote=user['settings']['legal']['can_vote'].to_b
		abuse=user['settings']['blocked']['abuse']
		not_allowed=user['settings']['blocked']['not_allowed']
		if abuse then
			screen=self.find_by_name("home/abuse")
		elsif not_allowed then
			screen=self.find_by_name("home/not_allowed")
		elsif not (can_vote and user['email'] and user['city'] and user['country']) then
			screen=self.find_by_name("welcome/hello")
		elsif user['email'].nil? or user['email'].empty?
			screen=self.find_by_name("welcome/email")
		elsif user['email_status'].to_i==-2
			@users.next_answer(user[:id],'answer')
			screen=self.find_by_name("profile/invalid_email")
		else
			screen=self.find_by_name("home/menu")
			screen[:kbd_del]=["home/menu"]
			screen[:kbd_del].push("admin/menu") unless ADMINS.include?(user[:id])
		end
		return self.get_screen(screen,user,msg)
	end

	def home_menu(msg,user,screen)
		Bot.log.info "#{__method__}"
		return self.get_screen(self.find_by_name("profile/invalid_email"),user,msg) if user['email_status']==-2
		screen[:kbd_del]=["home/menu"]
		screen[:kbd_del].push("admin/menu") unless ADMINS.include?(user[:id])
		@users.next_answer(user[:id],'answer')
		@users.clear_session(user[:id],'candidate')
		@users.clear_session(user[:id],'delete_candidates')
		return self.get_screen(screen,user,msg)
	end
end

include Home
