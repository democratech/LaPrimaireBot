# encoding: utf-8

=begin
   LaPrimaire.org Bot helps french citizens participate to LaPrimaire.org
   Copyright 2016 Telegraph-ai

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
=end

module Bot
	class Log < Logger
		def initialize(*args)
			super(::DEBUG ? STDOUT : STDERR)
			self.level = ::DEBUG ? Logger::DEBUG : Logger::WARN
			unless ::DEBUG then
				@mixpanel=Mixpanel::Tracker.new(MIXPANEL_TOKEN)
			end
		end


		def people(user_id,action,infos)
			unless ::DEBUG then
				case action
				when 'increment'
					@mixpanel.people.increment(user_id,infos)
				when 'set'
					@mixpanel.people.set(user_id,infos)
				when 'append'
					@mixpanel.people.append(user_id,infos)
				else
					Bot.log.error "Log.people: Unknown logging action received"
				end
			else
				Bot.log.debug "unlogged people event : #{action}"
			end
		end

		def event(user_id,name,infos=nil)
			unless ::DEBUG then
				if infos.nil? then
					@mixpanel.track(user_id,name)
				else
					@mixpanel.track(user_id,name,infos)
				end
			else
				Bot.log.debug "unlogged event : #{name}"
			end
		end

		def slack_notification(msg,channel="supporteurs",icon=":ghost:",from="democratech",attachment=nil)
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
				Bot.log.error "An error occurred trying to send a Slack notification"
			end
		end

		def slack_notifications(notifs)
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
end
