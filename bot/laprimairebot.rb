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
		prefix PREFIX.to_sym
		format :json
		class << self
			attr_accessor :mandrill, :tg_client, :nav, :mixpanel
		end

		helpers do
			def authorized
				headers['Secret-Key']==SECRET
			end

			def send_msg(id,msg,options)
				if options[:keep_kbd] then
					options.delete(:keep_kbd)
				else
					kbd = options[:kbd].nil? ? Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true) : options[:kbd] 
				end
				lines=msg.split("\n")
				buffer=""
				max=lines.length
				idx=0
				image=false
				kbd_hidden=false
				lines.each do |l|
					next if l.empty?
					idx+=1
					image=(l.start_with?("image:") && (['.jpg','.png','.gif','.jpeg'].include? File.extname(l)))
					if !image.nil? && !image.empty? && !buffer.empty? then # flush buffer before sending image
						writing_time=buffer.length/TYPINGSPEED
						LaPrimaireBot.tg_client.api.send_chat_action(chat_id: id, action: "typing")
						sleep(writing_time)
						LaPrimaireBot.tg_client.api.sendMessage(chat_id: id, text: buffer)
						buffer=""
					end
					if !image.nil? && !image.empty? then # sending image
						LaPrimaireBot.tg_client.api.send_chat_action(chat_id: id, action: "upload_photo")
						LaPrimaireBot.tg_client.api.send_photo(chat_id: id, photo: File.new(l.split(":")[1]))
					elsif options[:groupsend] # grouping lines into 1 single message # buggy
						buffer+=l
						if (idx==max) then # flush buffer
							writing_time=l.length/TYPINGSPEED
							LaPrimaireBot.tg_client.api.sendChatAction(chat_id: id, action: "typing")
							sleep(writing_time)
							LaPrimaireBot.tg_client.api.sendMessage(chat_id: id, text: buffer, reply_markup:kbd)
							buffer=""
						end
					else # sending 1 msg for every line
						writing_time=l.length/TYPINGSPEED
						writing_time=l.length/TYPINGSPEED_SLOW if max>1
						LaPrimaireBot.tg_client.api.sendChatAction(chat_id: id, action: "typing")
						sleep(writing_time)
						options[:chat_id]=id
						options[:text]=l
						if idx<max and not kbd_hidden then
							options[:reply_markup]=Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
							kbd_hidden=true
						elsif (idx==max)
							options[:reply_markup]=kbd
						end
						LaPrimaireBot.tg_client.api.sendMessage(options)
					end
				end
			end
		end

		post '/command' do
			error!('401 Unauthorized', 401) unless authorized
			update = Telegram::Bot::Types::Update.new(params)
			begin
				msg,options=Democratech::LaPrimaireBot.nav.get(update.message,update.update_id)
				send_msg(update.message.chat.id,msg,options) unless msg.nil?
			rescue Exception=>e
				Bot.slack_notification(e.message,"errors",":bomb:","bot",{"fallback"=>"Bot error stack trace","color"=>"warning","text"=>e.backtrace.inspect}) if PRODUCTION
				STDERR.puts "#{e.message}\n#{e.backtrace.inspect}"
				error! "Exception raised: #{e.message}", 200 # if you put an error code here, telegram will keep sending you the same msg until you die
			end
		end

		post '/' do
			update = Telegram::Bot::Types::Update.new(params)
			begin
				msg,options=Democratech::LaPrimaireBot.nav.get(update.message,update.update_id)
				send_msg(update.message.chat.id,msg,options) unless msg.nil?
			rescue Exception=>e
				Bot.slack_notification(e.message,"errors",":bomb:","bot",{"fallback"=>"Bot error stack trace","color"=>"warning","text"=>e.backtrace.inspect}) if PRODUCTION
				STDERR.puts "#{e.message}\n#{e.backtrace.inspect}"
				error! "Exception raised: #{e.message}", 200 # if you put an error code here, telegram will keep sending you the same msg until you die
			end
		end
	end
end
