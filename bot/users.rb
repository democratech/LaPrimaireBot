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
	class Users
		def initialize()
			@users={}
		end

		def add(user)
			u={
				:last_update_id=>nil,
				:current=>"home/welcome",
				:expected_input=>:answer,
				:expected_input_size=>-1,
				:buffer=>"",
				:new=>true,
				:first_name=>user.first_name,
				:last_name=>user.last_name,
				:id=>user.id,
				:username=>user.username
			}
			@users[u[:id]]=u
		end

		def update(user_id,data)
			data.each do |k,v|
				@users[user_id][k]=v
			end
		end

		def get(user_info)
			user=@users[user_info.id]
			user=self.add(user_info) if user.nil?
			return user
		end

		def already_answered(user_id,update_id)
			user=@users[user_id]
			return true if not user[:last_update_id].nil? and user[:last_update_id]>update_id.to_i
			self.update(user_id,{:last_update_id=>update_id.to_i})
			return false
		end
	end
end
