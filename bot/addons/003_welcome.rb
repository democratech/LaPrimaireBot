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
A tout moment, si vous avez des questions n'hésitez à me les poser, j'essaierais d'y répondre au mieux de mes capacités.
Mais assez parlé, commençons par vous créer un compte !
END
					:email=><<-END,
Quelle est votre adresse email ?
END
					:email_optin=><<-END,
Est-ce que vous acceptez que l'équipe de LaPrimaire.org (et seulement elle !) puisse vous envoyer un email de temps en temps ?
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
					:jump_to=>"welcome/email"
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
