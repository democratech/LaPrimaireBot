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
		def self.load_queries
			register_user=<<END
INSERT INTO citizens (telegram_id,firstname,lastname,username,session) VALUES ($1,$2,$3,$4,$5::jsonb) RETURNING *
END
			save_user_email=<<END
UPDATE citizens SET email=$1 WHERE telegram_id=$2;
END
			get_user_by_tgid=<<END
SELECT z.*,c.* FROM citizens AS z LEFT JOIN cities AS c ON (z.telegram_id=$1 AND c.city_id=z.city_id)
END
			get_city_by_zipcode=<<END
SELECT c.* FROM cities AS c WHERE c.zipcode=$1
END
			save_user_city=<<END
UPDATE citizens SET city_id=$1 WHERE telegram_id=$2
END
			remove_user=<<END
DELETE FROM citizens WHERE telegram_id=$1
END
			save_user_session=<<END
UPDATE citizens SET session=$1 WHERE telegram_id=$2
END
			Bot::Db.prepare("register_user",register_user)
			Bot::Db.prepare("save_user_email",save_user_email)
			Bot::Db.prepare("get_user_by_tgid",get_user_by_tgid)
			Bot::Db.prepare("get_city_by_zipcode",get_city_by_zipcode)
			Bot::Db.prepare("save_user_city",save_user_city)
			Bot::Db.prepare("remove_user",remove_user)
			Bot::Db.prepare("save_user_session",save_user_session)
		end

		def initialize()
			@users={}
		end

		def add(user)
			bot_session={
				'last_update_id'=>nil,
				'current'=>nil,
				'expected_input'=>:answer,
				'expected_input_size'=>-1,
				'buffer'=>""
			}
			return Bot::Db.query("register_user",[user.id,user.first_name,user.last_name,user.username,JSON.dump(bot_session)])[0]
		end

		def get_session(user_id)
			return @users[user_id]['session']
		end

		def update_session(user_id,data)
			data.each do |k,v|
				@users[user_id]['session'][k]=v
			end
			return self.get_session(user_id)
		end

		def save(user_id,data)
			puts "SAVE user_id: %s data: %s" % [user_id,data.inspect]
		end

		def get(user_info)
			res=Bot::Db.query("get_user_by_tgid",[user_info.id])
			user=res.num_tuples.zero? ? self.add(user_info) : res[0]
			user['session']=JSON.parse(user['session'])
			user[:id]=user['telegram_id']
			@users[user[:id]]=user
			return user
		end

		def save_user_session(user_id)
			res=Bot::Db.query("save_user_session",[JSON.dump(@users[user_id]['session']),user_id])
		end

		def already_answered(user_id,update_id)
			session=@users[user_id]['session']
			return true if not session['last_update_id'].nil? and session['last_update_id'].to_i>update_id.to_i
			self.update_session(user_id,{'last_update_id'=>update_id.to_i})
			return false
		end
	end
end
