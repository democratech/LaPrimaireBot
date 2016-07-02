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
	class Email
		@@mandrill=nil

		def self.init
			if MANDRILL then
				Bot.log.debug "initializing Mandrill"
				@@mandrill=Mandrill::API.new(MANDRILLKEY)
			end
		end

		def self.send(name,email,vars)
			if MANDRILL then
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
				Bot.log.error("Email could not be sent: #{res.inspect}") unless res[:status]=="sent"
				return res[:status]=="sent"
			else
				Bot.log.debug "MANDRILL disabled: email #{name} to #{emails} not sent"
			end
		end
	end
end
