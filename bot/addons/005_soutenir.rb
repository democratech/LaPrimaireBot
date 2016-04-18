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

module SoutenirCandidat
	# is being called when the module is included
	# here you need to update the Bot with your Add-on screens and hook your entry point into the Bot's menu
	def self.included(base)
		puts "loading SoutenirCandidat add-on" if DEBUG
		messages={
			:fr=>{
				:soutenir_candidat=>{
					:chercher_candidat=><<-END,
Quel(le) candidat(e) cherchez-vous ? (ou tapez '/start' pour revenir au menu)
END
				}
			}
		}
		screens={
			:soutenir_candidat=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:thumbs_up]} Soutenir un candidat",
					:text=>messages[:fr][:soutenir_candidat][:menu],
					:callback=>"mes_candidats/chercher_candidat_cb",
					:kbd=>["soutenir_candidat/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:retour=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"mes_candidats/back_cb",
					:jump_to=>"home/menu"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"soutenir_candidat/menu"}}})
	end

	def soutenir_candidat_menu_cb(msg,user,screen)
		stats=@candidates.stats(user[:id])
		non_vus=stats['verified'].to_i - stats['viewed'].to_i
		incomplets=stats['total'].to_i - stats['verified'].to_i
		vus= non_vus>1 ? "vus" : "vu"
		screen[:text]=screen[:text] % {nb_candidats_complets: stats['verified'].to_s, nb_candidats_non_vus: non_vus.to_s, nb_candidats_incomplets: incomplets.to_s, vus: vus}
		screen[:parse_mode]='HTML'
		return self.get_screen(screen,user,msg)
	end
end

include SoutenirCandidat
