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

module About
	def self.included(base)
		puts "loading About add-on" if DEBUG
		messages={
			:fr=>{
				:about=>{
					:menu=><<-END,
no_preview:LaPrimaire.org est une initiative citoyenne qui vise à faire émerger des candidats crédibles et représentatifs pour l’élection présidentielle de 2017, en dehors du cadre des partis politiques.
A l’issue de la Primaire, un nouveau parti politique sera créé et une campagne de financement participatif lancée afin de permettre au candidat issu de LaPrimaire.org de concourir à l'élection présidentielle.
no_preview:L'objectif est de parvenir à rassembler au minimum 100.000 citoyens pour donner du poids au candidat qui sera issu de LaPrimaire.org. Nous sommes actuellement %{nb} participants (soit %{percentage}/100 de l'objectif).
no_preview:<i>PS: Si le nombre de participants est plus petit que celui affiché sur le site web, c'est parce que l'application vient d'etre lancée et il faut laisser un peu de temps aux 22.000 citoyens pré-inscrits sur le site pour s'enregistrer sur l'application LaPrimaire.org #{Bot.emoticons[:smile]}</i>
END
					:deroulement=><<-END,
Cliquez pour voir <a href="https://laprimaire.org/deroulement">le déroulement de LaPrimaire</a>
END
					:equipe=><<-END,
Cliquez pour voir <a href="https://laprimaire.org/equipe">l'équipe derrière LaPrimaire.org</a>
END
					:info=><<-END,
Cliquez pour <a href="https://laprimaire.org">découvrir LaPrimaire.org</a>
END
					:chiffres=><<-END,
Accédez à tous les  <a href="https://laprimaire.org/transparence">les chiffres de LaPrimaire.org</a>
END
					:don=><<-END,
Cliquez ici pour  <a href="https://laprimaire.org/financer">soutenir financièrement LaPrimaire.org</a>
END
				}
			}
		}
		screens={
			:about=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:info]} A propos",
					:text=>messages[:fr][:about][:menu],
					:disable_web_page_preview=>true,
					:callback=>"about/menu_cb",
					:parse_mode=>"HTML",
					:kbd=>["about/deroulement","about/equipe","about/info","about/chiffres","about/don","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:deroulement=>{
					:answer=>"Déroulement",
					:text=>messages[:fr][:about][:deroulement],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:info=>{
					:answer=>"Principe",
					:text=>messages[:fr][:about][:info],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:chiffres=>{
					:answer=>"Nos chiffres",
					:text=>messages[:fr][:about][:chiffres],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:equipe=>{
					:answer=>"L'équipe",
					:text=>messages[:fr][:about][:equipe],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:don=>{
					:answer=>"Faire un don",
					:text=>messages[:fr][:about][:don],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"about/menu"}}})
		Bot.addMenu({:home=>{:menu=>{:kbd=>"home/nous_contacter"}}})
	end

	def about_menu_cb(msg,user,screen)
		puts "about_menu_cb" if DEBUG
		res=@users.get_total()
		nb=res[0]['nb_citizens'].to_i
		percentage=(100*(nb.to_f/100000.to_f)).to_i
		screen[:text]=screen[:text] % {nb:nb.to_s,percentage:percentage.to_s} 
		return self.get_screen(screen,user,msg)
	end

	def about_intro(msg,user,screen)
		puts "about_intro" if DEBUG
		return self.get_screen(screen,user,msg)
	end
end

include About
