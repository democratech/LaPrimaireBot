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
		Bot.log.info "loading About add-on"
		messages={
			:fr=>{
				:about=>{
					:menu=><<-END,
no_preview:LaPrimaire.org est une initiative citoyenne qui vise à faire émerger des candidats crédibles et représentatifs pour l’élection présidentielle de 2017, en dehors du cadre des partis politiques.
no_preview:A l’issue de la Primaire, un nouveau parti politique sera créé et une campagne de financement participatif lancée afin de permettre au candidat issu de LaPrimaire.org de concourir à l'élection présidentielle.
END
					:deroulement=><<-END,
La page <a href="https://laprimaire.org/deroulement">le déroulement de LaPrimaire</a> a la réponse à toutes vos interrogations sur le déroulement de LaPrimaire.org : Quel est le processus de sélection de LaPrimaire.org ? Quelles sont les grandes étapes ? Comment le candidat final sera-t-il sélectionné ? 
END
					:equipe=><<-END,
LaPrimaire.org est organisée par <a href="https://laprimaire.org/equipe/">des citoyens et des citoyennes ordinaires</a>, indépendants de tout parti politique, ayant pris un engagement de neutralité et ayant interdiction d'être candidats.
END
					:info=><<-END,
no_preview:<b>Qu'est-ce que LaPrimaire.org ?</b> LaPrimaire.org est une primaire ouverte, organisée pour permettre aux Français de choisir librement, de manière transparente et démocratique, les candidats qu'ils souhaitent voir se présenter à l'élection présidentielle de 2017 (voir <a href="https://laprimaire.org/manifeste/">notre manifeste</a>).
no_preview:<b>Quel intérêt ?</b> Aujourd'hui en France, les partis politiques (365,000 personnes soit moins de 1 pourcent de la population) désignent les candidats aux élections alors que les citoyens les rejettent massivement. L'objectif de LaPrimaire.org est d'insuffler un nouvel élan démocratique à notre pays en favorisant le renouvellement de notre classe politique.
no_preview:<b>Comment ça marche ?</b> Un processus de sélection des candidats (voir <a href="https://laprimaire.org/deroulement/">le déroulement</a>) a été spécifiquement mis au point pour permettre une primaire démocratique à laquelle toute personne peut se présenter et au sein de laquelle toutes les idées peuvent s'exprimer.
no_preview:<b>Comment participer ?</b> En tant que citoyen, vous pouvez soit participer en tant que votant et choisir / plébisciter les citoyens français que vous souhaiteriez voir plus impliquer dans la vie politique de notre pays. Vous également participer en tant que candidat si vous souhaitez porter vos idées et les présenter aux français. L'objectif est qu'au moins 100.000 citoyens participent à la primaire pour que celle-ci puisse avoir lieu.
no_preview:<b>Qui organise ?</b> LaPrimaire.org est organisée de manière entièrement bénévole par des citoyens ordinaires indépendants des partis politiques via une association loi 1901.
no_preview:<b>Qui finance ?</b> Pour financer LaPrimaire.org, nous avons ouvert une campagne de financement participatif. Si vous estimez que ce projet est utile pour l'avenir de notre démocratie, n'hésitez pas à <a href="https://laprimaire.org/financer/">faire un don</a>, selon vos moyens, peu importe le montant. Chaque don compte afin que la primaire puisse avoir lieu.
END
					:chiffres=><<-END,
Parce que sans transparence, il ne peut pas y avoir de confiance, et parce que ce sont vos dons qui financent la primaire, il nous paraissait normal, en retour, que nos chiffres et comptes soient <a href="https://laprimaire.org/transparence">totalement transparents</a>.
END
					:don=><<-END,
La participation à La Primaire est entièrement gratuite et son organisation ne repose que sur vos dons. Aidez-nous à faire de La Primaire un succès en <a href="https://laprimaire.org/financer/">soutenant financièrement LaPrimaire.org</a>.
END
					:etre_candidat=><<-END,
Si vous souhaitez être candidat, merci de remplir le formulaire <a href="https://laprimaire.org/inscription-candidat/">inscription candidat(e)</a>, en vous assurant au  préalable d'être en accord avec la <a href="https://laprimaire.org/charte/">charte du candidat</a>.
END
					:nous_contacter=><<-END,
N'hésitez à <a href='https://laprimaire.org/contact/'>nous contacter</a> si jamais vous avez des questions ou bien si quelque chose ne fonctionne pas. Nous essaierons de vous répondre dans les plus brefs délais.
END
					:diffuser=><<-END,
Rendez-vous sur la page <a href="https://laprimaire.org/partager/">Comment diffuser LaPrimaire.org ?</a> pour nous aider à atteindre <b>100.000 citoyens</b> et donner le plus de poids possible au candidat qui sortira de LaPrimaire.org. Nous sommes actuellement %{nb} participants (soit %{percentage}/100 de l'objectif). Aidez-nous à faire connaître LaPrimaire.org au plus grand nombre ! 
END
					:aide=><<-END,
Si ne comprenez pas comment soutenir un candidat ou bien si vous vous posez des questions sur le fonctionnement de Victoire, nous avons réalisé <a href="https://www.youtube.com/watch?v=3UdeS0NCRec">un tutoriel vidéo</a> qui vous montrera pas-à-pas comment procéder.
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
					:parse_mode=>"HTML",
					:kbd=>["about/deroulement","about/equipe","about/info","about/chiffres","about/don","about/etre_candidat","about/nous_contacter","about/retour"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:deroulement=>{
					:answer=>"Le déroulement",
					:text=>messages[:fr][:about][:deroulement],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:info=>{
					:answer=>"Le principe",
					:text=>messages[:fr][:about][:info],
					:parse_mode=>"HTML",
					:kbd=>["about/deroulement","about/equipe","about/info","about/chiffres","about/don","home/menu"],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
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
				},
				:etre_candidat=>{
					:answer=>"#{Bot.emoticons[:raising_hand]} Etre candidat",
					:text=>messages[:fr][:about][:etre_candidat],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:nous_contacter=>{
					:answer=>"#{Bot.emoticons[:envelope]} Nous contacter",
					:text=>messages[:fr][:about][:nous_contacter],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:diffuser=>{
					:answer=>"#{Bot.emoticons[:speaker]} Inviter vos amis",
					:text=>messages[:fr][:about][:diffuser],
					:callback=>"about/diffuser_cb",
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:aide=>{
					:answer=>"#{Bot.emoticons[:crying_face]} Besoin d'aide ?",
					:text=>messages[:fr][:about][:aide],
					:keep_kbd=>true,
					:parse_mode=>"HTML"
				},
				:retour=>{
					:answer=>"#{Bot.emoticons[:back]} Retour",
					:callback=>"about/retour_cb"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"about/diffuser"}}})
		Bot.addMenu({:home=>{:menu=>{:kbd=>"about/aide"}}})
		Bot.addMenu({:home=>{:menu=>{:kbd=>"about/menu"}}})
	end

	def about_diffuser_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		res=@users.get_total()
		nb=res[0]['nb_citizens'].to_i
		percentage=(100*(nb.to_f/100000.to_f)).to_i
		screen[:text]=screen[:text] % {nb:nb.to_s,percentage:percentage.to_s} 
		return self.get_screen(screen,user,msg)
	end


	def about_retour_cb(msg,user,screen)
		Bot.log.info "#{__method__}"
		from=user['session']['previous_session']['current']
		case from
		when "about/menu"
			screen=self.find_by_name("home/menu")
		else
			screen=self.find_by_name("home/menu")
		end
		@users.next_answer(user[:id],'answer')
		return self.get_screen(screen,user,msg)
	end
end

include About
