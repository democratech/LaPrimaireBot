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

module MoiCandidat
	def self.included(base)
		puts "loading MoiCandidat add-on" if DEBUG
		messages={
			:fr=>{
				:moi_candidat=>{
					:start=><<-END,
Mais... c'est vous %{firstname} %{lastname} !
Merci beaucoup pour votre intérêt à devenir candidat(e).
La possibilité de se déclarer candidat sur LaPrimaire.org sera mise en ligne très bientôt !
END
					:charte=><<-END,
Pour être candidat, il vous faut accepter la Charte du candidat.
END
					:charte_ok=><<-END,
Bien enregistré !
END
					:charte_ko=><<-END,
Désolé vous devez accepter la Charte du candidat pour pouvoir être candidat.
END
					:gender=><<-END,
Etes-vous un homme ou une femme ?
END
					:phone=><<-END,
Quel est votre numéro de téléphone ?
END
					:scope=><<-END,
Avez-vous un programme complet ou bien êtes-vous focalisé sur une thématique précise ?
END
					:team=><<-END,
Avez-vous déjà une équipe qui travaille avec vous ?
END
					:political_party=><<-END,
Avez-vous déjà été membre d'un parti politique ?
END
					:already_candidate=><<-END,
Avez-vous déjà été candidat(e) à une élection publique ?
END
					:already_elected=><<-END,
Avez-vous déjà exercé un mandat public ?
END
					:website=><<-END,
Merci pour votre intérêt à devenir
END
				}
			}
		}
		screens={
			:moi_candidat=>{
				:start=>{
					:text=>messages[:fr][:moi_candidat][:start],
					:callback=>"moi_candidat/intro",
					:disable_web_page_preview=>true,
					:kbd=>["mes_candidats/back"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:gender=>{
					:text=>messages[:fr][:moi_candidat][:gender],
					:kbd=>["moi_candidat/gender_m","moi_candidat/gender_f"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true},
					:jump_to=>"moi_candidat/scope"
				},
				:gender_m=>{
					:answer=>"Un homme",
					:callback=>"moi_candidat/gender_m",
					:jump_to=>"moi_candidat/scope"
				},
				:gender_f=>{
					:answer=>"Une femme",
					:callback=>"moi_candidat/gender_f",
					:jump_to=>"moi_candidat/scope"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def moi_candidat_intro(msg,user,screen)
		return self.get_screen(screen,user,msg)
	end

	def moi_candidat_gender_m(msg,user,screen)
		@candidates.set(user[:id],{:set=> 'gender',:value=>'M'})
		return self.get_screen(screen,user,msg)
	end

	def moi_candidat_gender_f(msg,user,screen)
		@candidates.set(user[:id],{:set=> 'gender',:value=>'F'})
		return self.get_screen(screen,user,msg)
	end
end

include MoiCandidat
