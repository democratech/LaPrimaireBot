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

module Welcome
	def self.included(base)
		Bot.log.info "loading Welcome add-on"
		messages={
			:fr=>{
				:welcome=>{
					:hello=><<-END,
image:static/images/laprimaire-bienvenue.jpg
Bonjour %{firstname} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
END
					:start=><<-END,
Mon rôle est de vous accompagner et de vous informer tout au long du déroulement de La Primaire.
Un petit conseil avant de commencer : je voudrais être certaine de bien vous comprendre. Pour cela le plus simple est d'utiliser les boutons qui s'affichent en bas de l'écran
END
					:condition_1=><<-END,
Avant tout, vous devez me confirmer que vous remplissez les conditions légales afin de pouvoir voter à la prochaine élection présidentielle française.
Etes-vous de nationalité française ou étrangère ?
END
					:condition_2=><<-END,
Quel sera votre âge à la veille du 1er tour de l'élection présidentielle française de 2017 ?
END
					:condition_2bis=><<-END,
Confirmez-vous ne pas être privé(e) de votre droit de vote suite à la perte de vos droits civils et politiques ou en situation d'incapacité prévue par la loi ?
END
					:condition_3=><<-END,
Vous engagez-vous à vous inscrire sur les listes électorales d'ici au 31 décembre 2016 afin de pouvoir voter en 2017 ?
END
					:condition_ok=><<-END,
Merci, c'est bien enregistré ! C'était une première étape de validation, une vérification complémentaire vous sera demandée ultérieurement.
END
					:condition_bof=><<-END,
Bien compris, nous espérons de tout coeur que LaPrimaire.org fera émerger un(e) candidat(e) qui vous donnera envie de voter en 2017 !
Ceci était une première étape de validation, une vérification complémentaire vous sera demandée ultérieurement.
END
					:condition_ko=><<-END,
Merci, c'est bien enregistré ! Malheureusement, vous ne remplissez pas les conditions pour pouvoir participer, désolé #{Bot.emoticons[:crying_face]}
https://www.youtube.com/watch?v=B9PjBgWOkng
END
					:charte=><<-END,
LaPrimaire.org étant une initiative ouverte à tous, pour que celle-ci se déroule au mieux, vous devez vous engager à :
1. Vous comporter avec respect, responsabilité et bienveillance envers les candidats et les autres citoyens, dans le respect de la Loi
2. Agir dans un esprit constructif et rechercher avant tout l'intérêt général et non servir des intérêts particuliers
Vous engagez-vous à respecter ce code de conduite ?
END
					:charte_ok=><<-END,
Parfait, merci ! A présent, il est temps de vous créer un compte #{Bot.emoticons[:smile]}
END
					:charte_ko=><<-END,
Désolé, dans ces conditons, nous ne pouvons pas vous laisser participer #{Bot.emoticons[:frowning]}
https://www.youtube.com/watch?v=B9PjBgWOkng
END
					:email=><<-END,
Quelle est votre adresse email ? Vous aurez besoin d'un email valide pour confirmer votre choix de candidat.
END
					:email_optin=><<-END,
Autorisez-vous l'équipe de LaPrimaire.org (et uniquement elle !) à vous adresser un email de temps en temps ?
END
					:email_optin_ok=><<-END,
Merci de votre confiance !
END
					:email_optin_ko=><<-END,
Ok, aucun souci, je respecte totalement votre décision #{Bot.emoticons[:little_smile]}
END
					:email_error=><<-END,
Hmmm... cet email ne semble pas valide #{Bot.emoticons[:rolling_eyes]}
Quel est votre (vrai) email ?
END
					:email_used=><<-END,
Hmmm... cet email est déjà utilisé #{Bot.emoticons[:rolling_eyes]}
Réessayons, quel est votre email ?
END
					:france=><<-END,
Habitez-vous en France (DOM-TOM inclus) ou à l'étranger ?
END
					:country=><<-END,
Dans quel pays habitez-vous ?
END
					:country_error=><<-END,
Hmmm... il ne me semble pas connaître ce pays #{Bot.emoticons[:thinking_face]}
Pouvez-vous me m'indiquer à nouveau le pays dans lequel vous habitez (en français) ?
END
					:city=><<-END,
Dans quelle ville habitez-vous ?
END
					:city_ask=><<-END,
Voyons...
https://maps.googleapis.com/maps/api/staticmap?size=250x250&maptype=roadmap\&markers=size:mid|color:red|%{city},%{country}
Vous habitez ici, c'est bien çà ?
END
					:city_ask_ok=><<-END,
Bien noté !
END
					:city_ask_ko=><<-END,
Hmmmm... recommençons pour voir, une erreur a dû se glisser quelque part !
END
					:zipcode=><<-END,
Quel est le code postal de votre ville ?
END
					:zipcode_city=><<-END,
#{Bot.emoticons[:thinking_face]} Hmmmm... il existe plusieurs villes avec ce code postal, laquelle est la vôtre ?
END
					:zipcode_error=><<-END,
A priori, ce code postal n'existe pas...
Réessayez s'il vous plait.
END
					:account_created=><<-END,
Merci ! Votre compte a été créé avec succès.
<i>Un conseil</i> : Pour dialoguer avec moi dans les meilleures conditions, je vous invite à installer l'application <b>Telegram</b> sur votre smartphone ou sur votre ordinateur : <a href='https://telegram.org/dl'>Télécharger Telegram</a>. Telegram est l'application de messagerie sécurisée utilisée pour organiser LaPrimaire.org.
END
				}
			}
		}
		screens={
			:welcome=>{
				:hello=>{
					:text=>messages[:fr][:welcome][:hello],
					:jump_to=>"welcome/start"
				},
				:start=>{
					:text=>messages[:fr][:welcome][:start],
					:disable_web_page_preview=>true,
					:jump_to=>"welcome/condition_1"
				},
				:condition_1=>{
					:text=>messages[:fr][:welcome][:condition_1],
					:kbd=>["welcome/condition_1_ok","welcome/condition_1_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:condition_1_ok=>{
					:answer=>"française",
					:jump_to=>"welcome/condition_2"
				},
				:condition_1_ko=>{
					:answer=>"étrangère",
					:callback=>"welcome/condition_ko_cb",
					:jump_to=>"welcome/condition_3_ko"
				},
				:condition_2=>{
					:text=>messages[:fr][:welcome][:condition_2],
					:kbd=>["welcome/condition_2_ok","welcome/condition_2_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:condition_2_ok=>{
					:answer=>"18 ans ou plus",
					:jump_to=>"welcome/condition_2bis"
				},
				:condition_2_ko=>{
					:answer=>"moins de 18 ans",
					:callback=>"welcome/condition_ko_cb",
					:jump_to=>"welcome/condition_3_ko"
				},
				:condition_2bis=>{
					:text=>messages[:fr][:welcome][:condition_2bis],
					:kbd=>["welcome/condition_2bis_ok","welcome/condition_2bis_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:condition_2bis_ok=>{
					:answer=>"Je confirme",
					:jump_to=>"welcome/condition_3"
				},
				:condition_2bis_ko=>{
					:answer=>"Non j'en suis privé",
					:callback=>"welcome/condition_ko_cb",
					:jump_to=>"welcome/condition_3_ko"
				},
				:condition_3=>{
					:text=>messages[:fr][:welcome][:condition_3],
					:kbd=>["welcome/condition_3_ok","welcome/condition_3_ko","welcome/condition_3_bof"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:condition_3_ok=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Oui, j'irai voter",
					:text=>messages[:fr][:welcome][:condition_ok],
					:callback=>"welcome/condition_ok_cb",
					:jump_to=>"welcome/charte"
				},
				:condition_3_bof=>{
					:answer=>"#{Bot.emoticons[:thinking_face]} J'hésite encore",
					:text=>messages[:fr][:welcome][:condition_bof],
					:bof=>true,
					:callback=>"welcome/condition_ok_cb",
					:jump_to=>"welcome/charte"
				},
				:condition_3_ko=>{
					:answer=>"#{Bot.emoticons[:thumbs_down]} Non, je n'irai pas voter",
					:callback=>"welcome/condition_ko_cb",
					:text=>messages[:fr][:welcome][:condition_ko]
				},
				:charte=>{
					:text=>messages[:fr][:welcome][:charte],
					:disable_web_page_preview=>true,
					:kbd=>["welcome/charte_ok","welcome/charte_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:charte_ok=>{
					:answer=>"Oui, je m'y engage",
					:text=>messages[:fr][:welcome][:charte_ok],
					:callback=>"welcome/charte_ok_cb",
					:jump_to=>"welcome/email"
				},
				:charte_ko=>{
					:answer=>"Non, je ne le souhaite pas",
					:text=>messages[:fr][:welcome][:charte_ko],
					:callback=>"welcome/charte_ko_cb"
				},
				:email=>{
					:text=>messages[:fr][:welcome][:email],
					:callback=>"welcome/enter_email"
				},
				:email_error=>{
					:text=>messages[:fr][:welcome][:email_error],
					:callback=>"welcome/enter_email"
				},
				:email_used=>{
					:text=>messages[:fr][:welcome][:email_used],
					:callback=>"welcome/enter_email"
				},
				:email_optin=>{
					:text=>messages[:fr][:welcome][:email_optin],
					:disable_web_page_preview=>true,
					:kbd=>["welcome/email_optin_ok","welcome/email_optin_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:email_optin_ok=>{
					:answer=>"Oui, pas de souci",
					:text=>messages[:fr][:welcome][:email_optin_ok],
					:callback=>"welcome/email_optin_ok",
					:jump_to=>"welcome/france"
				},
				:email_optin_ko=>{
					:answer=>"Non, je ne préfère pas",
					:text=>messages[:fr][:welcome][:email_optin_ko],
					:jump_to=>"welcome/france"
				},
				:france=>{
					:text=>messages[:fr][:welcome][:france],
					:kbd=>["welcome/zipcode","welcome/country"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:zipcode=>{
					:answer=>"J'habite en France",
					:text=>messages[:fr][:welcome][:zipcode],
					:callback=>"welcome/enter_zipcode"
				},
				:zipcode_city=>{
					:text=>messages[:fr][:welcome][:zipcode_city],
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:zipcode_error=>{
					:text=>messages[:fr][:welcome][:zipcode_error],
					:jump_to=>"welcome/zipcode"
				},
				:country=>{
					:answer=>"J'habite à l'étranger",
					:text=>messages[:fr][:welcome][:country],
					:callback=>"welcome/enter_country"
				},
				:country_error=>{
					:text=>messages[:fr][:welcome][:country_error],
					:callback=>"welcome/enter_country"
				},
				:city=>{
					:text=>messages[:fr][:welcome][:city],
					:callback=>"welcome/enter_city"
				},
				:city_ask=>{
					:text=>messages[:fr][:welcome][:city_ask],
					:kbd=>["welcome/city_ask_ok","welcome/city_ask_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:city_ask_ok=>{
					:answer=>"Oui, c'est bien là",
					:text=>messages[:fr][:welcome][:city_ask_ok],
					:jump_to=>"welcome/account_created"
				},
				:city_ask_ko=>{
					:answer=>"Non, ce n'est pas là",
					:callback=>"welcome/city_ask_ko",
					:jump_to=>"welcome/city"
				},
				:account_created=>{
					:text=>messages[:fr][:welcome][:account_created],
					:parse_mode=>"HTML",
					:callback=>"welcome/account_created_cb",
					:jump_to=>"home/menu"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def welcome_condition_ko_cb(msg,user,screen)
		Bot.log.info "welcome_condition_ko_cb"
		@users.update_settings(user[:id],{
			'legal'=>{'can_vote'=> false},
			'blocked'=>{'not_allowed'=> true}
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_condition_ok_cb(msg,user,screen)
		Bot.log.info "welcome_condition_ok_cb"
		update={'legal'=>{'can_vote'=> true}}
		update['legal']['not_sure']=true if screen[:bof]
		@users.update_settings(user[:id],update)
		return self.get_screen(screen,user,msg)
	end

	def welcome_charte_ko_cb(msg,user,screen)
		Bot.log.info "welcome_charte_ko_cb"
		@users.update_settings(user[:id],{
			'legal'=>{'charte'=> false},
			'blocked'=>{'not_allowed'=> true}
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_charte_ok_cb(msg,user,screen)
		Bot.log.info "welcome_charte_ok_cb"
		@users.update_settings(user[:id],{'legal'=>{'charte'=> true}})
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_email(msg,user,screen)
		Bot.log.info "welcome_enter_email"
		@users.next_answer(user[:id],'free_text',1,"welcome/save_email")
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_email(msg,user,screen)
		email=user['session']['buffer']
		Bot.log.info "welcome_save_email: #{email}"
		if email.match(/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/).nil? then
			screen=self.find_by_name("welcome/email_error")
			return self.get_screen(screen,user,msg) 
		end
		email=email.downcase.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
		res=@users.search({:by=>'email',:target=>email})
		if res.num_tuples > 0 and res[0]['user_id']!=user[:id] then
			screen=self.find_by_name("welcome/email_used")
			return self.get_screen(screen,user,msg) 
		end
		@users.next_answer(user[:id],'answer')
		@users.create_account(user[:id],email)
		@users.set(user[:id],{ :set=>'email', :value=>email })
		screen=self.find_by_name("welcome/email_optin")
		return self.get_screen(screen,user,msg)
	end

	def welcome_email_optin_ok(msg,user,screen)
		Bot.log.info "welcome_email_optin_ok"
		@users.update_settings(user[:id],{'legal'=>{'email_optin'=> true}})
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_country(msg,user,screen)
		Bot.log.info "welcome_enter_country"
		@users.next_answer(user[:id],'free_text',1,"welcome/save_country")
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_country(msg,user,screen)
		country=user['session']['buffer']
		answer=@geo.search_country(country,{hitsPerPage:1})
		return self.get_screen(self.find_by_name("welcome/country_error"),user,msg) if answer["hits"].length==0
		country=answer["hits"][0]["name"]
		Bot.log.info "welcome_save_country: #{country}"
		@users.next_answer(user[:id],'answer')
		@users.set(user[:id],{
			:set=>'country',
			:value=>country
		})
		screen=self.find_by_name("welcome/city")
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_city(msg,user,screen)
		Bot.log.info "welcome_enter_city"
		@users.next_answer(user[:id],'free_text',1,"welcome/city_ask")
		return self.get_screen(screen,user,msg)
	end

	def welcome_city_ask(msg,user,screen,city=nil)
		Bot.log.info "welcome_city_ask"
		city= city.nil? ? user['session']['buffer'] : city
		country=user['country']
		Bot.log.info "welcome_city_ask: #{city}"
		@users.next_answer(user[:id],'answer')
		args={
			:set=>'city',
			:value=>city.upcase
		}
		args[:using]={:field=>'zipcode',:value=>user['zipcode']} if country=="FRANCE"
		@users.set(user[:id],args)
		args={
			:city=>city.gsub(' ','+'),
			:country=>country.gsub(' ','+')
		}
		screen=self.find_by_name("welcome/city_ask")
		screen[:text]=screen[:text] % args
		return self.get_screen(screen,user,msg)
	end

	def welcome_city_ask_ko(msg,user,screen)
		Bot.log.info "welcome_city_ask_ko"
		screen= user['country']=="FRANCE" ? self.find_by_name("welcome/zipcode") : self.find_by_name("welcome/city")
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_zipcode(msg,user,screen)
		Bot.log.info "welcome_enter_zipcode"
		@users.set(user[:id],{
			:set=>'country',
			:value=>'FRANCE'
		})
		@users.next_answer(user[:id],'free_text',1,"welcome/save_zipcode")
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_zipcode(msg,user,screen)
		Bot.log.info "welcome_save_zipcode"
		zipcode=user['session']['buffer'].delete(' ')
		zipcode="0"+zipcode if zipcode.length==4
		Bot.log.info "welcome_save_zipcode: #{zipcode}"
		@users.set(user[:id],{
			:set=>'zipcode',
			:value=>zipcode
		})
		user['zipcode']=zipcode
		res=@geo.search_city({
			:type=>'city',
			:by=>'zipcode',
			:target=>zipcode
		})
		nb_tuples=res.num_tuples
		@users.next_answer(user[:id],'answer')
		if nb_tuples>1 then
			screen=self.find_by_name("welcome/zipcode_city")
			screen[:kbd_add]=[]
			res.each do |r|
				screen[:kbd_add].push(r['name'])
			end
			@users.next_answer(user[:id],'free_text',1,"welcome/city_ask")
		elsif nb_tuples==1
			city=res[0]['name']
			@users.set(user[:id],{
				:set=>'city',
				:value=>city.upcase,
				:using=>{
					:field=>"zipcode",
					:value=>zipcode
				}
			})
			return self.welcome_city_ask(msg,user,screen,city)
		else
			screen=self.find_by_name("welcome/zipcode_error")
		end
		return self.get_screen(screen,user,msg)
	end

	def welcome_account_created_cb(msg,user,screen)
		Bot.log.info "welcome_account_created"
		@users.update_account(user[:id])
		slack_msg="Nouveau compte créé : #{user['firstname']} #{user['lastname']}"
	       	slack_msg+=" (<https://telegram.me/#{user['username']}|@#{user['username']}>)" if user['username']
		slack_msg+=" #{user['zipcode']}," if user['zipcode']
		slack_msg+=" #{user['city']}, #{user['country']}"
		Bot.log.slack_notification(slack_msg,"inscrits",":laprimaire:","LaPrimaire.org")
		Bot.log.event(user[:id],'user_account_created')
		Bot.log.people(user[:id],'append',{
			'city'=>user['city'],
			'country'=>user['country'],
			'zipcode'=>user['zipcode']
		})
		return self.get_screen(screen,user,msg)
	end
end

include Welcome
