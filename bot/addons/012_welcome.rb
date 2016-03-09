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
Quel est votre email ?
END
					:email_not_valid=><<-END,
Hmmm... cet email ne semble pas valide #{Bot.emoticons[:rolling_eyes]}
Quel est votre email ?
END
					:france=><<-END,
Habitez-vous en France (DOM-TOM inclus) ou à l'étranger ?
END
					:country=><<-END,
Dans quel pays habitez-vous ?
END
					:city=><<-END,
Et dans quelle ville habitez-vous ?
END
					:zipcode=><<-END,
Enfin, quel est le code postal de votre ville ?
END
					:mutliple_cities=><<-END,
Hmmmm... plusieurs villes correpondent à ce code postal #{Bot.emoticons[:thinking_face]} dans laquelle habitez-vous ?
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
					:jump_to=>"welcome/email"
				},
				:email=>{
					:text=>messages[:fr][:welcome][:email],
					:callback=>"welcome/enter_email"
				},
				:email_not_valid=>{
					:text=>messages[:fr][:welcome][:email_not_valid],
					:callback=>"welcome/enter_email"
				},
				:france=>{
					:text=>messages[:fr][:welcome][:france],
					:kbd=>["welcome/country","welcome/zipcode"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:zipcode=>{
					:answer=>"Oui j'habite en France",
					:text=>messages[:fr][:welcome][:zipcode],
					:callback=>"welcome/enter_zipcode"
				},
				:country=>{
					:answer=>"Non j'habite à l'étranger",
					:text=>messages[:fr][:welcome][:country],
					:callback=>"welcome/enter_country"
				},
				:city=>{
					:text=>messages[:fr][:welcome][:city],
					:callback=>"welcome/enter_city"
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
		@users.update_session(user[:id], {
			'expected_input'=>'free_text',
			'expected_input_size'=>1,
			'callback'=>"welcome/save_email"
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_email(msg,user,screen)
		email=user['session']['buffer']
		@users.update_session(user[:id],{
			'buffer'=>"",
			'expected_input'=>'answer',
			'expected_input_length'=>-1,
		})
		@users.save(user[:id],{'email'=>email})
		screen=self.find_by_name("welcome/france")
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_country(msg,user,screen)
		@users.update_session(user[:id], {
			'expected_input'=>'free_text',
			'expected_input_size'=>1,
			'callback'=>"welcome/save_country"
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_country(msg,user,screen)
		country=user['session']['buffer']
		@users.update_session(user[:id],{
			'buffer'=>"",
			'expected_input'=>'answer',
			'expected_input_length'=>-1,
		})
		@users.save(user[:id],{'country'=>country})
		screen=self.find_by_name("welcome/city")
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_city(msg,user,screen)
		@users.update_session(user[:id], {
			'expected_input'=>'free_text',
			'expected_input_size'=>1,
			'callback'=>"welcome/save_city"
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_city(msg,user,screen)
		city=user['session']['buffer']
		@users.update_session(user[:id],{
			'buffer'=>"",
			'expected_input'=>'answer',
			'expected_input_length'=>-1,
		})
		@users.save(user[:id],{'city'=>city})
		screen=self.find_by_name("welcome/account_created")
		return self.get_screen(screen,user,msg)
	end

	def welcome_enter_zipcode(msg,user,screen)
		@users.update_session(user[:id],{
			'expected_input'=>'free_text',
			'expected_input_size'=>1,
			'callback'=>"welcome/save_zipcode"
		})
		return self.get_screen(screen,user,msg)
	end

	def welcome_save_zipcode(msg,user,screen)
		zipcode=user['session']['buffer']
		@users.update_session(user[:id],{
			'buffer'=>"",
			'expected_input'=>'answer',
			'expected_input_length'=>-1,
		})
		@users.save(user[:id],{'zipcode'=>zipcode})
		screen=self.find_by_name("welcome/account_created")
		return self.get_screen(screen,user,msg)
	end
end

include Welcome
