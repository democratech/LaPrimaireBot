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
			queries={
			'register_user'=><<END,
INSERT INTO citizens (user_id,firstname,lastname,username,session) VALUES ($1,$2,$3,$4,$5::jsonb) RETURNING *
END
			'get_user_by_email'=><<END,
SELECT z.*,c.slug,c.zipcode,c.departement,c.lat_deg,c.lon_deg FROM citizens AS z LEFT JOIN cities AS c ON (c.city_id=z.city_id) WHERE z.email=$1
END
			'get_user_by_user_id'=><<END,
SELECT z.*,c.slug,c.zipcode,c.departement,c.lat_deg,c.lon_deg FROM citizens AS z LEFT JOIN cities AS c ON (c.city_id=z.city_id) WHERE z.user_id=$1
END
			'set_city'=><<END,
UPDATE citizens SET city=$1, city_id=v.city_id FROM (SELECT (SELECT b.city_id FROM cities AS b WHERE upper(b.name)=$1) as city_id) AS v WHERE citizens.user_id=$2;
END
			'set_session'=><<END,
UPDATE citizens SET session=$1 WHERE user_id=$2
END
			'set_betatester'=><<END,
UPDATE citizens SET betatester=$1 WHERE user_id=$2
END
			'set_reviewer'=><<END,
UPDATE citizens SET reviewer=$1 WHERE user_id=$2
END
			'set_email'=><<END,
UPDATE citizens SET email=$1 WHERE user_id=$2;
END
			'set_country'=><<END,
UPDATE citizens SET country=$1 WHERE user_id=$2;
END
			'set_zipcode'=><<END,
UPDATE citizens SET city_id=v.city_id FROM cities AS v WHERE v.zipcode=$1 AND citizens.user_id=$2;
END
			'remove_user'=><<END,
DELETE FROM citizens WHERE user_id=$1
END
			}
			queries.each { |k,v| Bot::Db.prepare(k,v) }
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

		def next_answer(user_id,type,size=-1,callback=nil)
			@users[user_id]['session'].merge!({
				'buffer'=>"",
				'expected_input'=>type,
				'expected_input_size'=>size,
				'callback'=>callback
			})
		end

		def get(user_info)
			res=self.search({
				:by=>"user_id",
				:target=>user_info.id
			})
			user=res.num_tuples.zero? ? self.add(user_info) : res[0]
			user['session']=JSON.parse(user['session'])
			user[:id]=user['user_id']
			@users[user[:id]]=user
			return user
		end

		def save_user_session(user_id)
			self.set(user_id,{
				:set=>"session",
				:value=>JSON.dump(@users[user_id]['session'])
			})
		end

		def already_answered(user_id,update_id)
			session=@users[user_id]['session']
			return true if not session['last_update_id'].nil? and session['last_update_id'].to_i>update_id.to_i
			self.update_session(user_id,{'last_update_id'=>update_id.to_i})
			return false
		end

		def set(user_id,query)
			Bot::Db.query("set_"+query[:set],[query[:value],user_id])
			@users[user_id][query[:set]]=query[:value]
		end

		def search(query)
			return Bot::Db.query("get_user_by_"+query[:by],[query[:target]]) 
		end
	end
end
