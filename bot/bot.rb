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
		:grinning=>"\u{1F600}",
		:frowning=>"\u{2639}",
		:info=>"\u{2139}",
		:halo=>"\u{1F607}",
		:tongue=>"\u{1F60B}",
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
		:house=>"\u{1F3E0}",
		:plus_sign=>"\u{2795}",
		:cross_mark=>"\u{274C}",
		:nb_0=>"\u{0030}",
		:nb_1=>"\u{0031}",
		:nb_2=>"\u{0032}",
		:nb_3=>"\u{0033}",
		:nb_4=>"\u{0034}",
		:nb_5=>"\u{0035}",
		:woman=>"\u{1F469}",
		:man=>"\u{1F468}",
		:inbox=>"\u{1F4E5}",
		:trash=>"\u{1F5D1}",
		:back=>"\u{21A9}"
	}
	@@messages={
		:fr=>{
			:system=>{
				:default=><<-END,
Aucun programme n'est actuellement chargé dans ce bot, ses capacités sont donc très limitées... mais vous pouvez toujours essayer :)
END
				:dont_understand=><<-END,
Aïe, désolé %{firstname} j'ai peur de ne pas avoir compris ce que vous me demandez #{@@emoticons[:crying_face]} Utilisez les boutons du clavier ci-dessous pour communiquer avec moi s'il vous plait.
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
				oldval.push(newval) 
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

	def self.slack_notification(msg,channel="supporteurs",icon=":ghost:",from="democratech",attachment=nil)
		uri = URI.parse(SLCKHOST)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Post.new(SLCKPATH)
		msg={
			"channel"=> channel,
			"username"=> from,
			"text"=> msg,
			"icon_emoji"=>icon
		}
		if attachment then
			msg["attachments"]=[{
				"fallback"=>attachment["fallback"]
			}]
			msg["attachments"][0]["color"]=attachment["color"] if attachment["color"]
			msg["attachments"][0]["pretext"]=attachment["pretext"] if attachment["pretext"]
			msg["attachments"][0]["title"]=attachment["title"] if attachment["title"]
			msg["attachments"][0]["title_link"]=attachment["title_link"] if attachment["title_link"]
			msg["attachments"][0]["text"]=attachment["text"] if attachment["text"]
			msg["attachments"][0]["image_url"]=attachment["image_url"] if attachment["image_url"]
			msg["attachments"][0]["thumb_url"]=attachment["image_url"] if attachment["thumb_url"]
		end
		request.body = "payload="+JSON.dump(msg)
		res=http.request(request)
		if not res.kind_of? Net::HTTPSuccess then
			raise "An error occurred trying to send a Slack notification\n"
		end
	end

	def self.slack_notifications(notifs)
		channels={}
		notifs.each do |n|
			msg=n[0] || ""
			chann=n[1] || "errors"
			icon=n[2] || ":warning:"
			from=n[3] || "democratech"
			if channels[chann].nil? then
				channels[chann]="%s *%s* %s" % [icon,from,msg]
			else
				channels[chann]+="\n%s *%s* %s" % [icon,from,msg]
			end
		end
		channels.each do |k,v|
			self.slack_notification(v,k,":bell:","democratech")
		end
	end
end
