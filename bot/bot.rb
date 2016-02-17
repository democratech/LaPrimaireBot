# encoding: utf-8

module Democratech
	class Bot < Grape::API
		format :json
		class << self
			attr_accessor :db, :mg_client, :mandrill, :tg_client, :token
		end

		post '/' do
			update = Telegram::Bot::Types::Update.new(params)
			update_id = update.update_id
			message = update.message
			message_id = message.message_id

			# echo-server, just for test purpose
			case message.text
			when /.+/
				text = "#{message.from.first_name}:#{message.text}"
				chat_id = message.chat.id

				# send echo tu user 
				Bot.tg_client.api.send_message(chat_id: chat_id, text: text)
				puts "#{self.class.name}:#{text}"
			end
		end

		helpers do
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
	end
end
