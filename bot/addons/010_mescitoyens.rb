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

module MesCitoyens
	# is being called when the module is included
	# here you need to update the Bot with your Add-on screens and hook your entry point into the Bot's menu
	def self.included(base)
		puts "loading MesCitoyens add-on" if DEBUG
		messages={
			:fr=>{
				:mes_citoyens=>{
					:menu=><<-END,
no_preview:Voici les citoyens que vous aimeriez voir se présenter en tant que candidat sur LaPrimaire.org :
END
					:new=><<-END,
no_preview:Vous avez à l'esprit un(e) citoyen(e) qui devrait participer activement à la vie politique du pays ? Quels sont ses nom et prénom ?
END
					:empty=><<-END,
Pour le moment, vous n'avez proposé aucun(e) citoyen(ne).
no_preview:Si vous avez en tête un(e) citoyen(ne) dont , dites-le nous :
* <b>#{Bot.emoticons[:speech_balloon]} Proposer un citoyen</b> : Plébisciter les citoyen(ne)s que vous appréciez et dont les compétences seraient utiles pour construire l'avenir du pays. Nous démarcherons activement les citoyens les plus plébiscités pour les convaincre de devenir officiellement candidats !
END
					:how=><<-END,
Vous avez la possibilité de proposer jusqu'à 5 citoyens que vous aimeriez voir se porter candidat sur LaPrimaire.org.
Vous pouvez proposer qui vous souhaitez, mais voici quelques conseils :
1. <b>N'importe quel citoyen peut être candidat(e)</b> (même vous !). L'objectif de LaPrimaire.org est de faire émerger les meilleurs candidat(e)s <b>d'où qu'ils/elles viennent</b>. Ne vous limitez pas aux seules personnalités politiques connues.
2. <b>Pensez "équipe"</b>. Réfléchissez aux personnes dont les idées emportent votre adhésion et que vous souhaiteriez voir être plus impliquées dans la vie politique de notre pays. Ne vous limitez pas à la seule recherche du prochain Président.
3. <b>Réfléchissez par thèmes</b>. Quels sont vos thématiques de prédilection et vos sujets d'expertise ? L'écologie ? L'économie ? La santé ? L'éducation ? L'emploi ? Proposez les personnes qui portent les idées auxquelles vous adhérez.
4. <b>Privilégiez celles et ceux qui "font"</b>. L'action est un bon moyen pour juger de la conviction d'un(e) candidat(e) : Privilégiez les candidat(e)s qui s'investissent personnellement pour mettre en oeuvre les idées qu'ils/elles défendent.
5. <b>Soyez sérieux</b>. Ne proposez pas de faux candidats (fictifs, décédés, etc.), vous risqueriez le blocage pur et simple de votre compte.
END
					:del_ask=><<-END,
Quel citoyen souhaitez-vous retirer de votre liste ?
END
					:del=><<-END,
Bien noté ! %{name} a été supprimé de votre liste
END
					:confirm=><<-END,
%{media}
Est-ce bien votre choix ?
END
					:confirm_yes=><<-END,
Parfait, c'est bien enregistré
END
					:confirm_no=><<-END,
Hmmmm... réessayons !
END
					:real_candidate=><<-END,
Vous êtes le premier à proposer ce citoyen !
Bien qu'il vous soit possible de soutenir n'importe quel(le) citoyen(ne), celui ou celle-ci doit être Français(e) et éligible en France sinon il/elle sera rejeté(e).
Soutenir un(e) citoyen(ne) fantaisiste irait à l'encontre de la Charte que vous avez acceptée et vous prendriez le risque d'être exclu #{Bot.emoticons[:crying_face]}
Sachant cela, confirmez-vous vouloir proposer ce(tte) citoyen(ne) ? 
END
					:real_candidate_ok=><<-END,
Bien noté, merci !
END
					:real_candidate_ko=><<-END,
Merci pour votre honnêteté #{Bot.emoticons[:smile]}
END
					:gender=><<-END,
Ce citoyen(ne) est-il un homme ou une femme ?
END
					:gender_ok=><<-END,
Parfait, merci !
END
					:not_found=><<-END,
Malheureusement, je ne trouve personne avec ce nom #{Bot.emoticons[:crying_face]}. Pour affiner la recherche, n'hésitez pas à réessayer en ajoutant des mots-clés derrière le nom de la personne que vous souhaitez soutenir. Exemple: Prénom Nom #motclé1 #motclé2
END
					:blocked=><<-END,
Désolé mais ce citoyen n'a encore jamais été proposé et votre compte n'est plus autorisé à proposer de nouveaux citoyens #{Bot.emoticons[:crying_face]}
END
					:max_reached=><<-END,
Désolé mais ce citoyen n'a encore jamais été proposé et vous avez atteint le nombre maximum de citoyens que vous pouvez proposer #{Bot.emoticons[:crying_face]}
END
					:error=><<-END,
Hmmmm.... je n'ai pas compris, il va falloir recommencer s'il vous plaît. Désolé #{Bot.emoticons[:confused]}
END
					:already_candidate=><<-END,
no_preview:Bonne nouvelle ! %{name} est déjà officiellement %{candidat} sur LaPrimaire.org, vous pouvez d'ores et déjà aller soutenir sa candidature. 
END
					:use_keyboard=><<-END,
Désolé, je n'ai pas compris qui vous souhaitiez supprimer de votre liste... utilisez les boutons du clavier pour choisir le ou la candidate que vous souhaitez supprimer s'il vous plaît.
END
				}
			}
		}
		screens={
			:mes_citoyens=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:speech_balloon]} Proposer un candidat",
					:text=>messages[:fr][:mes_citoyens][:menu],
					:callback=>"mes_citoyens/menu_cb",
					:kbd=>["mes_citoyens/new","mes_citoyens/del_ask","mes_citoyens/how","moi_candidat/menu","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:empty=>{
					:text=>messages[:fr][:mes_citoyens][:empty],
					:parse_mode=>"HTML",
					:kbd=>["mes_citoyens/new","mes_citoyens/how","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:how=>{
					:answer=>"#{Bot.emoticons[:thinking_face]} Qui proposer ?",
					:text=>messages[:fr][:mes_citoyens][:how],
					:disable_web_page_preview=>true,
					:parse_mode=>"HTML",
					:kbd=>["mes_citoyens/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:new=>{
					:answer=>"#{Bot.emoticons[:speech_balloon]} Proposer un citoyen",
					:text=>messages[:fr][:mes_citoyens][:new],
					:callback=>"mes_citoyens/new"
				},
				:del_ask=>{
					:answer=>"#{Bot.emoticons[:cross_mark]} Supprimer",
					:text=>messages[:fr][:mes_citoyens][:del_ask],
					:callback=>"mes_citoyens/del_ask",
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:del=>{
					:text=>messages[:fr][:mes_citoyens][:del],
					:jump_to=>"mes_citoyens/menu"
				},
				:confirm=>{
					:text=>messages[:fr][:mes_citoyens][:confirm],
					:kbd=>["mes_citoyens/confirm_yes","mes_citoyens/confirm_no","mes_citoyens/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:confirm_yes=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Oui, c'est mon choix",
					:text=>messages[:fr][:mes_citoyens][:confirm_yes],
					:callback=>"mes_citoyens/confirm_yes",
					:jump_to=>"mes_citoyens/real_candidate"
				},
				:confirm_no=>{
					:answer=>"#{Bot.emoticons[:thumbs_down]} Non, mauvaise personne",
					:text=>messages[:fr][:mes_citoyens][:confirm_no],
					:callback=>"mes_citoyens/confirm_no",
					:jump_to=>"mes_citoyens/confirm"
				},
				:real_candidate=>{
					:text=>messages[:fr][:mes_citoyens][:real_candidate],
					:kbd=>["mes_citoyens/real_candidate_ok","mes_citoyens/real_candidate_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:real_candidate_ok=>{
					:answer=>"Oui je confirme",
					:text=>messages[:fr][:mes_citoyens][:real_candidate_ok],
					:real=>true,
					:callback=>"mes_citoyens/real_candidate_cb",
					:jump_to=>"mes_citoyens/gender"
				},
				:real_candidate_ko=>{
					:answer=>"Non je ne confirme pas",
					:text=>messages[:fr][:mes_citoyens][:real_candidate_ko],
					:real=>false,
					:callback=>"mes_citoyens/real_candidate_cb",
					:jump_to=>"mes_citoyens/menu"
				},
				:gender=>{
					:text=>messages[:fr][:mes_citoyens][:gender],
					:kbd=>["mes_citoyens/gender_man","mes_citoyens/gender_woman"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:gender_man=>{
					:answer=>"#{Bot.emoticons[:man]} un homme",
					:text=>messages[:fr][:mes_citoyens][:gender_ok],
					:man=>true,
					:callback=>"mes_citoyens/gender_cb",
					:jump_to=>"mes_citoyens/menu"
				},
				:gender_woman=>{
					:answer=>"#{Bot.emoticons[:woman]} une femme",
					:text=>messages[:fr][:mes_citoyens][:gender_ok],
					:woman=>true,
					:callback=>"mes_citoyens/gender_cb",
					:jump_to=>"mes_citoyens/menu"
				},
				:back=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"mes_citoyens/back_cb",
					:jump_to=>"mes_citoyens/menu"
				},
				:inconnu=>{
					:text=>messages[:fr][:mes_citoyens][:inconnu],
					:jump_to=>"mes_citoyens/chercher_candidat"
				},
				:not_found=>{
					:text=>messages[:fr][:mes_citoyens][:not_found],
					:jump_to=>"mes_citoyens/menu"
				},
				:blocked=>{
					:text=>messages[:fr][:mes_citoyens][:blocked],
					:jump_to=>"mes_citoyens/menu"
				},
				:max_reached=>{
					:text=>messages[:fr][:mes_citoyens][:max_reached],
					:jump_to=>"mes_citoyens/menu"
				},
				:error=>{
					:text=>messages[:fr][:mes_citoyens][:error],
					:jump_to=>"mes_citoyens/menu"
				},
				:already_candidate=>{
					:text=>messages[:fr][:mes_citoyens][:already_candidate],
					:jump_to=>"mes_citoyens/menu"
				},
				:use_keyboard=>{
					:text=>messages[:fr][:mes_citoyens][:use_keyboard],
					:jump_to=>"mes_citoyens/del_ask"
				}

			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"mes_citoyens/menu"}}})
	end

	def mes_citoyens_menu_cb(msg,user,screen)
		puts "mes_citoyens_menu" if DEBUG
		res=@candidates.proposed_by(user[:id])
		res.each_with_index do |r,i|
			name=r['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
			soutiens=r['nb_supporters'].to_i
			il = r['gender']=='F' ? 'elle' : 'il'
			soutiens_txt= soutiens>1 ? "invité à se présenter par #{soutiens} citoyens" : "invité à se présenter par #{soutiens} citoyen"
			i+=1
			fig="nb_"+i.to_s
			screen[:text]+="<b>#{name}</b> (<a href='https://laprimaire.org/candidat/#{r['candidate_id']}'>voir sa page</a>) #{soutiens_txt}\n"
			screen[:parse_mode]='HTML'
		end
		if res.num_tuples<1 then # no citizens supported yet
			screen=self.find_by_name("mes_citoyens/empty")
		elsif res.num_tuples>4 then # not allowed to chose more citizens
			screen[:kbd_del]=["mes_citoyens/new"]
			screen[:text]+="Vous avez atteint le nombre maximum de citoyen(ne)s que vous pouvez inviter (5). Si vous voulez inviter un(e) autre citoyen(ne), retirez au préalable votre soutien à l'un(e) des citoyen(ne)s ci-dessus.\n"
		end
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end

	def mes_citoyens_back_cb(msg,user,screen)
		puts "mes_citoyens_back" if DEBUG
		from=user['session']['previous_session']['current']
		candidate=user['session']['candidate']
		photo=candidate['photo'] if candidate
		if photo then
			File.delete(photo) if File.exists?(photo)
		end
		@users.next_answer(user[:id],'answer')
		@users.clear_session(user[:id],'candidate')
		@users.clear_session(user[:id],'delete_candidates')
		return self.get_screen(screen,user,msg)
	end

	def mes_citoyens_new(msg,user,screen)
		puts "mes_citoyens_new" if DEBUG
		@users.next_answer(user[:id],'free_text',1,"mes_citoyens/search")
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def mes_citoyens_search(msg,user,screen)
		candidate=user['session']['candidate']
		name=candidate ? candidate["name"] : user['session']['buffer']
		puts "mes_citoyens_search : #{name}" if DEBUG
		return self.get_screen(self.find_by_name("mes_citoyens/not_found"),user,msg) if not name
		# immediately send a message to acknowledge we got the request as the search might take time
		Democratech::LaPrimaireBot.tg_client.api.sendChatAction(chat_id: user[:id], action: "typing")
		Democratech::LaPrimaireBot.tg_client.api.sendMessage({
			:chat_id=>user[:id],
			:text=>"Ok, je recherche...",
			:reply_markup=>Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
		})
		screen=self.find_by_name("mes_citoyens/confirm")
		res=@candidates.search_index(name) if candidate.nil?
		@users.next_answer(user[:id],'answer')
		if candidate.nil? and res['hits'].length>0  then
			puts "mes_citoyens_search: index hit" if DEBUG
			candidate=res['hits'][0]
			if candidate['photo'] then
				photo=CANDIDATS_DIR+candidate['photo']
			else
				photo=IMAGE_DIR+'missing-photo-M.jpg'
			end
			@users.update_session(user[:id],{'candidate'=>candidate})
		else
			puts "mes_citoyens_search: web" if DEBUG
			tags=name.scan(/#(\w+)/).flatten
			name=name.gsub(/#\w+/,'').strip if tags
			if name and tags then
				tmp=name+" "+tags.join(' ')
				images = @web.search_image(name+" "+tags.join(' '))
			elsif name
				images = @web.search_image(name)
			end
			return self.get_screen(self.find_by_name("mes_citoyens/not_found"),user,msg) if images.empty?
			idx=0
			idx=candidate['idx'] if (!candidate.nil? and !candidate['idx'].nil?)
			photo=nil
			while (idx<5 and photo.nil? and !images[idx].nil?) do
				img,type=images[idx]
				begin
					web_img=MiniMagick::Image.open(img.link)
					web_img.resize "x300"
					photo=TMP_DIR+'image'+user[:id].to_s+"."+type
					web_img.write(photo)
					break
				rescue
					photo=nil
				ensure
					idx+=1
					@users.update_session(user[:id],{'candidate'=>{'name'=>name,'photo'=>photo,'idx'=>idx}})
					retry_screen=self.find_by_name("mes_citoyens/confirm_no")
				end
			end
			return self.get_screen(self.find_by_name("mes_citoyens/not_found"),user,msg) if photo.nil?
		end
		screen[:text]=screen[:text] % {media:"image:"+photo}
		return self.get_screen(screen,user,msg)
	end

	def mes_citoyens_get_image(images,idx)
		img,type=images[idx]
		return self.get_screen(self.find_by_name("mes_citoyens/not_found"),user,msg) if images.empty? or images[idx].nil?
		begin
			web_img=MiniMagick::Image.open(img.link)
			web_img.resize "x300"
			photo=TMP_DIR+'image'+user[:id].to_s+"."+type
			web_img.write(photo)
			idx+=1
			@users.update_session(user[:id],{'candidate'=>{'name'=>name,'photo'=>photo,'idx'=>idx}})
			retry_screen=self.find_by_name("mes_citoyens/confirm_no")
			screen[:text]=retry_screen[:text]+screen[:text] if candidate
		rescue
			idx=
				img,type=images[idx+1]
			photo=nil
		end
	end

	def mes_citoyens_confirm_no(msg,user,screen)
		candidate=user['session']['candidate']
		puts "mes_citoyens_confirm_no : #{candidate}" if DEBUG
		image=candidate.nil? ? nil : candidate['photo']
		File.delete(image) if (!image.nil? and File.exists?(image))
		idx=candidate['idx'].nil? ? 1 : candidate['idx']
		return idx==4 ? self.get_screen(self.find_by_name("mes_citoyens/not_found"),user,msg) : mes_citoyens_search(msg,user,screen)
	end

	def mes_citoyens_confirm_yes(msg,user,screen)
		candidate=user['session']['candidate']
		puts "mes_citoyens_confirm_yes : #{candidate}" if DEBUG
		if candidate then
			image=candidate['photo']
			if candidate['candidate_id'] then # candidate already exists in db
				res=@candidates.search({:by=>'candidate_id',:target=>candidate['candidate_id']})
				@candidates.add(candidate,true) if res.num_tuples.zero? # candidate in index but not in db (weird case)
				@candidates.add_supporter(user[:id],candidate['candidate_id'])
				screen=self.find_by_name("mes_citoyens/menu")
				if res[0]['verified'].to_b then
					screen=self.find_by_name("mes_citoyens/already_candidate") 
					name=res[0]['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
					var= res[0]['gender']=='F' ? "candidate" : "candidat"
					screen[:text]=screen[:text] % {name: name, candidat: var }
				end

			elsif user['settings']['blocked']['add_candidate'] # user is forbidden to add new candidates
				screen=self.find_by_name("mes_citoyens/blocked")
				File.delete(image) if (!image.nil? and File.exists?(image))
			elsif !ADMINS.include?(user[:id]) && user['settings']['limits']['candidate_proposals'].to_i<=user['settings']['actions']['nb_candidates_proposed'].to_i # user has already added the maximum candidates he could add
				screen=self.find_by_name("mes_citoyens/max_reached")
				File.delete(image) if (!image.nil? and File.exists?(image))
			else # candidate needs to be registered in db
				candidate=@candidates.add(candidate)
				nb_candidates_proposed=user['settings']['actions']['nb_candidates_proposed']+1
				@users.update_settings(user[:id],{'actions'=>{'nb_candidates_proposed'=>nb_candidates_proposed}})
				user['session']['candidate']['candidate_id']=candidate['candidate_id']
				FileUtils.mv(image,CANDIDATS_DIR+candidate['photo'])
				@candidates.add_supporter(user[:id],candidate['candidate_id'])
			end
		else
			screen=self.find_by_name("mes_citoyens/error")
		end
		return self.get_screen(screen,user,msg)
	end

	def mes_citoyens_real_candidate_cb(msg,user,screen)
		candidate=user['session']['candidate']
		puts "mes_candidates_real_candidate_cb : #{candidate}" if DEBUG
		real_candidate = screen[:real]
		if not real_candidate then
			@candidates.delete(candidate['candidate_id'])
			File.delete(CANDIDATS_DIR+candidate['photo']) if File.exists?(CANDIDATS_DIR+candidate['photo'])
		else
			slack_msg="Nouveau candidat(e) proposé(e) : #{candidate['name']} (<https://laprimaire.org/candidat/#{candidate['candidate_id']}|voir sa page>) par #{user['firstname']} #{user['lastname']}"
			Bot.slack_notification(slack_msg,"candidats",":man:","LaPrimaire.org")
			Democratech::LaPrimaireBot.mixpanel.track(user[:id],'new_candidate_supported',{'name'=>candidate['name']}) if PRODUCTION
			Democratech::LaPrimaireBot.mixpanel.people.increment(user[:id],{'nb_candidates_proposed'=>1}) if PRODUCTION
		end
		return self.get_screen(screen,user,msg)
	end

	def mes_citoyens_gender_cb(msg,user,screen)
		candidate=user['session']['candidate']
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(self.find_by_name("mes_citoyens/error"),user,msg) if candidate.nil?
		gender = screen[:man] ? 'M':'F'
		@candidates.set(candidate['candidate_id'],{:set=> 'gender',:value=> gender})
		return self.get_screen(screen,user,msg)
	end

	def mes_citoyens_del_ask(msg,user,screen)
		puts "mes_citoyens_del_ask" if DEBUG
		res=@candidates.proposed_by(user[:id])
		return self.get_screen(self.find_by_name("mes_citoyens/error"),user,msg) if res.num_tuples.zero?
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
		@users.next_answer(user[:id],'free_text',1,"mes_citoyens/del")
		return self.get_screen(screen,user,msg)
	end

	def mes_citoyens_del(msg,user,screen)
		buffer=user['session']['buffer']
		puts "mes_citoyens_del : #{buffer}" if DEBUG
		return self.get_screen(self.find_by_name("mes_citoyens/error"),user,msg) unless buffer
		return self.get_screen(self.find_by_name("mes_citoyens/use_keyboard"),user,msg) if buffer.match(/\d\./).nil?
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

#include MesCitoyens
