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

module Welcome
	def self.included(base)
		puts "loading Welcome add-on" if DEBUG
		messages={
			:fr=>{
				:welcome=>{
					:hello=><<-END,
Bonjour %{firstname} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
END
					:start=><<-END,
Mon rôle est de vous accompagner et de vous informer tout au long du déroulement de La Primaire.
END
					:condition_1=><<-END,
Avant tout, vous devez nous confirmer que vous remplissez les conditions légales afin de pouvoir voter à la prochaine élection présidentielle française.
Etes-vous de nationalité française ?
END
					:condition_2=><<-END,
Avez-vous 18 ans révolus ou les aurez-vous au plus tard le 22 avril 2017, soit la veille du 1er tour de l'élection présidentielle française de 2017 ?
END
					:condition_3=><<-END,
Etes-vous inscrit sur les listes électorales ou vous engagez-vous à réaliser les démarches nécessaires en prévision des élections de 2017 ?
END
					:condition_ok=><<-END,
Merci, c'est bien enregistré ! C'était une première étape de validation, une vérification complémentaire vous sera demandée ultérieurement.
END
					:condition_ko=><<-END,
Merci, c'est bien enregistré ! Malheureusement, vous ne remplissez pas les conditions pour pouvoir participer à LaPrimaire.org, désolé #{Bot.emoticons[:crying_face]}
END
					:charte=><<-END,
LaPrimaire.org étant une initiative ouverte à tous, pour que celle-ci se déroule au mieux, vous devez vous engager à :
1. vous comporter avec respect, responsabilité et bienveillance envers les candidats et les autres citoyens, dans le respect de la Loi
2. agir dans un esprit constructif et rechercher avant tout l'intérêt général et non servir des intérêts particuliers
Vous engagez-vous à respecter ce code de conduite ?
END
					:charte_ok=><<-END,
Parfait, merci ! A présent, il est temps de vous créer un compte #{Bot.emoticons[:smile]}
END
					:charte_ko=><<-END,
Désolé, dans ces conditons, nous ne pouvons pas vous laisser participer à LaPrimaire.org #{Bot.emoticons[:frowning]}
image:static/gif/aurevoir.gif
END
					:email=><<-END,
Quelle est votre adresse email ? Vous aurez besoin d'un email valide pour confirmer votre choix de candidat.
END
					:email_optin=><<-END,
Est-ce que vous autorisez l'équipe de LaPrimaire.org (et seulement elle !) à vous envoyer un email de temps en temps ?
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
Pouvez-vous me redire dans quel pays vous habitez (en français) ?
END
					:city=><<-END,
Dans quelle ville habitez-vous ?
END
					:city_ask=><<-END,
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
					:answer=>"Je suis Français",
					:jump_to=>"welcome/condition_2"
				},
				:condition_1_ko=>{
					:answer=>"Je suis étranger",
					:callback=>"welcome/condition_ko_cb",
					:jump_to=>"welcome/condition_3_ko"
				},
				:condition_2=>{
					:text=>messages[:fr][:welcome][:condition_2],
					:kbd=>["welcome/condition_2_ok","welcome/condition_2_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:condition_2_ok=>{
					:answer=>"J'ai plus de 18 ans",
					:jump_to=>"welcome/condition_3"
				},
				:condition_2_ko=>{
					:answer=>"J'ai moins de 18 ans",
					:callback=>"welcome/condition_ko_cb",
					:jump_to=>"welcome/condition_3_ko"
				},
				:condition_3=>{
					:text=>messages[:fr][:welcome][:condition_3],
					:kbd=>["welcome/condition_3_ok","welcome/condition_3_ko"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:condition_3_ok=>{
					:answer=>"Oui, je pourrai voter",
					:text=>messages[:fr][:welcome][:condition_ok],
					:callback=>"welcome/condition_ok_cb",
					:jump_to=>"welcome/charte"
				},
				:condition_3_ko=>{
					:answer=>"Non, je n'irai pas voter",
					:callback=>"welcome/condition_ko_cb",
					:text=>messages[:fr][:welcome][:condition_ko],
					:disable_web_page_preview=>true
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
					:disable_web_page_preview=>true,
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
					:kbd=>["welcome/country","welcome/zipcode"],
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
					:jump_to=>"home/menu"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def welcome_condition_ko_cb(msg,user,screen)
		puts "welcome_charte_ko_cb" if DEBUG
		@users.set(user[:id],{
			:set=>'legal',
			:value=>false
		})
		@users.set(user[:id],{
			:set=>'can_vote',
			:value=>false
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_condition_ok_cb(msg,user,screen)
		puts "welcome_charte_ok_cb" if DEBUG
		@users.set(user[:id],{
			:set=>'legal',
			:value=>true
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_charte_ko_cb(msg,user,screen)
		puts "welcome_charte_ko_cb" if DEBUG
		@users.set(user[:id],{
			:set=>'charte',
			:value=>false
		})
		@users.set(user[:id],{
			:set=>'can_vote',
			:value=>false
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_charte_ok_cb(msg,user,screen)
		puts "welcome_charte_ok_cb" if DEBUG
		@users.set(user[:id],{
			:set=>'charte',
			:value=>true
		})
		@users.set(user[:id],{
			:set=>'can_vote',
			:value=>true
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_email(msg,user,screen)
		puts "welcome_enter_email" if DEBUG
		@users.next_answer(user[:id],'free_text',1,"welcome/save_email")
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_email(msg,user,screen)
		email=user['session']['buffer']
		puts "welcome_save_email: #{email}" if DEBUG
		if email.match(/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/).nil? then
			screen=self.find_by_name("welcome/email_error")
			return self.get_screen(screen,user,msg) 
		end
		res=@users.search({:by=>'email',:target=>email})
		if res.num_tuples > 0 and res[0]['user_id']!=user[:id] then
			screen=self.find_by_name("welcome/email_used")
			return self.get_screen(screen,user,msg) 
		end
		@users.next_answer(user[:id],'answer')
		@users.set(user[:id],{
			:set=>'email',
			:value=>email
		})
		screen=self.find_by_name("welcome/email_optin")
		return self.get_screen(screen,user,msg)
	end

	def welcome_email_optin_ok(msg,user,screen)
		puts "welcome_email_optin_ok" if DEBUG
		@users.set(user[:id],{
			:set=>'optin',
			:value=>true
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_country(msg,user,screen)
		puts "welcome_enter_country" if DEBUG
		@users.next_answer(user[:id],'free_text',1,"welcome/save_country")
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_country(msg,user,screen)
		country=user['session']['buffer']
		answer=Bot::Geo.countries.search(country,{hitsPerPage:1})
		return self.get_screen("welcome/country_error") if answer["hits"].length==0
		country=answer["hits"][0]["name"]
		puts "welcome_save_country: #{country}" if DEBUG
		@users.next_answer(user[:id],'answer')
		@users.set(user[:id],{
			:set=>'country',
			:value=>country
		})
		screen=self.find_by_name("welcome/city")
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_city(msg,user,screen)
		puts "welcome_enter_city" if DEBUG
		@users.next_answer(user[:id],'free_text',1,"welcome/city_ask")
		return self.get_screen(screen,user,msg)
	end

	def welcome_city_ask(msg,user,screen,city=nil)
		city= city.nil? ? user['session']['buffer'] : city
		country=user['country']
		puts "welcome_city_ask: #{city}" if DEBUG
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
		screen= user['country']=="FRANCE" ? self.find_by_name("welcome/zipcode") : self.find_by_name("welcome/city")
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_zipcode(msg,user,screen)
		puts "welcome_enter_zipcode" if DEBUG
		@users.set(user[:id],{
			:set=>'country',
			:value=>'FRANCE'
		})
		@users.next_answer(user[:id],'free_text',1,"welcome/save_zipcode")
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_zipcode(msg,user,screen)
		zipcode=user['session']['buffer'].delete(' ')
		zipcode="0"+zipcode if zipcode.length==4
		puts "welcome_save_zipcode: #{zipcode}" if DEBUG
		@users.set(user[:id],{
			:set=>'zipcode',
			:value=>zipcode
		})
		res=@geo.search({
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
end

include Welcome
