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

require_relative 'navigation.rb'

module Democratech
	class LaPrimaireBot < Grape::API
		format :json
		class << self
			attr_accessor :db, :mg_client, :mandrill, :tg_client, :token, :nav, :pg
		end

		helpers do
			def send_msg(id,msg,kbd,options)
				kbd = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true) if kbd.nil?
				lines=msg.split("\n")
				buffer=""
				max=lines.length
				idx=0
				image=false
				lines.each do |l|
					next if l.empty?
					idx+=1
					image=(l.start_with?("image:") && (['.jpg','.png','.gif','.jpeg'].include? File.extname(l)))
					if image && !buffer.empty? then # flush buffer before sending image
						writing_time=buffer.length/TYPINGSPEED
						LaPrimaireBot.tg_client.api.send_chat_action(chat_id: id, action: "typing")
						sleep(writing_time)
						LaPrimaireBot.tg_client.api.sendMessage(chat_id: id, text: buffer)
						buffer=""
					end
					if image then # sending image
						LaPrimaireBot.tg_client.api.send_chat_action(chat_id: id, action: "upload_photo")
						LaPrimaireBot.tg_client.api.send_photo(chat_id: id, photo: File.new(l.split(":")[1]))
					else # sending 1 msg for every line
						writing_time=l.length/TYPINGSPEED
						LaPrimaireBot.tg_client.api.sendChatAction(chat_id: id, action: "typing")
						sleep(writing_time)
						options[:chat_id]=id
						options[:text]=l
						if (kbd.nil? || idx<max) then
							LaPrimaireBot.tg_client.api.sendMessage(options)
						elsif (idx==max)
							options[:reply_markup]=kbd
							LaPrimaireBot.tg_client.api.sendMessage(options)
						end
					end
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
					puts "An error occurred trying to send a Slack notification\n"
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
					slack_notification(v,k,":bell:","democratech")
				end
			end
		end

		post '/' do
			update = Telegram::Bot::Types::Update.new(params)
			update_id = update.update_id
			message = update.message
			message_id = message.message_id
			msg,ans=Democratech::LaPrimaireBot.nav.get(message)
			send_msg(message.chat.id,msg,ans,disable_web_page_preview:true) unless msg.nil?
		end
	end
end
