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

module Admin
	def self.included(base)
		Bot.log.info "loading Admin add-on"
		messages={
			:fr=>{
				:admin=>{
					:menu=>"Bienvenue dans l'admin, que souhaitez-vous faire ?",
					:inconnu=><<-END,
Malheureusement, je ne trouve aucun(e) candidat(e) avec ce nom #{Bot.emoticons[:crying_face]}. Etes-vous certain que la personne que vous cherchez est officiellement candidate ?
END
					:forbidden=><<-END,
Vous n'avez pas accès à cette fonctionnalité, désolé !
END
					:too_large=><<-END,
Votre recherche n'est pas assez précise, soyez plus précis s'il vous plaît !
END
					:chercher_candidat=><<-END,
Quel(le) candidat(e) cherchez-vous ? (ou tapez '/start' pour revenir au menu)
END
					:show=><<-END,
%{name} - %{soutiens_txt} - %{status} - <a href='https://laprimaire.org/admin/%{candidate_key}'>page d'administration</a>
END
					:chercher_candidat_ask=><<-END,
Plusieurs candidat(e)s correspondent à votre recherche, lequel cherchez-vous ?
END
				}
			}
		}
		screens={
			:admin=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:police_officer]} Admin",
					:text=>messages[:fr][:admin][:menu],
					:kbd=>["admin/chercher_candidat","admin/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:chercher_candidat=>{
					:answer=>"#{Bot.emoticons[:loupe]} Chercher un candidat",
					:text=>messages[:fr][:admin][:chercher_candidat],
					:callback=>"admin/chercher_candidat_cb"
				},
				:unverify_candidate=>{
					:answer=>"#{Bot.emoticons[:hourglass]} Suspendre",
					:callback=>"admin/unverify_candidate_cb",
					:jump_to=>"admin/show"
				},
				:accept_candidate=>{
					:answer=>"#{Bot.emoticons[:rocket]} Mettre en ligne",
					:callback=>"admin/accept_candidate_cb",
					:jump_to=>"admin/show"
				},
				:retour=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"admin/retour_cb"
				},
				:forbidden=>{
					:text=>messages[:fr][:admin][:forbidden],
					:jump_to=>"home/menu"
				},
				:inconnu=>{
					:text=>messages[:fr][:admin][:inconnu],
					:jump_to=>"admin/chercher_candidat"
				},
				:too_large=>{
					:text=>messages[:fr][:admin][:too_large],
					:jump_to=>"admin/chercher_candidat"
				},
				:show=>{
					:text=>messages[:fr][:admin][:show],
					:kbd=>["admin/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:chercher_candidat_ask=>{
					:text=>messages[:fr][:admin][:chercher_candidat_ask],
					:kbd=>["admin/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"admin/menu"}}})
	end

	def admin_chercher_candidat_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		return self.get_screen(self.find_by_name("admin/forbidden"),user,msg) if not ADMINS.include?(user[:id])
		@users.next_answer(user[:id],'free_text',1,"admin/trouver_candidat_cb")
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def admin_trouver_candidat_cb(msg,user,screen)
		candidate=user['session']['candidate']
		name=candidate ? candidate["name"] : user['session']['buffer']
		Bot.log.info "#{__method__} : #{name}"
		return self.get_screen(self.find_by_name("admin/forbidden"),user,msg) if not ADMINS.include?(user[:id])
		return self.get_screen(self.find_by_name("admin/inconnu"),user,msg) if not name
		return self.get_screen(self.find_by_name("admin/too_large"),user,msg) if name.length<4
		# immediately send a message to acknowledge we got the request as the search might take time
		Democratech::TelegramBot.client.api.sendChatAction(chat_id: user[:id], action: "typing")
		Democratech::TelegramBot.client.api.sendMessage({
			:chat_id=>user[:id],
			:text=>"Ok, je recherche...",
			:reply_markup=>Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
		})
		res=@candidates.search_candidate_db(name) if candidate.nil?
		nb_results=res.num_tuples
		return self.get_screen(self.find_by_name("admin/inconnu"),user,msg) if nb_results==0
		return self.get_screen(self.find_by_name("admin/too_large"),user,msg) if nb_results>5
		@users.next_answer(user[:id],'answer')
		if nb_results==1 then
			screen=self.find_by_name("admin/show")
			return self.admin_show(msg,user,screen,res[0])
		else
			screen=self.find_by_name("admin/chercher_candidat_ask")
			candidates_list={}
			screen[:kbd_add]=[]
			res.each_with_index do |r,i|
				name=r['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
				i+=1
				screen[:kbd_add].push(i.to_s+". "+name)
				candidates_list[i.to_s]={'candidate_id'=>r['candidate_id'],'name'=>name}
			end
			@users.update_session(user[:id],{'see_candidates'=>candidates_list})
			@users.next_answer(user[:id],'free_text',1,"admin/show")
		end
		return self.get_screen(screen,user,msg)
	end

	def admin_show(msg,user,screen,candidate=nil)
		Bot.log.info "#{__method__}"
		return self.get_screen(self.find_by_name("admin/forbidden"),user,msg) if not ADMINS.include?(user[:id])
		if candidate.nil? then
			buffer=user['session']['buffer']
			return self.get_screen(self.find_by_name("admin/error"),user,msg) unless buffer
			if buffer.match(/\d\./).nil? then
				@users.next_answer(user[:id],'answer')
				@users.clear_session(user[:id],'see_candidates')
				return self.get_screen(self.find_by_name("admin/menu"),user,msg) 
			end
			idx,name=buffer.split('. ')
			name=name.strip.split(' ').each{|n| n.capitalize!}.join(' ') if name
			candidate_id=user['session']['see_candidates'][idx]['candidate_id'].to_i
		else
			candidate_id=candidate['candidate_id']
		end
		candidate=@candidates.find(candidate_id,user[:id])
		verified=candidate['verified']
		name=candidate['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
		soutiens=candidate['nb_soutiens'].to_i
		soutiens_txt= soutiens>1 ? "#{soutiens} soutiens" : "#{soutiens} soutien"
		screen[:kbd_add]=[]
		if verified.to_b then
			status_txt="candidature validée #{Bot.emoticons[:rocket]}"
			screen[:kbd_add].push(@screens[:admin][:unverify_candidate][:answer])
		else
			status_txt="en attente de validation #{Bot.emoticons[:hourglass]}"
			screen[:kbd_add].push(@screens[:admin][:accept_candidate][:answer])
		end
		screen[:text]=screen[:text] % {name: name, candidate_key: candidate['candidate_key'], soutiens_txt: soutiens_txt, status: status_txt}
		screen[:parse_mode]='HTML'
		@users.update_session(user[:id],{'candidate'=>candidate})
		@users.clear_session(user[:id],'see_candidates')
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end

	def admin_unverify_candidate_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		return self.get_screen(self.find_by_name("admin/forbidden"),user,msg) if not ADMINS.include?(user[:id])
		candidate=user['session']['candidate']
		@candidates.unverify(candidate['candidate_id'])
		screen=self.find_by_name("admin/show")
		return self.admin_show(msg,user,screen,candidate)
	end

	def admin_accept_candidate_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		return self.get_screen(self.find_by_name("admin/forbidden"),user,msg) if not ADMINS.include?(user[:id])
		candidate=user['session']['candidate']
		@candidates.accept(candidate['candidate_id'])
		screen=self.find_by_name("admin/show")
		return self.admin_show(msg,user,screen,candidate)
	end

	def admin_retour_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		from=user['session']['previous_session']['current']
		case from
		when "admin/menu"
			screen=self.find_by_name("home/menu")
		else
			@users.clear_session(user[:id],'candidate')
			screen=self.find_by_name("admin/menu")
		end
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end
end

include Admin
