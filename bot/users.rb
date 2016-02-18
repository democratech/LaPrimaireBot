# encoding: utf-8

module Bot
	class Users
		def initialize()
			@users={}
		end

		def add(user)
			u={
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
	end
end
