# encoding: utf-8

module Bot
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
	@@messages={}
	@@screens={}

	def self.mergeHash(old_path,new_path)
		return old_path.merge(new_path) do |key,oldval,newval| 
			if oldval.class.to_s=="Hash" then
				self.mergeHash(oldval,newval)
			else
				newval
			end
		end
	end

	def self.mergeMenu(old_path,new_path)
		return old_path.merge(new_path) do |key,oldval,newval| 
			if key==:kbd then
				oldval.unshift(newval) 
			else
				self.mergeMenu(oldval,newval)
			end
		end
	end

	def self.addMenu(path)
		@@screens=self.mergeMenu(@@screens,path) 
	end

	def self.updateScreens(new_screens)
		@@screens=self.mergeHash(@@screens,new_screens)
	end

	def self.updateMessages(new_messages)
		@@messages=self.mergeHash(@@messages,new_messages)
	end

	def self.updateEmoticons(new_emoticons)
		@@emoticons=self.mergeHash(@@emoticons,new_emoticons)
	end

	def self.screens
		@@screens
	end

	def self.messages
		@@messages
	end

	def self.emoticons
		@@emoticons
	end
end
