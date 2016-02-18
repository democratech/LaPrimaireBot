# encoding: utf-8

module Bot
	@@botname="Victoire"
	@@name="La Primaire"
	@@emoticons={
		:blush=>"\u{1F60A}",
		:crying_face=>"\u{1F622}",
		:face_sunglasses=>"\u{1F60E}",
		:megaphone=>"\u{1F4E3}",
		:memo=>"\u{1F4DD}",
		:speech_balloon=>"\u{1F4AC}",
		:finger_up=>"\u{261D}",
		:french_flag=>"\u{1F1EB}",
		:finger_right=>"\u{1F449}",
		:house=>"\u{1F3E0}",
		:thumbs_up=>"\u{1F44D}",
		:thumbs_down=>"\u{1F44E}",
		:search=>"\u{1F50D}",
		:disappointed=>"\u{1F629}"
	}
	@@messages={
		:fr=>{
			:home=>{
				:welcome=><<-END,
Bonjour %{first_name} !
Je suis #{@@botname}, votre guide pour #{@@name} #{@@emoticons[:blush]}
Mon rôle est de vous accompagner et de vous informer tout au long du déroulement de La Primaire.
A tout moment, si vous avez des questions n'hésitez à me les poser, j'essaierais d'y répondre au mieux de mes capacités.
Mais assez parlé, commençons !
			END
				:intro=><<-END,
Que voulez-vous faire ?
				END
				:not_implemented=><<-END,
Désolée, je n'ai pas encore reçu les instructions pour vous guider dans ce choix #{@@emoticons[:crying_face]}
			END
				:pas_compris=><<-END,
Aïe, désolé %{first_name} j'ai peur de ne pas avoir compris ce que vous me demandez #{@@emoticons[:crying_face]}
			END
			}
		}
	}
	@@screens={
		:home=>{
			:welcome=>{
				:answer=>"/start",
				:text=>@@messages[:fr][:home][:welcome],
				:callback=>"home/welcome",
				:jump_to=>"home/intro"
			},
			:intro=>{
				:answer=>"#{@@emoticons[:home]} Accueil",
				:text=>@@messages[:fr][:home][:intro],
				:kbd=>["home/memo"],
				:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
			},
			:memo=>{
				:answer=>"#{@@emoticons[:memo]} Vous faire un retour",
				:text=>@@messages[:fr][:home][:not_implemented],
				:jump_to=>"home/intro"
			},
			:wtf=>{
				:text=>@@messages[:fr][:home][:pas_compris],
				:jump_to=>"home/intro"
			}
		}
	}
	def self.screens
		@@screens
	end

	def self.updateScreens(screens)
		@@screens=@@screens.merge(screens)
	end

	def self.messages
		@@messages
	end

	def self.updateMessages(messages)
		@@messages=@@messages.merge(messages)
	end

	def self.emoticons
		@@emoticons
	end

	def self.updateEmoticons(emoticons)
		@@emoticons=@@emoticons.merge(emoticons)
	end
end
