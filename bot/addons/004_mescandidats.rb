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
					:menu=><<-END,
Il y a actuellement %{nb_candidats_complets} candidat(e)s dont le profil est complet (dont %{nb_candidats_non_vus} que vous n'avez pas encore %{vus}) et %{nb_candidats_incomplets} dont le profil est en cours de création.
END
#Pour se qualifier au deuxième tour de LaPrimaire.org, les candidats doivent obtenir <b>500 soutiens</b> de citoyens au total.
#Vous ne pouvez soutenir que <b>5 candidats</b> au maximum. Bien entendu, à tout moment vous pouvez retirer votre soutien à un candidat que vous aviez soutenu auparavant.
#Cliquez sur le bouton #{Bot.emoticons[:busts]}<i>Voir les candidats</i> pour voir un des candidats déjà enregistré et sur le bouton #{Bot.emoticons[:woman]}#{Bot.emoticons[:man]}<i>Mes candidats</i> pour voir les candidats que vous soutenez.
# Si aucun candidat ne vous plait, vous pouvez proposer les citoyen(ne)s que vous souhaiteriez voir être candidat(e)s et ainsi les inciter à se présenter.
					:show=><<-END,
<b>%{name}</b> (<a href='https://laprimaire.org/candidat/%{candidate_id}'>voir sa page</a>) a %{soutiens_txt} sur 500 nécessaires pour se qualifier
END
					:voir_candidat=><<-END,
<b>%{name}</b> (<a href='https://laprimaire.org/candidat/%{candidate_id}'>voir sa page</a>) a %{soutiens_txt} sur 500 nécessaires
no_preview:Si vous souhaitez que %{name} participe à LaPrimaire.org pour y apporter ses idées et participe à la construction de l'avenir du pays ? Apporter lui votre soutien en cliquant sur le bouton <i>#{Bot.emoticons[:thumbs_up]} Soutenir</i> ci-dessous. Pour voir un autre candidat, cliquez sur <i>#{Bot.emoticons[:finger_right]} Voir un autre candidat</i>
END
					:chercher_candidat=><<-END,
Quel(le) candidat(e) cherchez-vous ? (ou tapez 'menu' pour revenir au menu)
END
					:soutenir=><<-END,
Bien noté ! Vous avez apporté votre soutien à %{name}
END
					:retirer_soutien=><<-END,
Bien noté ! Vous avez retiré votre soutien à %{name}
END
					:chercher_candidat_ask=><<-END,
Plusieurs candidat(e)s correspondent à votre recherche, lequel cherchez-vous ?
END
					:too_large=><<-END,
Votre recherche n'est pas assez précise, soyez plus précis s'il vous plait !
END
					:new=><<-END,
Quel(le) candidat(e) souhaitez-vous soutenir ?
END
					:mes_candidats=><<-END,
Voici les candidats que vous soutenez :
END
					:empty=><<-END,
Pour le moment, vous ne soutenez aucun candidat
END
					:how=><<-END,
Vous avez la possibilité de soutenir jusqu'à 5 candidats sur LaPrimaire.org.
Vous pouvez soutenir qui vous souhaitez, mais voici quelques conseils :
1. <b>Tout le monde peut être candidat(e)</b> (même vous !). L'objectif de LaPrimaire.org est de faire émerger les meilleurs candidat(e)s <b>d'où qu'ils/elles viennent</b>. Ne vous limitez pas aux seules personnalités politiques connues.
2. <b>Pensez "équipe"</b>. Réfléchissez aux personnes dont les idées emportent votre adhésion et que vous souhaiteriez voir être plus impliquées dans la vie politique de notre pays. Ne vous limitez pas à la seule recherche du prochain Président.
3. <b>Réfléchissez par thèmes</b>. Quels sont vos thématiques de prédilection et vos sujets d'expertise ? L'écologie ? L'économie ? La santé ? L'éducation ? L'emploi ? Proposez les personnes qui portent les idées auxquelles vous adhérez.
4. <b>Privilégiez celles et ceux qui "font"</b>. L'action est un bon moyen pour juger de la conviction d'un(e) candidat(e) : Privilégiez les candidat(e)s qui s'investissent personnellement pour mettre en oeuvre les idées qu'ils/elles défendent.
5. <b>Soyez sérieux</b>. Ne proposez pas de faux candidats (fictifs, décédés, etc.), vous risqueriez le blocage pur et simple de votre compte.
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
Bien qu'il vous soit possible de soutenir n'importe quel(le) candidat(e), celui ou celle-ci doit être Français(e) et éligible en France sinon il/elle sera rejeté(e).
Soutenir un candidat ou une candidate fantaisiste irait à l'encontre de la Charte que vous avez acceptée et vous prendriez le risque d'être exclu #{Bot.emoticons[:crying_face]}
Sachant cela, confirmez-vous votre soutien à ce(tte) candidat(e) ? 
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
					:inconnu=><<-END,
Malheureusement, je ne trouve aucun(e) candidat(e) avec ce nom #{Bot.emoticons[:crying_face]}. Etes-vous certain que la personne que vous cherchez est officiellement candidate ?
END
					:blocked=><<-END,
Désolé mais ce candidat est inconnu et votre compte n'est plus autorisé à proposer de nouveaux candidats #{Bot.emoticons[:crying_face]}
END
					:max_reached=><<-END,
Désolé mais ce candidat est inconnu et vous avez atteint le maximum de candidats inconnus que vous pouvez proposer #{Bot.emoticons[:crying_face]}
END
					:max_support=><<-END,
Désolé, vous avez atteint le nombre maximum de candidat(e)s que vous pouvez soutenir (5) #{Bot.emoticons[:crying_face]}. Si vous souhaitez soutenir ce(te) candidat(e), il vous faut d'abord retirer votre soutien à un(e) autre candidat(e).
END
					:error=><<-END,
Hmmmm.... je me suis embrouillée les pinceaux, il va falloir recommencer s'il vous plait. Désolé #{Bot.emoticons[:confused]}
END
				}
			}
		}
		screens={
			:mes_candidats=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:woman]}#{Bot.emoticons[:man]} Voir les candidats",
					:text=>messages[:fr][:mes_candidats][:menu],
					:callback=>"mes_candidats/menu_cb",
					:disable_web_page_preview=>true,
					:kbd=>["mes_candidats/voir_candidat","mes_candidats/chercher_candidat","mes_candidats/mes_candidats","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:mes_candidats=>{
					:answer=>"#{Bot.emoticons[:woman]}#{Bot.emoticons[:man]} Mes candidats",
					:text=>messages[:fr][:mes_candidats][:mes_candidats],
					:callback=>"mes_candidats/mes_candidats_cb",
					:kbd=>["mes_candidats/del_ask","mes_candidats/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:chercher_candidat=>{
					:answer=>"#{Bot.emoticons[:loupe]} Chercher un candidat",
					:text=>messages[:fr][:mes_candidats][:chercher_candidat],
					:callback=>"mes_candidats/chercher_candidat_cb"
				},
				:too_large=>{
					:text=>messages[:fr][:mes_candidats][:too_large],
					:jump_to=>"mes_candidats/chercher_candidat"
				},
				:chercher_candidat_ask=>{
					:text=>messages[:fr][:mes_candidats][:chercher_candidat_ask],
					:kbd=>["mes_candidats/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:voir_candidat=>{
					:answer=>"#{Bot.emoticons[:busts]} Voir les candidats",
					:text=>messages[:fr][:mes_candidats][:voir_candidat],
					:callback=>"mes_candidats/voir_candidat_cb",
					:kbd=>["mes_candidats/candidat_suivant","mes_candidats/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:show=>{
					:text=>messages[:fr][:mes_candidats][:show],
					:kbd=>["mes_candidats/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:soutenir=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Soutenir ce candidat",
					:text=>messages[:fr][:mes_candidats][:soutenir],
					:callback=>"mes_candidats/soutenir_cb",
					:jump_to=>"mes_candidats/menu"
				},
				:max_support=>{
					:text=>messages[:fr][:mes_candidats][:max_support],
					:jump_to=>"mes_candidats/menu"
				},
				:retirer_soutien=>{
					:answer=>"#{Bot.emoticons[:cross_mark]} Retirer mon soutien",
					:text=>messages[:fr][:mes_candidats][:retirer_soutien],
					:callback=>"mes_candidats/retirer_soutien_cb",
					:jump_to=>"mes_candidats/menu"
				},
				:candidat_suivant=>{
					:answer=>"#{Bot.emoticons[:bust]} Voir un autre candidat",
					:jump_to=>"mes_candidats/voir_candidat"
				},
				:aucun_soutien=>{
					:text=>messages[:fr][:mes_candidats][:empty],
					:jump_to=>"mes_candidats/menu"
				},
				:empty=>{
					:text=>messages[:fr][:mes_candidats][:empty],
					:kbd=>["mes_candidats/new","mes_candidats/how","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:how=>{
					:answer=>"#{Bot.emoticons[:thinking_face]} Qui soutenir ?",
					:text=>messages[:fr][:mes_candidats][:how],
					:disable_web_page_preview=>true,
					:parse_mode=>"HTML",
					:kbd=>["mes_candidats/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:new=>{
					:answer=>"#{Bot.emoticons[:finger_right]} Soutenir",
					:text=>messages[:fr][:mes_candidats][:new],
					:callback=>"mes_candidats/new"
				},
				:del_ask=>{
					:answer=>"#{Bot.emoticons[:cross_mark]} Supprimer",
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
					:answer=>"#{Bot.emoticons[:thumbs_up]} Oui, c'est mon choix",
					:text=>messages[:fr][:mes_candidats][:confirm_yes],
					:callback=>"mes_candidats/confirm_yes",
					:jump_to=>"mes_candidats/real_candidate"
				},
				:confirm_no=>{
					:answer=>"#{Bot.emoticons[:thumbs_down]} Non, mauvaise personne",
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
					:answer=>"Oui je confirme",
					:text=>messages[:fr][:mes_candidats][:real_candidate_ok],
					:real=>true,
					:callback=>"mes_candidats/real_candidate_cb",
					:jump_to=>"mes_candidats/gender"
				},
				:real_candidate_ko=>{
					:answer=>"Non je ne confirme pas",
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
					:callback=>"mes_candidats/back_cb",
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:inconnu=>{
					:text=>messages[:fr][:mes_candidats][:inconnu],
					:jump_to=>"mes_candidats/chercher_candidat"
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
		Bot.addMenu({:home=>{:menu=>{:kbd=>"mes_candidats/menu"}}})
	end

	def mes_candidats_menu_cb(msg,user,screen)
		stats=@candidates.stats(user[:id])
		non_vus=stats['verified'].to_i - stats['viewed'].to_i
		incomplets=stats['total'].to_i - stats['verified'].to_i
		vus= non_vus>1 ? "vus" : "vu"
		screen[:text]=screen[:text] % {nb_candidats_complets: stats['verified'].to_s, nb_candidats_non_vus: non_vus.to_s, nb_candidats_incomplets: incomplets.to_s, vus: vus}
		screen[:parse_mode]='HTML'
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_voir_candidat_cb(msg,user,screen)
		puts "mes_candidats_voir_candidat_cb" if DEBUG
		candidate=@candidates.next_candidate(user[:id])
		mon_soutien=candidate['mon_soutien']
		name=candidate['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
		soutiens=candidate['nb_soutiens'].to_i
		soutiens_txt= soutiens>1 ? "#{soutiens} soutiens" : "#{soutiens} soutien"
		screen[:kbd_add]=[]
		if mon_soutien.to_b then
			soutiens_txt+= " (dont vous!)"
			screen[:kbd_add].push(@screens[:mes_candidats][:retirer_soutien][:answer])
		else
			screen[:kbd_add].push(@screens[:mes_candidats][:soutenir][:answer])
		end
		screen[:text]=screen[:text] % {name: name, candidate_id: candidate['candidate_id'], soutiens_txt: soutiens_txt}
		screen[:parse_mode]='HTML'
		@users.update_session(user[:id],{'candidate'=>candidate})
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'view_candidate',{'name'=>candidate['name']}) if PRODUCTION
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_chercher_candidat_cb(msg,user,screen)
		@users.next_answer(user[:id],'free_text',1,"mes_candidats/trouver_candidat_cb")
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_trouver_candidat_cb(msg,user,screen)
		candidate=user['session']['candidate']
		name=candidate ? candidate["name"] : user['session']['buffer']
		puts "mes_candidats_trouver_candidat_cb : #{name}" if DEBUG
		return self.get_screen(self.find_by_name("mes_candidats/inconnu"),user,msg) if not name
		return self.get_screen(self.find_by_name("mes_candidats/too_large"),user,msg) if name.length<4
		# immediately send a message to acknowledge we got the request as the search might take time
		Democratech::LaPrimaireBot.tg_client.api.sendChatAction(chat_id: user[:id], action: "typing")
		Democratech::LaPrimaireBot.tg_client.api.sendMessage({
			:chat_id=>user[:id],
			:text=>"Ok, je recherche...",
			:reply_markup=>Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
		})
		res=@candidates.search_candidate(name) if candidate.nil?
		return self.get_screen(self.find_by_name("mes_candidats/inconnu"),user,msg) if res.num_tuples.zero?
		return self.get_screen(self.find_by_name("mes_candidats/too_large"),user,msg) if res.num_tuples>5
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

	def mes_candidats_show(msg,user,screen,candidate=nil)
		puts "mes_candidats_show" if DEBUG
		if candidate.nil? then
			buffer=user['session']['buffer']
			return self.get_screen(self.find_by_name("mes_candidats/error"),user,msg) unless buffer
			if buffer.match(/\d\./).nil? then
				@users.next_answer(user[:id],'answer')
				@users.clear_session(user[:id],'delete_candidates')
				return self.get_screen(self.find_by_name("mes_candidats/menu"),user,msg) 
			end
			idx,name=buffer.split('. ')
			name=name.strip.split(' ').each{|n| n.capitalize!}.join(' ') if name
			candidate_id=user['session']['delete_candidates'][idx]['candidate_id'].to_i
		else
			candidate_id=candidate['candidate_id']
		end
		candidate=@candidates.find(candidate_id,user[:id])
		mon_soutien=candidate['mon_soutien']
		name=candidate['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
		soutiens=candidate['nb_soutiens'].to_i
		soutiens_txt= soutiens>1 ? "#{soutiens} soutiens" : "#{soutiens} soutien"
		screen[:kbd_add]=[]
		if mon_soutien.to_b then
			soutiens_txt+= " (dont vous!)"
			screen[:kbd_add].push(@screens[:mes_candidats][:retirer_soutien][:answer])
		else
			screen[:kbd_add].push(@screens[:mes_candidats][:soutenir][:answer])
		end
		screen[:text]=screen[:text] % {name: name, candidate_id: candidate['candidate_id'], soutiens_txt: soutiens_txt}
		screen[:parse_mode]='HTML'
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'view_candidate',{'name'=>candidate['name']}) if PRODUCTION
		@users.update_session(user[:id],{'candidate'=>candidate})
		@users.clear_session(user[:id],'delete_candidates')
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_soutenir_cb(msg,user,screen)
		puts "mes_candidats_soutenir_cb" if DEBUG
		res=@candidates.supported_by(user[:id])
		if res.num_tuples>4 then
			@users.clear_session(user[:id],'candidate')
			return self.get_screen(self.find_by_name("mes_candidats/max_support"),user,msg)
		end
		candidate=user['session']['candidate']
		name=candidate['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
		@candidates.add_supporter(user[:id],candidate['candidate_id'])
		screen[:text]=screen[:text] % {name: name}
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_retirer_soutien_cb(msg,user,screen)
		puts "mes_candidats_retirer_soutien_cb" if DEBUG
		candidate=user['session']['candidate']
		name=candidate['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
		@candidates.remove_supporter(user[:id],candidate['candidate_id'])
		screen[:text]=screen[:text] % {name: name}
		@users.clear_session(user[:id],'candidate')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_mes_candidats_cb(msg,user,screen)
		puts "mes_candidats_mes_candidats" if DEBUG
		res=@candidates.supported_by(user[:id])
		res.each_with_index do |r,i|
			name=r['name'].strip.split(' ').each{|n| n.capitalize!}.join(' ')
			soutiens=r['nb_supporters'].to_i
			soutiens_txt= soutiens>1 ? "#{soutiens} soutiens" : "#{soutiens} soutien"
			i+=1
			fig="nb_"+i.to_s
			screen[:text]+="* #{name} (<a href='https://laprimaire.org/candidat/#{r['candidate_id']}'>voir sa page</a>) - #{soutiens_txt} sur 500 nécessaires\n"
			screen[:parse_mode]='HTML'
		end
		if res.num_tuples<1 then # no candidates supported yet
			screen=self.find_by_name("mes_candidats/aucun_soutien")
		elsif res.num_tuples>4 then # not allowed to chose more candidates
			screen[:kbd_del]=["mes_candidats/new"]
			screen[:text]+="Vous avez atteint le nombre maximum de candidat(e)s que vous pouvez soutenir (5). Si vous voulez soutenir un(e) autre candidat(e), vous devez au préalable retirer votre soutien à l'un(e) des candidat(e)s ci-dessus.\n"
		end
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_back_cb(msg,user,screen)
		puts "mes_candidats_back" if DEBUG
		puts "CURRENT #{user['session']['previous_session']['current']}\n"
		from=user['session']['previous_session']['current']
		case from
		when "mes_candidats/voir_candidat"
			screen=self.find_by_name("mes_candidats/menu")
		when "mes_candidats/show"
			screen=self.find_by_name("mes_candidats/menu")
		when "mes_candidats/chercher_candidat"
			screen=self.find_by_name("mes_candidats/menu")
		when "mes_candidats/mes_candidats"
			screen=self.find_by_name("mes_candidats/menu")
		else
			candidate=user['session']['candidate']
			photo=candidate['photo'] if candidate
			if photo then
				File.delete(photo) if File.exists?(photo)
			end
		end
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
		candidate=user['session']['candidate']
		name=candidate ? candidate["name"] : user['session']['buffer']
		puts "mes_candidats_search : #{name}" if DEBUG
		return self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) if not name
		# immediately send a message to acknowledge we got the request as the search might take time
		Democratech::LaPrimaireBot.tg_client.api.sendChatAction(chat_id: user[:id], action: "typing")
		Democratech::LaPrimaireBot.tg_client.api.sendMessage({
			:chat_id=>user[:id],
			:text=>"Ok, je recherche...",
			:reply_markup=>Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
		})
		screen=self.find_by_name("mes_candidats/confirm")
		res=@candidates.search_index(name) if candidate.nil?
		@users.next_answer(user[:id],'answer')
		if candidate.nil? and res['hits'].length>0  then
			puts "mes_candidats_search: index hit" if DEBUG
			candidate=res['hits'][0]
			if candidate['photo'] then
				photo=CANDIDATS_DIR+candidate['photo']
			else
				photo=IMAGE_DIR+'missing-photo-M.jpg'
			end
			@users.update_session(user[:id],{'candidate'=>candidate})
		elsif not name.scan(/\b#{user['firstname']}\b/i).empty? and not name.scan(/\b#{user['lastname']}\b/i).empty? then
			@users.next_answer(user[:id],'answer')
			return self.get_screen(self.find_by_name("moi_candidat/start"),user,msg)
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
			return self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) if images.empty?
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
					retry_screen=self.find_by_name("mes_candidats/confirm_no")
				end
			end
			return self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) if photo.nil?
		end
		screen[:text]=screen[:text] % {media:"image:"+photo}
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_get_image(images,idx)
		img,type=images[idx]
		return self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) if images.empty? or images[idx].nil?
		begin
			web_img=MiniMagick::Image.open(img.link)
			web_img.resize "x300"
			photo=TMP_DIR+'image'+user[:id].to_s+"."+type
			web_img.write(photo)
			idx+=1
			@users.update_session(user[:id],{'candidate'=>{'name'=>name,'photo'=>photo,'idx'=>idx}})
			retry_screen=self.find_by_name("mes_candidats/confirm_no")
			screen[:text]=retry_screen[:text]+screen[:text] if candidate
		rescue
			idx=
				img,type=images[idx+1]
			photo=nil
		end
	end

	def mes_candidats_confirm_no(msg,user,screen)
		candidate=user['session']['candidate']
		puts "mes_candidats_confirm_no : #{candidate}" if DEBUG
		image=candidate['photo']
		File.delete(image) if (!image.nil? and File.exists?(image))
		idx=candidate['idx'].nil? ? 1 : candidate['idx']
		return idx==4 ? self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) : mes_candidats_search(msg,user,screen)
	end

	def mes_candidats_confirm_yes(msg,user,screen)
		candidate=user['session']['candidate']
		puts "mes_candidats_confirm_yes : #{candidate}" if DEBUG
		if candidate then
			image=candidate['photo']
			if candidate['candidate_id'] then # candidate already exists in db
				res=@candidates.search({:by=>'candidate_id',:target=>candidate['candidate_id']})
				@candidates.add(candidate,true) if res.num_tuples.zero? # candidate in index but not in db (weird case)
				@candidates.add_supporter(user[:id],candidate['candidate_id'])
				screen=self.find_by_name("mes_candidats/mes_candidats")
			elsif user['settings']['blocked']['add_candidate'] # user is forbidden to add new candidates
				screen=self.find_by_name("mes_candidats/blocked")
				File.delete(image) if (!image.nil? and File.exists?(image))
			elsif !ADMINS.include?(user[:id]) && user['settings']['limits']['candidate_proposals'].to_i<=user['settings']['actions']['nb_candidates_proposed'].to_i # user has already added the maximum candidates he could add
				screen=self.find_by_name("mes_candidats/max_reached")
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
			screen=self.find_by_name("mes_candidats/error")
		end
		return self.get_screen(screen,user,msg)
	end

	def mes_candidats_real_candidate_cb(msg,user,screen)
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
