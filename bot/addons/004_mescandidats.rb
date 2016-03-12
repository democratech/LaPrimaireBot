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
		puts "loading Welcome add-on" if DEBUG
		messages={
			:fr=>{
				:mes_candidats=>{
					:new=><<-END,
Qui souhaitez-vous proposer comme candidat(e) ?
END
					:mes_candidats=><<-END,
Voici les candidats que vous supportez :
END
					:empty=><<-END,
Vous n'avez encore proposé aucun candidat !
END
					:how=><<-END,
Choisissez quelqu'un de bien et c'est bon :)
END
					:del_ask=><<-END,
A quel candidat souhaitez-vous retirer votre soutien ?
END
					:del=><<-END,
%{name} n'a désormais plus votre soutien !
END
					:confirm=><<-END,
Ok, je recherche...
%{media}
Est-ce bien votre choix ?
END
					:confirm_yes=><<-END,
Parfait, c'est bien enregistré !
END
					:confirm_no=><<-END,
Hmmmm... réessayons !
END
					:not_found=><<-END,
Malheureusement, je ne trouve personne avec ce nom #{Bot.emoticons[:crying_face]}
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
					:kbd=>["mes_candidats/del_ask","mes_candidats/new","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:empty=>{
					:text=>messages[:fr][:mes_candidats][:empty],
					:kbd=>["mes_candidats/how","mes_candidats/new","mes_candidats/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:how=>{
					:answer=>"#{Bot.emoticons[:thinking_face]} Quel candidats puis-je proposer ?",
					:text=>messages[:fr][:mes_candidats][:how],
					:jump_to=>"mes_candidats/empty"
				},
				:new=>{
					:answer=>"#{Bot.emoticons[:finger_right]} Proposer un candidat",
					:text=>messages[:fr][:mes_candidats][:new],
					:callback=>"mes_candidats/new"
				},
				:del_ask=>{
					:answer=>"#{Bot.emoticons[:trash]} Supprimer un candidat",
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
					:jump_to=>"mes_candidats/mes_candidats"
				},
				:confirm_no=>{
					:answer=>"#{Bot.emoticons[:thumbs_down]} Non, ce n'est pas la bonne personne",
					:text=>messages[:fr][:mes_candidats][:confirm_no],
					:callback=>"mes_candidats/confirm_no",
					:jump_to=>"mes_candidats/confirm"
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
				:error=>{
					:text=>messages[:fr][:mes_candidats][:error],
					:jump_to=>"mes_candidats/new"
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
			screen[:text]+="* #{name} (<a href='https://bot.democratech.co/candidat/#{r['candidate_id']}'>voir sa page</a>)\n"
			screen[:parse_mode]='HTML'
		end
		if res.num_tuples<1 then # no candidates supported yet
			screen=self.find_by_name("mes_candidats/empty")
		elsif res.num_tuples>4 then # not allowed to chose more candidates
			screen[:kbd_del]=["mes_candidats/new"]
			screen[:text]+="Vous avez atteint le nombre maximum de candidats que vous pouvez proposer. Si vous voulez soutenir un autre candidat, vous devez au préalable enlever votre soutien à l'un des candidats ci-dessus.\n"
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
			images = @web.search_image(name) if name
			idx=candidate.nil? ? 0 : candidate['idx']
			img,type=images[idx]
			return self.get_screen(self.find_by_name("mes_candidats/not_found"),user,msg) if images.empty? or images[idx].nil?
			photo=TMP_DIR+'image'+user[:id].to_s+"."+type
			open(photo,'wb') { |file| file << open(img.link).read }
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
				@candidates.add_supporter(user[:id],candidate['candidate_id'])
			else # candidate needs to be registered in db
				image=candidate['photo']
				candidate=@candidates.add(candidate)
				puts "candidate #{candidate}"
				FileUtils.mv(image,CANDIDATS_DIR+candidate['photo'])
				@candidates.add_supporter(user[:id],candidate['candidate_id'])
			end
			@users.clear_session(user[:id],'candidate')
		else
			screen=self.find_by_name("mes_candidats/error")
		end
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
