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

module MesCandidats
	# is being called when the module is included
	# here you need to update the Bot with your Add-on screens and hook your entry point into the Bot's menu
	def self.included(base)
		puts "loading MesCandidats add-on" if DEBUG
		messages={
			:fr=>{
				:mes_candidats=>{
					:new=><<-END,
Quel candidat(e) souhaitez-vous soutenir ?
END
					:mes_candidats=><<-END,
Voici les candidats que vous soutenez :
END
					:empty=><<-END,
Vous n'avez encore apporté votre soutien à aucun candidat !
END
					:how=><<-END,
Vous avez la possibilité de soutenir jusqu'à 5 candidats sur LaPrimaire.org.
Vous pouvez littéralement soutenir qui vous voulez mais voici quelques conseils :
1. <b>Tout le monde peut être candidat(e)</b> (même vous !). L'objectif de LaPrimaire.org est de faire émerger les meilleurs candidat(e)s <b>d'où qu'ils/elles viennent</b>. Ne vous limitez pas aux seules personnalités politiques connues.
2. <b>Pensez "équipe"</b>. Réfléchissez aux personnes dont vous adhérez aux idées et que vous souhaiteriez voir être plus impliquées dans la vie politique de notre pays. Ne vous limitez pas à la seule recherche du prochain Président.
3. <b>Réfléchissez par thèmes</b>. Quels sont vos thématiques de prédilection et vos sujets d'expertise ? L'écologie ? L'économie ? La santé ? Proposez les personnes qui portent les idées auxquelles vous adhérez.
4. <b>Privilégiez les "faiseurs"</b>. L'action est un bon moyen pour juger de la conviction d'un candidat : Privilégiez les candidats qui s'investissent personnellement pour mettre en oeuvre les idées qu'il défendent.
5. <b>Soyez sérieux</b>. Ne proposez pas de faux candidats (fictifs, morts etc...), vous risqueriez le blocage pur et simple de votre compte.
END
					:del_ask=><<-END,
A quel candidat souhaitez-vous retirer votre soutien ?
END
					:del=><<-END,
%{name} n'a désormais plus votre soutien !
END
					:confirm=><<-END,
%{media}
Est-ce bien votre choix ?
END
					:confirm_yes=><<-END,
Parfait, c'est bien enregistré !
END
					:confirm_no=><<-END,
Hmmmm... réessayons !
END
					:real_candidate=><<-END,
Vous êtes le premier à soutenir ce candidat !
Bien qu'il vous soit possible de soutenir n'importe quel(le) candidat(e), celui ou celle-ci doit être Français(e) et éligible en France sinon il sera rejeté.
Soutenir un candidat ou une candidate fantaisiste irait à l'encontre de la charte que vous avez acceptée et vous prendriez le risque d'être exclu #{Bot.emoticons[:crying_face]}
Sachant cela, confirmez-vous votre soutien à ce candidat ? 
END
					:real_candidate_ok=><<-END,
Bien noté, merci !
END
					:real_candidate_ko=><<-END,
Merci pour votre honnêteté #{Bot.emoticons[:smile]}
END
					:gender=><<-END,
Ce candidat(e) est-il un homme ou une femme ?
END
					:gender_ok=><<-END,
Parfait, merci !
END
					:not_found=><<-END,
Malheureusement, je ne trouve personne avec ce nom #{Bot.emoticons[:crying_face]}. Pour affiner la recherche, n'hésitez pas à réessayer en ajoutant des mots-clés derrière le nom de la personne que vous souhaitez soutenir. Exemple: Prénom Nom #motclé1 #motclé2
END
					:blocked=><<-END,
Désolé mais ce candidat est inconnu et votre compte n'est plus autorisé à proposer de nouveaux candidats #{Bot.emoticons[:crying_face]}
END
					:max_reached=><<-END,
Désolé mais ce candidat est inconnu et vous avez atteint le maximum de candidats inconnus que vous pouvez proposer #{Bot.emoticons[:crying_face]}
END
					:error=><<-END,
Hmmmm.... je me suis embrouillé les pinceaux, il va falloir recommencer s'il vous plait. Désolé #{Bot.emoticons[:confused]}
END
				}
			}
		}
		screens={
			:mes_candidats=>{
				:mes_candidats=>{
					:answer=>"#{Bot.emoticons[:woman]}#{Bot.emoticons[:man]} Mes candidats",
					:text=>messages[:fr][:mes_candidats][:mes_candidats],
					:callback=>"mes_candidats/mes_candidats",
					:kbd=>["mes_candidats/new","mes_candidats/del_ask","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:empty=>{
					:text=>messages[:fr][:mes_candidats][:empty],
					:kbd_vertical=>true,
					:kbd=>["mes_candidats/new","mes_candidats/how","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:how=>{
					:answer=>"#{Bot.emoticons[:thinking_face]} Quels candidats soutenir ?",
					:text=>messages[:fr][:mes_candidats][:how],
					:disable_web_page_preview=>true,
					:parse_mode=>"HTML",
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:new=>{
					:answer=>"#{Bot.emoticons[:finger_right]} Soutenir un candidat",
					:text=>messages[:fr][:mes_candidats][:new],
					:callback=>"mes_candidats/new"
				},
				:del_ask=>{
					:answer=>"#{Bot.emoticons[:cross_mark]} Supprimer un candidat",
					:text=>messages[:fr][:mes_candidats][:del_ask],
					:callback=>"mes_candidats/del_ask",
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:del=>{
					:text=>messages[:fr][:mes_candidats][:del],
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:confirm=>{
					:text=>messages[:fr][:mes_candidats][:confirm],
					:kbd=>["mes_candidats/confirm_yes","mes_candidats/confirm_no","mes_candidats/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:confirm_yes=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Oui, je confirme mon choix",
					:text=>messages[:fr][:mes_candidats][:confirm_yes],
					:callback=>"mes_candidats/confirm_yes",
					:jump_to=>"mes_candidats/real_candidate"
				},
				:confirm_no=>{
					:answer=>"#{Bot.emoticons[:thumbs_down]} Non, ce n'est pas la bonne personne",
					:text=>messages[:fr][:mes_candidats][:confirm_no],
					:callback=>"mes_candidats/confirm_no",
					:jump_to=>"mes_candidats/confirm"
				},
				:real_candidate=>{
					:text=>messages[:fr][:mes_candidats][:real_candidate],
					:kbd=>["mes_candidats/real_candidate_ok","mes_candidats/real_candidate_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:real_candidate_ok=>{
					:answer=>"Je confirme mon soutien",
					:text=>messages[:fr][:mes_candidats][:real_candidate_ok],
					:real=>true,
					:callback=>"mes_candidats/real_candidate_cb",
					:jump_to=>"mes_candidats/gender"
				},
				:real_candidate_ko=>{
					:answer=>"Je retire mon soutien",
					:text=>messages[:fr][:mes_candidats][:real_candidate_ko],
					:real=>false,
					:callback=>"mes_candidats/real_candidate_cb",
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:gender=>{
					:text=>messages[:fr][:mes_candidats][:gender],
					:kbd=>["mes_candidats/gender_man","mes_candidats/gender_woman"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:gender_man=>{
					:answer=>"#{Bot.emoticons[:man]} un homme",
					:text=>messages[:fr][:mes_candidats][:gender_ok],
					:man=>true,
					:callback=>"mes_candidats/gender_cb",
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:gender_woman=>{
					:answer=>"#{Bot.emoticons[:woman]} une femme",
					:text=>messages[:fr][:mes_candidats][:gender_ok],
					:woman=>true,
					:callback=>"mes_candidats/gender_cb",
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:back=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"mes_candidats/back",
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:not_found=>{
					:text=>messages[:fr][:mes_candidats][:not_found],
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:blocked=>{
					:text=>messages[:fr][:mes_candidats][:blocked],
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:max_reached=>{
					:text=>messages[:fr][:mes_candidats][:max_reached],
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:error=>{
					:text=>messages[:fr][:mes_candidats][:error],
					:jump_to=>"mes_candidats/mes_candidats"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"mes_candidats/mes_candidats"}}})
	end

	def mes_candidats_mes_candidats(msg,user,screen)
		puts "mes_candidats_mes_candidats" if DEBUG
		res=@candidates.supported_by(user[:id])
		res.each_with_index do |r,i|
			name=r['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
			i+=1
			fig="nb_"+i.to_s
			screen[:text]+="* #{name} (<a href='https://laprimaire.org/candidat/#{r['candidate_id']}'>voir sa page</a>)\n"
			screen[:parse_mode]='HTML'
		end
		if res.num_tuples<1 then # no candidates supported yet
			screen=self.find_by_name("mes_candidats/empty")
		elsif res.num_tuples>4 then # not allowed to chose more candidates
			screen[:kbd_del]=["mes_candidats/new"]
			screen[:text]+="Vous avez atteint le nombre maximum de candidats que vous pouvez soutenir (5). Si vous voulez soutenir un autre candidat, vous devez au préalable retirer votre soutien à l'un des candidats ci-dessus.\n"
		end
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_back(msg,user,screen)
		puts "mes_candidats_back" if DEBUG
		@users.next_answer(user[:id],'answer')
		@users.clear_session(user[:id],'candidate')
		@users.clear_session(user[:id],'delete_candidates')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_new(msg,user,screen)
		puts "mes_candidats_new" if DEBUG
		@users.next_answer(user[:id],'free_text',1,"mes_candidats/search")
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_search(msg,user,screen)
		# immediately send a message to acknowledge we got the request as the search might take time
		Democratech::LaPrimaireBot.tg_client.api.sendChatAction(chat_id: user[:id], action: "typing")
		Democratech::LaPrimaireBot.tg_client.api.sendMessage({
			:chat_id=>user[:id],
			:text=>"Ok, je recherche...",
			:reply_markup=>nil
		})
		candidate=user['session']['candidate']
		name=candidate ? candidate["name"] : user['session']['buffer']
		puts "mes_candidats_search : #{name}" if DEBUG
		return self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) if not name
		screen=self.find_by_name("mes_candidats/confirm")
		res=@candidates.search_index(name) if candidate.nil?
		@users.next_answer(user[:id],'answer')
		if candidate.nil? and res['hits'].length>0  then
			puts "mes_candidats_search: index hit" if DEBUG
			candidate=res['hits'][0]
			photo=CANDIDATS_DIR+candidate['photo']
			@users.update_session(user[:id],{'candidate'=>candidate})
		else
			puts "mes_candidats_search: web" if DEBUG
			tags=name.scan(/#(\w+)/).flatten
			name=name.gsub(/#\w+/,'').strip if tags
			if name and tags then
				tmp=name+" "+tags.join(' ')
				images = @web.search_image(name+" "+tags.join(' '))
			elsif name
				images = @web.search_image(name)
			end
			idx=candidate.nil? ? 0 : candidate['idx']
			img,type=images[idx]
			return self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) if images.empty? or images[idx].nil?
			web_img=MiniMagick::Image.open(img.link)
			web_img.resize "x300"
			photo=TMP_DIR+'image'+user[:id].to_s+"."+type
			web_img.write(photo)
			idx+=1
			@users.update_session(user[:id],{'candidate'=>{'name'=>name,'photo'=>photo,'idx'=>idx}})
			retry_screen=self.find_by_name("mes_candidats/confirm_no")
			screen[:text]=retry_screen[:text]+screen[:text] if candidate
		end
		screen[:text]=screen[:text] % {media:"image:"+photo}
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_confirm_no(msg,user,screen)
		candidate=user['session']['candidate']
		puts "mes_candidats_confirm_no : #{candidate}" if DEBUG
		image=candidate['photo']
		File.delete(image) if File.exists?(image)
		idx=candidate['idx'].nil? ? 1 : candidate['idx']
		return idx==4 ? self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) : mes_candidats_search(msg,user,screen)
	end

	def mes_candidats_confirm_yes(msg,user,screen)
		candidate=user['session']['candidate']
		puts "mes_candidats_confirm_yes : #{candidate}" if DEBUG
		if candidate then
			if candidate['candidate_id'] then # candidate already exists in db
				res=@candidates.search({:by=>'candidate_id',:target=>candidate['candidate_id']})
				@candidates.add(candidate) if res.num_tuples.zero? # candidate in index but not in db (weird case)
				@candidates.add_supporter(user[:id],candidate['candidate_id'])
				screen=self.find_by_name("mes_candidats/mes_candidats")
			elsif user['settings']['blocked']['add_candidate'] # user is forbidden to add new candidates
				screen=self.find_by_name("mes_candidats/blocked")
				File.delete(image) if File.exists?(image)
			elsif user['settings']['limits']['candidate_proposals'].to_i<=user['settings']['actions']['nb_candidates_proposed'].to_i # user has already added the maximum candidates he could add
				screen=self.find_by_name("mes_candidats/max_reached")
				File.delete(image) if File.exists?(image)
			else # candidate needs to be registered in db
				image=candidate['photo']
				candidate=@candidates.add(candidate)
				nb_candidates_proposed=user['settings']['actions']['nb_candidates_proposed']+1
				@users.update_settings(user[:id],{'actions'=>{'nb_candidates_proposed'=>nb_candidates_proposed}})
				user['session']['candidate']['candidate_id']=candidate['candidate_id']
				FileUtils.mv(image,CANDIDATS_DIR+candidate['photo'])
				@candidates.add_supporter(user[:id],candidate['candidate_id'])
			end
		else
			screen=self.find_by_name("mes_candidats/error")
		end
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_real_candidate_cb(msg,user,screen)
		candidate=user['session']['candidate']
		puts "mes_candidates_real_candidate_cb : #{candidate}"
		real_candidate = screen[:real]
		if not real_candidate then
			@candidates.delete(candidate['candidate_id'])
			File.delete(CANDIDATS_DIR+candidate['photo']) if File.exists?(CANDIDATS_DIR+candidate['photo'])
		else
			slack_msg="Nouveau candidat(e) proposé(e) : #{candidate['name']} (<https://laprimaire.org/candidat/#{candidate['candidate_id']}|voir sa page>)"
			Bot.slack_notification(slack_msg,"candidats",":man:","LaPrimaire.org")
			Democratech::LaPrimaireBot.mixpanel.track(user[:id],'new_candidate_supported',{'name'=>candidate['name']})
			Democratech::LaPrimaireBot.mixpanel.people.increment(user[:id],{'nb_candidates_proposed'=>1})
		end
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_gender_cb(msg,user,screen)
		candidate=user['session']['candidate']
		gender = screen[:man] ? 'M':'F'
		@candidates.set(candidate['candidate_id'],{:set=> 'gender',:value=> gender})
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_del_ask(msg,user,screen)
		puts "mes_candidats_del_ask" if DEBUG
		res=@candidates.supported_by(user[:id])
		return self.get_screen(self.find_by_name("mes_candidats/error"),user,msg) if res.num_tuples.zero?
		@users.clear_session(user[:id],'delete_candidates')
		screen[:kbd_add]=[]
		candidates_list={}
		res.each_with_index do |r,i|
			i+=1
			name=r['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
			screen[:kbd_add].push(i.to_s+". "+name)
			candidates_list[i.to_s]={'candidate_id'=>r['candidate_id'],'name'=>name}
		end
		@users.update_session(user[:id],{'delete_candidates'=>candidates_list})
		@users.next_answer(user[:id],'free_text',1,"mes_candidats/del")
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_del(msg,user,screen)
		buffer=user['session']['buffer']
		puts "mes_candidats_del : #{buffer}" if DEBUG
		return self.get_screen(self.find_by_name("mes_candidats/error"),user,msg) unless buffer
		idx,name=buffer.split('. ')
		name=name.strip.split(' ').each{|n| n.capitalize!}.join(' ') if name
		candidate_id=user['session']['delete_candidates'][idx]['candidate_id'].to_i
		@candidates.remove_supporter(user[:id],candidate_id)
		@users.clear_session(user[:id],'delete_candidates')
		@users.next_answer(user[:id],'answer')
		screen[:text]=screen[:text] % {name:name} 
		return self.get_screen(screen,user,msg)
	end
end

include MesCandidats
