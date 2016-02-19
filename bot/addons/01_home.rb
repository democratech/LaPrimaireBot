# encoding: utf-8

module Home
	def self.included(base)
		messages={
			:fr=>{
				:home=>{
					:welcome=><<-END,
Bonjour %{first_name} !
Je suis Victoire, votre guide pour LaPrimaire #{Bot.emoticons[:blush]}
Mon rôle est de vous accompagner et de vous informer tout au long du déroulement de La Primaire.
A tout moment, si vous avez des questions n'hésitez à me les poser, j'essaierais d'y répondre au mieux de mes capacités.
Mais assez parlé, commençons !
END
					:menu=><<-END,
Que voulez-vous faire ?
	END
					:not_implemented=><<-END,
Désolée, je n'ai pas encore reçu les instructions pour vous guider dans ce choix #{Bot.emoticons[:crying_face]}
END
					:pas_compris=><<-END,
Aïe, désolé %{first_name} j'ai peur de ne pas avoir compris ce que vous me demandez #{Bot.emoticons[:crying_face]}
END
				}
			}
		}
		screens={
			:home=>{
				:welcome=>{
					:answer=>"/start",
					:text=>messages[:fr][:home][:welcome],
					:callback=>"home/welcome",
					:jump_to=>"home/menu"
				},
				:menu=>{
					:answer=>"#{Bot.emoticons[:home]} Accueil",
					:text=>messages[:fr][:home][:menu],
					:kbd=>[],
					:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
				},
				:memo=>{
					:answer=>"#{Bot.emoticons[:memo]} Vous faire un retour",
					:text=>messages[:fr][:home][:not_implemented],
					:jump_to=>"home/menu"
				},
				:wtf=>{
					:text=>messages[:fr][:home][:pas_compris],
					:jump_to=>"home/menu"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"home/memo"}}})
	end
end

include Home
