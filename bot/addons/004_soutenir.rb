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

module SoutenirCandidat
	# is being called when the module is included
	# here you need to update the Bot with your Add-on screens and hook your entry point into the Bot's menu
	def self.included(base)
		Bot.log.info "loading SoutenirCandidat add-on"
		messages={
			:fr=>{
				:soutenir_candidat=>{
					:menu=><<-END,
Comment s'appelle le candidat ou la candidate que vous souhaitez soutenir ? Ecrivez-moi son nom ou bien cliquez sur <i>#{Bot.emoticons[:back]} Retour</i> pour revenir à l'accueil
END
					:inconnu=><<-END,
no_preview:Hmmm... je ne trouve pas de candidat <b>déclaré</b> avec ce nom #{Bot.emoticons[:crying_face]} A priori, le citoyen que vous recherchez ne s'est pas (encore!) officiellement déclaré candidat sur LaPrimaire.org.
Souhaitez-vous plébisciter %{name} pour l'inviter à se déclarer officiellement candidat ?
END
					:recherche_trop_large=><<-END,
Votre recherche n'est pas assez précise, soyez plus précis s'il vous plaît !
END
					:nom_trop_long=><<-END,
Le nom de ce citoyen me semble un petit peu trop long #{Bot.emoticons[:rolling_eyes]} J'ai du mal à croire qu'un candidat puisse s'appeler comme cela.
END
					:show_candidate=><<-END,
<a href='https://laprimaire.org/candidat/%{candidate_id}'>%{name}</a> est %{candidate} et a déjà obtenu %{soutiens_txt} sur les 500 nécessaires pour se qualifier.
END
					:show_citizen=><<-END,
<a href='https://laprimaire.org/candidat/%{candidate_id}'>%{name}</a> n'est pas officiellement %{candidate} mais sa candidature est plébiscitée par %{soutiens_txt}. Si %{name} atteint 500 plébiscites citoyens, nous l'inviterons à se déclarer %{candidate} officiellement.
END
					:show_actions_avec_soutien=><<-END,
Cliquez sur <i>#{Bot.emoticons[:cross_mark]} Retirer mon soutien</i> pour retirer votre soutien à %{name} ou <i>#{Bot.emoticons[:back]} Retour</i> pour revenir à l'accueil
END
					:show_actions_sans_soutien_candidat=><<-END,
Cliquez sur <i>#{Bot.emoticons[:thumbs_up]} Soutenir ce candidat</i> pour apporter votre soutien à %{name} ou <i>#{Bot.emoticons[:back]} Retour</i> pour revenir à l'accueil
END
					:show_actions_sans_soutien_citoyen=><<-END,
Cliquez sur <i>#{Bot.emoticons[:thumbs_up]} Plébisciter ce citoyen</i> pour plébisciter la candidature de %{name} ou <i>#{Bot.emoticons[:back]} Retour</i> pour revenir à l'accueil
END
					:chercher_candidat_ask=><<-END,
Plusieurs candidat(e)s correspondent à votre recherche, lequel cherchez-vous ?
END
					:soutenir=><<-END,
Bien noté ! Vous avez apporté votre soutien à %{name}
END
					:retirer_soutien=><<-END,
Bien noté ! Vous avez retiré votre soutien à %{name}
END
					:del_citizen_ask=><<-END,
A quel(le) citoyen(ne) souhaitez-vous retirer votre soutien pour pouvoir soutenir %{name} ?
END
					:del_citizen_cb=><<-END,
%{name} n'a désormais plus votre soutien.
END
					:replace_ask=><<-END,
A quel(le) citoyen(ne) souhaitez-vous retirer votre soutien pour pouvoir soutenir %{name} ?
END
					:replace_soutien_cb=><<-END,
%{oldname} n'a désormais plus votre soutien, il a été remplacé par %{newname} !
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
Vous êtes le premier à proposer %{name} !
Bien qu'il vous soit possible de soutenir n'importe quel(le) citoyen(ne), celui ou celle-ci doit être Français(e) et éligible en France sinon il/elle sera rejeté(e).
Soutenir un(e) citoyen(ne) fantaisiste irait à l'encontre de la Charte que vous avez acceptée et vous prendriez le risque d'être exclu #{Bot.emoticons[:crying_face]}
Sachant cela, confirmez-vous vouloir proposer %{name} ? 
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
Désolé mais ce candidat est inconnu et votre compte n'est plus autorisé à proposer de nouveaux candidats #{Bot.emoticons[:crying_face]}
END
					:max_reached=><<-END,
Désolé mais ce candidat est inconnu et vous avez atteint le maximum de candidats inconnus que vous pouvez proposer #{Bot.emoticons[:crying_face]}
END
					:max_support_candidate=><<-END,
Hmmm... vous avez atteint le nombre maximum de candidat(e)s déclaré(e)s que vous pouvez soutenir (5) #{Bot.emoticons[:crying_face]} Si vous souhaitez soutenir %{name}, il vous faut d'abord retirer votre soutien à un(e) autre candidat(e).
END
					:max_support_citizen=><<-END,
Hmmm... vous avez atteint le nombre maximum de citoyen(ne)s que vous pouvez plébisciter (5) #{Bot.emoticons[:crying_face]} Si vous souhaitez plébisciter %{name}, il vous faut d'abord retirer votre plébiscite à un(e) autre citoyen(ne).
END
					:error=><<-END,
Hmmmm.... je n'ai pas compris, il va falloir recommencer s'il vous plaît. Désolé #{Bot.emoticons[:confused]}
END
					:email_required=><<-END,
Hmmm... il me semble que vous ne m'avez pas dit quel était votre email. Votre email est indispensable pour pouvoir soutenir un ou une candidat(e). Cliquez sur <i>#{Bot.emoticons[:memo]} Mon profil</i> pour renseigner votre email.
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
					:parse_mode=>"HTML",
					:kbd=>["soutenir_candidat/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:email_required=>{
					:text=>messages[:fr][:soutenir_candidat][:email_required],
					:parse_mode=>"HTML",
					:jump_to=>"home/menu"
				},
				:retour=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"soutenir_candidat/retour_cb"
				},
				:inconnu=>{
					:text=>messages[:fr][:soutenir_candidat][:inconnu],
					:parse_mode=>"HTML",
					:callback=>"soutenir_candidat/search_citizen_cb"
				},
				:recherche_trop_large=>{
					:text=>messages[:fr][:soutenir_candidat][:recherche_trop_large],
					:jump_to=>"soutenir_candidat/menu"
				},
				:nom_trop_long=>{
					:text=>messages[:fr][:soutenir_candidat][:nom_trop_long],
					:jump_to=>"soutenir_candidat/menu"
				},
				:show_candidate=>{
					:text=>messages[:fr][:soutenir_candidat][:show_candidate],
					:parse_mode=>"HTML",
					:kbd=>["soutenir_candidat/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:show_citizen=>{
					:text=>messages[:fr][:soutenir_candidat][:show_citizen],
					:parse_mode=>"HTML",
					:kbd=>["soutenir_candidat/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:chercher_candidat_ask=>{
					:text=>messages[:fr][:soutenir_candidat][:chercher_candidat_ask],
					:kbd=>["soutenir_candidat/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:plebisciter=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Plébisciter ce citoyen",
					:text=>messages[:fr][:soutenir_candidat][:soutenir],
					:callback=>"soutenir_candidat/soutenir_cb",
					:jump_to=>"home/menu"
				},
				:soutenir=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Soutenir ce candidat",
					:text=>messages[:fr][:soutenir_candidat][:soutenir],
					:callback=>"soutenir_candidat/soutenir_cb",
					:jump_to=>"home/menu"
				},
				:max_support_candidate=>{
					:text=>messages[:fr][:soutenir_candidat][:max_support_candidate],
					:jump_to=>"home/menu"
				},
				:max_support_citizen=>{
					:text=>messages[:fr][:soutenir_candidat][:max_support_citizen],
					:jump_to=>"home/menu"
				},
				:retirer_soutien=>{
					:answer=>"#{Bot.emoticons[:cross_mark]} Retirer mon soutien",
					:text=>messages[:fr][:soutenir_candidat][:retirer_soutien],
					:callback=>"soutenir_candidat/retirer_soutien_cb",
					:jump_to=>"home/menu"
				},
				:del_citizen_ask=>{
					:text=>messages[:fr][:soutenir_candidat][:del_citizen_ask],
					:callback=>"soutenir_candidat/del_citizen_ask_cb",
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:del_citizen_cb=>{
					:text=>messages[:fr][:soutenir_candidat][:del_citizen_cb],
					:jump_to=>"soutenir_candidat/confirm_yes"
				},
				:replace_ask=>{
					:text=>messages[:fr][:soutenir_candidat][:replace_ask],
					:callback=>"soutenir_candidat/replace_ask_cb",
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:replace_soutien_cb=>{
					:text=>messages[:fr][:soutenir_candidat][:replace_soutien_cb],
					:jump_to=>"home/menu"
				},
				:confirm=>{
					:text=>messages[:fr][:soutenir_candidat][:confirm],
					:kbd=>["soutenir_candidat/confirm_yes","soutenir_candidat/confirm_no","soutenir_candidat/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:confirm_yes=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Oui, c'est mon choix",
					:text=>messages[:fr][:soutenir_candidat][:confirm_yes],
					:callback=>"soutenir_candidat/confirm_yes",
					:jump_to=>"soutenir_candidat/real_candidate"
				},
				:confirm_no=>{
					:answer=>"#{Bot.emoticons[:thumbs_down]} Non, mauvaise personne",
					:text=>messages[:fr][:soutenir_candidat][:confirm_no],
					:callback=>"soutenir_candidat/confirm_no",
					:jump_to=>"soutenir_candidat/confirm"
				},
				:real_candidate=>{
					:text=>messages[:fr][:soutenir_candidat][:real_candidate],
					:callback=>"soutenir_candidat/real_candidate_ask_cb",
					:kbd=>["soutenir_candidat/real_candidate_ok","soutenir_candidat/real_candidate_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:real_candidate_ok=>{
					:answer=>"Oui je confirme",
					:text=>messages[:fr][:soutenir_candidat][:real_candidate_ok],
					:real=>true,
					:callback=>"soutenir_candidat/real_candidate_cb",
					:jump_to=>"soutenir_candidat/gender"
				},
				:real_candidate_ko=>{
					:answer=>"Non je ne confirme pas",
					:text=>messages[:fr][:soutenir_candidat][:real_candidate_ko],
					:real=>false,
					:callback=>"soutenir_candidat/real_candidate_cb",
					:jump_to=>"home/menu"
				},
				:gender=>{
					:text=>messages[:fr][:soutenir_candidat][:gender],
					:kbd=>["soutenir_candidat/gender_man","soutenir_candidat/gender_woman"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:gender_man=>{
					:answer=>"#{Bot.emoticons[:man]} un homme",
					:text=>messages[:fr][:soutenir_candidat][:gender_ok],
					:man=>true,
					:callback=>"soutenir_candidat/gender_cb",
					:jump_to=>"home/menu"
				},
				:gender_woman=>{
					:answer=>"#{Bot.emoticons[:woman]} une femme",
					:text=>messages[:fr][:soutenir_candidat][:gender_ok],
					:woman=>true,
					:callback=>"soutenir_candidat/gender_cb",
					:jump_to=>"home/menu"
				},
				:max_reached=>{
					:text=>messages[:fr][:soutenir_candidat][:max_reached],
					:jump_to=>"home/menu"
				},
				:not_found=>{
					:text=>messages[:fr][:soutenir_candidat][:not_found],
					:jump_to=>"home/menu"
				},
				:error=>{
					:text=>messages[:fr][:soutenir_candidat][:error],
					:jump_to=>"soutenir_candidat/menu"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"soutenir_candidat/menu"}}})
	end

	def soutenir_candidat_menu_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		return self.get_screen(self.find_by_name("soutenir_candidat/email_required"),user,msg) if user['email'].nil?
		return self.get_screen(self.find_by_name("profile/invalid_email"),user,msg) if user['email_status'].to_i==-2
		@users.next_answer(user[:id],'free_text',1,"soutenir_candidat/trouver_candidat_cb")
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_trouver_candidat_cb(msg,user,screen)
		candidate=user['session']['candidate']
		name=candidate ? candidate["name"] : user['session']['buffer']
		Bot.log.info "#{__method__} : #{name}"
		return self.get_screen(self.find_by_name("home/menu"),user,msg) if name==@screens[:soutenir_candidat][:retour][:answer]
		return self.get_screen(self.find_by_name("soutenir_candidat/inconnu"),user,msg) if not name
		return self.get_screen(self.find_by_name("soutenir_candidat/recherche_trop_large"),user,msg) if name.length<4
		return self.get_screen(self.find_by_name("soutenir_candidat/nom_trop_long"),user,msg) if name.length>55
		# immediately send a message to acknowledge we got the request as the search might take time
		Democratech::TelegramBot.client.api.sendChatAction(chat_id: user[:id], action: "typing")
		Democratech::TelegramBot.client.api.sendMessage({
			:chat_id=>user[:id],
			:text=>"Ok, voyons si je peux trouver ce(te) citoyen(ne)...",
			:reply_markup=>Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
		})
		Bot.log.event(user[:id],'search_candidate',{'name'=>name})
		res=@candidates.search_index(name) if candidate.nil?
		nb_results=res['hits'].length
		if nb_results.zero? then
			return soutenir_candidat_search_citoyen_cb(msg,user,screen)
		end
		@users.next_answer(user[:id],'answer')
		if res['hits'].length==1 then
			Bot.log.info "index_search: index hit"
			candidate=res['hits'][0]
			candidate=@candidates.find(candidate['candidate_id'],user[:id])
			return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if candidate.nil?
			if candidate['verified'].to_b then
				screen=self.find_by_name("soutenir_candidat/show_candidate")
			else
				screen=self.find_by_name("soutenir_candidat/show_citizen")
			end
			return self.soutenir_candidat_show_cb(msg,user,screen,candidate)
		end
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_show_cb(msg,user,screen,candidate=nil)
		Bot.log.info "#{__method__} : #{candidate}"
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if candidate.nil?
		candidate_id=candidate['candidate_id']
		candidate=@candidates.find(candidate_id,user[:id])
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if candidate.nil?
		mon_soutien=candidate['mon_soutien']
		name=candidate['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
		soutiens=candidate['nb_soutiens'].to_i
		soutiens_txt= soutiens>1 ? "#{soutiens} soutiens" : "#{soutiens} soutien"
		candidate_txt= candidate['gender']=='M' ? "candidat déclaré" : "candidate déclarée"
		screen[:kbd_add]=[]
		if mon_soutien.to_b then
			screen[:text]+=Bot.messages[:fr][:soutenir_candidat][:show_actions_avec_soutien]
			soutiens_txt+= " (dont vous!)"
			screen[:kbd_add].push(@screens[:soutenir_candidat][:retirer_soutien][:answer])
		else
			if candidate['verified'].to_b then
				screen[:text]+=Bot.messages[:fr][:soutenir_candidat][:show_actions_sans_soutien_candidat]
				screen[:kbd_add].push(@screens[:soutenir_candidat][:soutenir][:answer])
			else
				screen[:text]+=Bot.messages[:fr][:soutenir_candidat][:show_actions_sans_soutien_citoyen]
				candidate_txt= candidate['gender']=='M' ? "candidat" : "candidate"
				soutiens_txt= soutiens>1 ? "#{soutiens} citoyens" : "#{soutiens} citoyen"
				soutiens_txt+= " (dont vous!)" if mon_soutien.to_b
				screen[:kbd_add].push(@screens[:soutenir_candidat][:plebisciter][:answer])
			end
		end
		screen[:text]=screen[:text] % {name: name, candidate_id: candidate['candidate_id'], soutiens_txt: soutiens_txt, candidate: candidate_txt}
		screen[:parse_mode]='HTML'
		Bot.log.event(user[:id],'view_candidate',{'name'=>candidate['name']})
		@users.update_session(user[:id],{'candidate'=>candidate})
		@users.clear_session(user[:id],'delete_candidates')
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_soutenir_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		res=@candidates.supported_by(user[:id])
		nb_candidates_supported=0
		nb_citizens_supported=0
		if not res.num_tuples.zero? then
			res.each do |r|
				if not r['verified'].nil? and r['verified'].to_b then
					nb_candidates_supported+=1
				else
					nb_citizens_supported+=1
				end
			end
		end
		candidate=user['session']['candidate']
		if candidate.nil? then
			Bot.log.error "#{__method__}: candidate is undefined in session"
			return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg)
		end
		name=candidate['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
		verified=candidate['verified'].to_b
		if verified then
			Bot.log.event(user[:id],'support_candidate',{'name'=>name})
			return soutenir_candidat_replace_ask_cb(msg,user,screen,verified) if nb_candidates_supported>4
		else
			Bot.log.event(user[:id],'support_candidate',{'name'=>name,'citizen'=>1})
			return soutenir_candidat_replace_ask_cb(msg,user,screen,verified) if nb_citizens_supported>4
		end
		@candidates.add_supporter(user[:id],candidate['candidate_id'],user['email'])
		screen[:text]=screen[:text] % {name: name}
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_retirer_soutien_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		candidate=user['session']['candidate']
		name=candidate['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
		@candidates.remove_supporter(user[:id],candidate['candidate_id'])
		screen[:text]=screen[:text] % {name: name}
		@users.clear_session(user[:id],'candidate')
		Bot.log.event(user[:id],'remove_support',{'name'=>name})
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_search_citoyen_cb(msg,user,screen)
		candidate=user['session']['candidate']
		name=candidate ? candidate["name"] : user['session']['buffer']
		Bot.log.info "#{__method__} : #{name}"
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if not name
		screen=self.find_by_name("soutenir_candidat/confirm")
		@users.next_answer(user[:id],'answer')
		tags=name.scan(/#(\w+)/).flatten
		name=name.gsub(/#\w+/,'').strip if tags
		if name and tags then
			tmp=name+" "+tags.join(' ')
			images = @web.search_image(name+" "+tags.join(' '))
		elsif name
			images = @web.search_image(name)
		end
		return self.get_screen(self.find_by_name("soutenir_candidat/not_found"),user,msg) if images.empty?
		idx=0
		idx=candidate['idx'] if (!candidate.nil? and !candidate['idx'].nil?)
		photo=nil
		wait_msg= idx==0 ? "Hmmm a priori c'est une personne que je ne connais pas encore, voyons voir..." : "Ok, je recherche..."
		# immediately send a message to acknowledge we got the request as the search might take time
		Democratech::TelegramBot.client.api.sendChatAction(chat_id: user[:id], action: "typing")
		Democratech::TelegramBot.client.api.sendMessage({
			:chat_id=>user[:id],
			:text=>wait_msg,
			:reply_markup=>Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
		})
		Bot.log.event(user[:id],'search_citizen',{'name'=>name})
		while (idx<5 and photo.nil? and !images[idx].nil?) do
			img,type=images[idx]
			begin
				web_img=MiniMagick::Image.open(img.link)
				web_img.resize "x300"
				photo=TMP_DIR+'image'+user[:id].to_s+"."+type
				web_img.write(photo)
				@web.upload_image(photo)
				break
			rescue
				photo=nil
			ensure
				idx+=1
				@users.update_session(user[:id],{'candidate'=>{'name'=>name,'photo'=>photo,'idx'=>idx}})
				retry_screen=self.find_by_name("soutenir_candidat/confirm_no")
			end
		end
		return self.get_screen(self.find_by_name("soutenir_candidat/not_found"),user,msg) if photo.nil?
		screen[:text]=screen[:text] % {media:"image:"+photo}
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_confirm_no(msg,user,screen)
		candidate=user['session']['candidate']
		Bot.log.info "#{__method__}"
		image=candidate.nil? ? nil : candidate['photo']
		@web.delete_image(image) if !image.nil?
		idx=candidate['idx'].nil? ? 1 : candidate['idx']
		return idx==4 ? self.get_screen(self.find_by_name("soutenir_candidat/not_found"),user,msg) : soutenir_candidat_search_citoyen_cb(msg,user,screen)
	end

	def soutenir_candidat_confirm_yes(msg,user,screen)
		candidate=user['session']['candidate']
		Bot.log.info "#{__method__}"
		if candidate then
			# we check that the user did not already support 5 citizens
			res_check=@candidates.supported_by(user[:id])
			nb_citizens_supported=0
			if not res_check.num_tuples.zero? then
				res_check.each do |r|
					nb_citizens_supported+=1 if not r['verified'].to_b
				end
			end
			Bot.log.info "nb citizens supported: #{nb_citizens_supported}"
			return self.soutenir_candidat_del_citizen_ask_cb(msg,user,screen) if nb_citizens_supported>4
			image=candidate['photo']
			if candidate['candidate_id'] then # candidate already exists in db / impossible case in theory
				res=@candidates.search({:by=>'candidate_id',:target=>candidate['candidate_id']})
				@candidates.add(candidate,true) if res.num_tuples.zero? # candidate in index but not in db (weird case)
				@candidates.add_supporter(user[:id],candidate['candidate_id'],user['email'])
				screen=self.find_by_name("home/menu")
			elsif user['settings']['blocked']['add_candidate'] # user is forbidden to add new candidates
				screen=self.find_by_name("soutenir_candidat/blocked")
				@web.delete_image(image) if !image.nil?
			elsif !ADMINS.include?(user[:id]) && user['settings']['limits']['candidate_proposals'].to_i<=user['settings']['actions']['nb_candidates_proposed'].to_i # user has already added the maximum candidates he could add
				screen=self.find_by_name("soutenir_candidat/max_reached")
				@web.delete_image(image) if !image.nil?
				Bot.log.event(user[:id],'new_candidate_max_reached',{'name'=>name})
			else # candidate needs to be registered in db
				candidate=@candidates.add(candidate)
				nb_candidates_proposed=user['settings']['actions']['nb_candidates_proposed']+1
				@users.update_settings(user[:id],{'actions'=>{'nb_candidates_proposed'=>nb_candidates_proposed}})
				user['session']['candidate']['candidate_id']=candidate['candidate_id']
				FileUtils.mv(image,CANDIDATS_DIR+candidate['photo'])
				@web.upload_image(CANDIDATS_DIR+candidate['photo'])
				@candidates.add_supporter(user[:id],candidate['candidate_id'],user['email'])
			end
		else
			screen=self.find_by_name("soutenir_candidat/error")
		end
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_real_candidate_ask_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		candidate=user['session']['candidate']
		screen[:text]=screen[:text] % {name: candidate['name']}
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_real_candidate_cb(msg,user,screen)
		candidate=user['session']['candidate']
		Bot.log.info "#{__method__}"
		real_candidate = screen[:real]
		if not real_candidate then
			del_candidate=@candidates.delete(candidate['candidate_id'])
			@web.delete_image(candidate['photo']) if !candidate['photo'].nil?
			@web.delete_image(del_candidate['photo']) if !del_candidate['photo'].nil?
		else
			@web.delete_image(candidate['photo']) if !candidate['photo'].nil?
			slack_msg="Nouveau candidat(e) proposé(e) : #{candidate['name']} (<https://laprimaire.org/candidat/#{candidate['candidate_id']}|voir sa page>) par #{user['firstname']} #{user['lastname']}"
			Bot.log.slack_notification(slack_msg,"candidats",":man:","LaPrimaire.org")
			Bot.log.event(user[:id],'new_candidate_supported',{'name'=>candidate['name']})
			Bot.log.event(user[:id],'support_candidate',{'name'=>candidate['name'],'citizen'=>1})
			Bot.log.people(user[:id],'increment',{'nb_candidates_proposed'=>1})
		end
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_gender_cb(msg,user,screen)
		candidate=user['session']['candidate']
		Bot.log.info "#{__method__}"
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if candidate.nil?
		gender = screen[:man] ? 'M':'F'
		@candidates.set(candidate['candidate_id'],{:set=> 'gender',:value=> gender})
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_del_citizen_ask_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		candidate=user['session']['candidate']
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if candidate.nil?
		res=@candidates.supported_by(user[:id])
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if res.num_tuples.zero?
		screen=self.find_by_name("soutenir_candidat/del_citizen_ask")
		@users.clear_session(user[:id],'delete_candidates')
		screen[:kbd_add]=[]
		screen[:kbd_add].push(@screens[:soutenir_candidat][:retour][:answer])
		candidates_list={}
		idx=0
		res.each do |r|
			if not r['verified'].to_b then
				idx+=1
				name=r['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
				screen[:kbd_add].push(idx.to_s+". "+name)
				candidates_list[idx.to_s]={'candidate_id'=>r['candidate_id'],'name'=>name}
			end
		end
		screen[:text]=Bot.messages[:fr][:soutenir_candidat][:max_support_citizen]+screen[:text] 
		screen[:text]=screen[:text] % {name: candidate['name']}
		@users.update_session(user[:id],{'delete_candidates'=>candidates_list})
		@users.next_answer(user[:id],'free_text',1,"soutenir_candidat/del_citizen_cb")
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_del_citizen_cb(msg,user,screen)
		buffer=user['session']['buffer']
		Bot.log.info "#{__method__} : #{buffer}"
		return self.get_screen(self.find_by_name("home/menu"),user,msg) if buffer==@screens[:soutenir_candidat][:retour][:answer]
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) unless buffer
		idx,name=buffer.split('. ')
		name=name.strip.split(' ').each{|n| n.capitalize!}.join(' ') if name
		delcandidate=user['session']['delete_candidates'][idx]
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if delcandidate.nil?
		delcandidate_id=user['session']['delete_candidates'][idx]['candidate_id'].to_i
		screen[:text]=screen[:text] % {name:name} 
		@candidates.remove_supporter(user[:id],delcandidate_id)
		@users.clear_session(user[:id],'delete_candidates')
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'remove_support',{'name'=>name})
		return self.get_screen(screen,user,msg)
	end


	def soutenir_candidat_replace_ask_cb(msg,user,screen,verified=nil)
		Bot.log.info "#{__method__}"
		candidate=user['session']['candidate']
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if candidate.nil?
		res=@candidates.supported_by(user[:id])
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if res.num_tuples.zero?
		screen=self.find_by_name("soutenir_candidat/replace_ask")
		@users.clear_session(user[:id],'delete_candidates')
		screen[:kbd_add]=[]
		screen[:kbd_add].push(@screens[:soutenir_candidat][:retour][:answer])
		candidates_list={}
		idx=0
		res.each do |r|
			if r['verified'].to_b==verified then
				idx+=1
				name=r['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
				screen[:kbd_add].push(idx.to_s+". "+name)
				candidates_list[idx.to_s]={'candidate_id'=>r['candidate_id'],'name'=>name}
			end
		end
		if verified then
			screen[:text]=Bot.messages[:fr][:soutenir_candidat][:max_support_candidate]+screen[:text] 
		else
			screen[:text]=Bot.messages[:fr][:soutenir_candidat][:max_support_citizen]+screen[:text] 
		end
		screen[:text]=screen[:text] % {name: candidate['name']}
		@users.update_session(user[:id],{'delete_candidates'=>candidates_list})
		@users.next_answer(user[:id],'free_text',1,"soutenir_candidat/replace_soutien_cb")
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_replace_soutien_cb(msg,user,screen)
		buffer=user['session']['buffer']
		Bot.log.info "#{__method__} : #{buffer}"
		newcandidate=user['session']['candidate']
		return self.get_screen(self.find_by_name("home/menu"),user,msg) if buffer==@screens[:soutenir_candidat][:retour][:answer]
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if newcandidate.nil?
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) unless buffer
		idx,name=buffer.split('. ')
		name=name.strip.split(' ').each{|n| n.capitalize!}.join(' ') if name
		oldcandidate=user['session']['delete_candidates'][idx]
		return self.get_screen(self.find_by_name("soutenir_candidat/error"),user,msg) if oldcandidate.nil?
		oldcandidate_id=user['session']['delete_candidates'][idx]['candidate_id'].to_i
		screen[:text]=screen[:text] % {oldname:name, newname: newcandidate['name']} 
		@candidates.remove_supporter(user[:id],oldcandidate_id)
		@candidates.add_supporter(user[:id],newcandidate['candidate_id'],user['email'])
		@users.clear_session(user[:id],'delete_candidates')
		@users.clear_session(user[:id],'candidate')
		@users.next_answer(user[:id],'answer')
		Bot.log.event(user[:id],'remove_support',{'name'=>name})
		Bot.log.event(user[:id],'support_candidate',{'name'=>name})
		return self.get_screen(screen,user,msg)
	end

	def soutenir_candidat_retour_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		from=user['session']['previous_session']['current']
		case from
		when "soutenir_candidat/menu"
			screen=self.find_by_name("home/menu")
		else
			screen=self.find_by_name("home/menu")
		end
		@users.next_answer(user[:id],'answer')
		@users.clear_session(user[:id],'candidate')
		@users.clear_session(user[:id],'delete_candidates')
		return self.get_screen(screen,user,msg)
	end
end

include SoutenirCandidat
