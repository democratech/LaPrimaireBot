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
				raise "An error occurred trying to send a Slack notification\n"
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
