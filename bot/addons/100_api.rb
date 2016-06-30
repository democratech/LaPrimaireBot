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

module Api
	def self.included(base)
		Bot.log.info "loading Api add-on"
		messages={
			:fr=>{
				:api=>{
					:access_granted=><<-END,
Bonne nouvelle %{firstname}, vous avez désormais accès à LaPrimaire.org... c'est reparti ! #{Bot.emoticons[:face_sunglasses]}
END
					:allow_user=><<-END,
Bonne nouvelle %{firstname}, votre accès à LaPrimaire.org a été réinitialisé... c'est reparti ! #{Bot.emoticons[:face_sunglasses]}
END
					:unblock_user=><<-END,
Bonne nouvelle %{firstname}, votre accès à LaPrimaire.org a été rétabli... c'est reparti ! #{Bot.emoticons[:face_sunglasses]}
END
					:block_candidate_reviews=><<-END,
%{firstname}, il semblerait que vous ne soyez pas très doué pour noter les candidats ou alors que vous ne les notez pas assez sérieusement. En effet, vous avez accepté des fausses candidatures et/ou rejeté des vraies candidatures. Je dois donc suspendre votre capacité à noter les candidats #{Bot.emoticons[:crying_face]}
END
					:block_candidate_proposals=><<-END,
%{firstname}, parmi les candidats que vous avez proposés, un nombre trop important était de faux candidats. Je suis donc dans l'obligation de suspendre votre capacité à proposer de nouveaux candidats #{Bot.emoticons[:crying_face]}
END
					:ban_user=><<-END,
%{firstname}, votre comportement sur LaPrimaire.org est en violation de la Charte que vous avez acceptée. En conséquence, je suis donc dans l'obligation de suspendre votre compte #{Bot.emoticons[:crying_face]}
END
					:reset_user=><<-END,
%{firstname}, votre compte vient d'être remis à zéro. Tapez /start pour continuer.
END
					:bot_upgrade=><<-END,
Ah, il semblerait que j'ai été mise à jour depuis la dernière fois que nous avons discuté, revenons au menu principal pour que je puisse appliquer la mise à jour automatiquement...
END
					:broadcast=><<-END,
Excusez-moi pour cette interruption mais je viens de recevoir le message suivant de la part de LaPrimaire.org qu'on m'a chargé de vous transmettre :
"%{broadcast_msg}"
Cliquez sur le bouton "#{Bot.emoticons[:back]} Retour" dès que vous souhaitez reprendre où vous en étiez.
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
				},
				:allow_user=>{
					:text=>messages[:fr][:api][:allow_user],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:ban_user=>{
					:text=>messages[:fr][:api][:ban_user],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:reset_user=>{
					:text=>messages[:fr][:api][:reset_user],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:bot_upgrade=>{
					:text=>messages[:fr][:api][:bot_upgrade],
					:disable_web_page_preview=>true,
					:callback=>"api/bot_upgrade",
					:jump_to=>"home/welcome"
				},
				:unblock_user=>{
					:text=>messages[:fr][:api][:unblock_user],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:block_candidate_reviews=>{
					:text=>messages[:fr][:api][:block_candidate_reviews],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:block_candidate_proposals=>{
					:text=>messages[:fr][:api][:block_candidate_proposals],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:broadcast=>{
					:text=>messages[:fr][:api][:broadcast],
					:save_session=>true,
					:disable_web_page_preview=>true,
					:kbd=>["api/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true},
					:callback=>"api/broadcast"
				},
				:back=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"api/broadcast"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def api_access_granted(msg,user,screen)
		Bot.log.info "api_access_granted"
		@users.remove_from_waiting_list(user)
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'api_grant_beta_access')
		return self.get_screen(screen,user,msg)
	end

	def api_allow_user(msg,user,screen)
		Bot.log.info "api_allow_user"
		@users.update_settings(user[:id],{'blocked'=>{'not_allowed'=>false }})
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'api_reallow_user')
		return self.get_screen(screen,user,msg)
	end

	def api_block_candidate_proposals(msg,user,screen)
		Bot.log.info "api_block_candidate_proposals"
		@users.update_settings(user[:id],{'blocked'=>{'add_candidate'=>true }})
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'api_block_add_candidate')
		return self.get_screen(screen,user,msg)
	end

	def api_block_candidate_reviews(msg,user,screen)
		Bot.log.info "api_block_candidate_reviews"
		@users.update_settings(user[:id],{'blocked'=>{'reviews'=>true }})
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'api_block_candidate_reviews')
		return self.get_screen(screen,user,msg)
	end

	def api_ban_user(msg,user,screen)
		Bot.log.info "api_ban_user"
		@users.update_settings(user[:id],{'blocked'=>{'abuse'=>true }})
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'api_ban_user')
		return self.get_screen(screen,user,msg)
	end

	def api_reset_user(msg,user,screen)
		Bot.log.info "api_reset_user"
		@users.reset(user)
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'api_reset_user')
		return self.get_screen(screen,user,msg)
	end

	def api_bot_upgrade(msg,user,screen)
		Bot.log.info "#{__method__}"
		@users.bot_upgrade_completed(user[:id])
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end

	def api_unblock_user(msg,user,screen)
		Bot.log.info "api_unblock_user"
		@users.update_settings(user[:id],{'blocked'=>{
			'add_candidate'=>false,
			'abuse'=>false,
			'not_allowed'=>false,
			'review'=>false
		}})
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'api_unblock_user')
		return self.get_screen(screen,user,msg)
	end

	def api_broadcast(msg,user,screen)
		Bot.log.info "api_broadcast"
		if screen[:save_session] then
			current= user['session']['current'].nil? ? "home/welcome" :user['session']['current']
			broadcast_msg=user['session']['api_payload']
			previous_screen=self.find_by_name(current)
			@users.next_answer(user[:id],'answer')
			@users.clear_session(user[:id],'api_payload')
			screen[:text]=screen[:text] % {broadcast_msg: broadcast_msg}
		else
			screen=@users.previous_state(user[:id])
			screen=self.find_by_name("home/welcome") if screen.nil?
			if !screen[:text].nil? and !screen[:text].empty? then
				screen[:text]="Merci pour votre attention ! Reprenons...\n"+screen[:text]
			else
				screen[:text]="Merci pour votre attention ! Reprenons..."
			end
		end
		return self.get_screen(screen,user,msg)
	end
end

include Api
