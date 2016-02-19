# encoding: utf-8

module MeCandidat
	def self.included(base)
		messages={
			:fr=>{
				:me_candidat=>{}
			}
		}
		screens={
			:me_candidat=>{
				:menu=>{
					:answer=>"#{Bot.emoticons[:finger_up]} Etre candidat",
					:text=>Bot.messages[:fr][:home][:not_implemented],
					:jump_to=>"home/menu"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"me_candidat/menu"}}})
	end
end

include MeCandidat
