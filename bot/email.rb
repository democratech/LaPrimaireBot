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
	class Email
		@@mandrill=nil

		def self.init
			Bot.log.debug "initializing Mandrill"
			@@mandrill=Mandrill::API.new(MANDRILLKEY)
		end

		def self.send(name,email,vars)
			message= {
				:to=>[{
					:email=> "#{email}"
				}],
				:merge_vars=>[{
					:rcpt=>"#{email}",
					:vars=>[]
				}]
			}
			if not vars.nil? then
				vars.each do |k,v|
					message[:merge_vars][0][:vars].push({:name=>k,:content=>v})
				end
			end
			begin
				result=@@mandrill.messages.send_template(name,[],message)
				res={
					:email=>result[0]['email'],
					:status=>result[0]['status'],
					:reject_reason=>result[0]['reject_reason'],
					:id=>result[0]['_id']
				}
			rescue Mandrill::Error => e
				Bot.log.error("A mandrill error occurred: #{e.class} - #{e.message}")
			end
			sent=(res[:status]!="sent")
			Bot.log.error("Email could not be send: #{res.inspect}")
			return sent
		end
	end
end
