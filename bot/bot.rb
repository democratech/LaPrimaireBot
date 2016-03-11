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

module Bot
	@@emoticons={ # see http://unicode.org/emoji/charts/full-emoji-list.html
		:blush=>"\u{1F60A}",
		:info=>"\u{2139}",
		:crying_face=>"\u{1F622}",
		:face_sunglasses=>"\u{1F60E}",
		:megaphone=>"\u{1F4E3}",
		:memo=>"\u{1F4DD}",
		:speech_balloon=>"\u{1F4AC}",
		:finger_up=>"\u{261D}",
		:french_flag=>"\u{1F1EB}",
		:finger_right=>"\u{1F449}",
		:home=>"\u{1F3E0}",
		:thumbs_up=>"\u{1F44D}",
		:thumbs_down=>"\u{1F44E}",
		:search=>"\u{1F50D}",
		:very_disappointed=>"\u{1F629}",
		:disappointed=>"\u{1F61E}",
		:rocket=>"\u{1F680}",
		:little_smile=>"\u{1F642}",
		:smile=>"\u{1F603}",
		:confused=>"\u{1F615}",
		:rolling_eyes=>"\u{1F644}",
		:thinking_face=>"\u{1F914}",
		:head_bandage_face=>"\u{1F915}",
		:bomb=>"\u{1F4A3}",
		:earth=>"\u{1F30D}",
		:house=>"\u{1F3E0}"
	}
	@@messages={
		:fr=>{
			:system=>{
				:default=><<-END,
Aucun programme n'est actuellement chargé dans ce bot, ses capacités sont donc très limitées... mais vous pouvez toujours essayer :)
END
				:dont_understand=><<-END,
Aïe, désolé %{firstname} j'ai peur de ne pas avoir compris ce que vous me demandez #{@@emoticons[:crying_face]}
END
				:something_wrong=><<-END,
Apparemment, un petit souci informatique est survenu #{@@emoticons[:head_bandage_face]} il va nous falloir reprendre depuis le début, désolé #{@@emoticons[:confused]}
END
			}
		}

	}
	@@screens={
		:system=>{
			:default=>{
				:text=>@@messages[:fr][:system][:default],
			},
			:dont_understand=>{
				:text=>@@messages[:fr][:system][:dont_understand],
				:keep_kbd=>true
			},
			:something_wrong=>{
				:text=>@@messages[:fr][:system][:something_wrong]
			}
		}
	}

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
