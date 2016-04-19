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

module SoutenirCandidat
	# is being called when the module is included
	# here you need to update the Bot with your Add-on screens and hook your entry point into the Bot's menu
	def self.included(base)
		Bot.log.info "loading SoutenirCandidat add-on"
		messages={
			:fr=>{
				:soutenir_candidat=>{
					:menu=><<-END,
Comment s'appelle le candidat ou la candidate que vous souhaitez soutenir ?
END
					:inconnu=><<-END,
Malheureusement, je ne trouve aucun(e) candidat(e) avec ce nom #{Bot.emoticons[:crying_face]}. Etes-vous certain que la personne que vous cherchez est officiellement candidate ?
END
					:recherche_trop_large=><<-END,
Votre recherche n'est pas assez précise, soyez plus précis s'il vous plaît !
END
				}
			}
		}
		screens={
			:soutenir_candidat=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Soutenir un candidat",
					:text=>messages[:fr][:soutenir_candidat][:menu],
					:callback=>"soutenir_candidat/menu_cb",
					:kbd=>["soutenir_candidat/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:retour=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"soutenir_candidat/retour_cb"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"soutenir_candidat/menu"}}})
	end

	def soutenir_candidat_menu_cb(msg,user,screen)
		@users.next_answer(user[:id],'free_text',1,"soutenir_candidat/trouver_candidat_cb")
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_trouver_candidat_cb(msg,user,screen)
		candidate=user['session']['candidate']
		name=candidate ? candidate["name"] : user['session']['buffer']
		Bot.log.info "mes_candidats_trouver_candidat_cb : #{name}"
		return self.get_screen(self.find_by_name("home/menu"),user,msg) if name==@screens[:soutenir_candidat][:retour][:answer]
		return self.get_screen(self.find_by_name("soutenir_candidat/inconnu"),user,msg) if not name
		return self.get_screen(self.find_by_name("soutenir_candidat/recherche_trop_large"),user,msg) if name.length<4
		# immediately send a message to acknowledge we got the request as the search might take time
		Democratech::TelegramBot.client.api.sendChatAction(chat_id: user[:id], action: "typing")
		Democratech::TelegramBot.client.api.sendMessage({
			:chat_id=>user[:id],
			:text=>"Ok, je recherche...",
			:reply_markup=>Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
		})
		res=@candidates.search_candidate(name) if candidate.nil?
		return self.get_screen(self.find_by_name("soutenir_candidat/inconnu"),user,msg) if res.num_tuples.zero?
		return self.get_screen(self.find_by_name("soutenir_candidat/recherche_trop_large"),user,msg) if res.num_tuples>5
		@users.next_answer(user[:id],'answer')
		if res.num_tuples==1 then
			screen=self.find_by_name("mes_candidats/show")
			return self.mes_candidats_show(msg,user,screen,res[0])
		else
			screen=self.find_by_name("mes_candidats/chercher_candidat_ask")
			candidates_list={}
			screen[:kbd_add]=[]
			res.each_with_index do |r,i|
				name=r['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
				i+=1
				screen[:kbd_add].push(i.to_s+". "+name)
				candidates_list[i.to_s]={'candidate_id'=>r['candidate_id'],'name'=>name}
			end
			@users.update_session(user[:id],{'delete_candidates'=>candidates_list})
			@users.next_answer(user[:id],'free_text',1,"mes_candidats/show")
		end
		return self.get_screen(screen,user,msg)
	end


	def soutenir_candidat_back_cb(msg,user,screen)
		Bot.log.info "soutenir_candidat_back_cb"
		from=user['session']['previous_session']['current']
		case from
		when "soutenir_candidat/menu"
			screen=self.find_by_name("home/menu")
		end
		@users.next_answer(user[:id],'answer')
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end
end

include SoutenirCandidat
