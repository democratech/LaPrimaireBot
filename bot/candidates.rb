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
	class Candidates
		def self.load_queries
			queries={
			'register_candidate'=><<END,
INSERT INTO candidates (user_id,uuid,name,zipcode,country,city_id,email) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *
END
			'get_candidate_by_uuid'=><<END,
SELECT z.*,c.firstname,c.lastname FROM candidates AS z LEFT JOIN citizens AS c ON (c.user_id=z.user_id) WHERE z.uuid=$1
END
			'set_gender'=><<END,
UPDATE candidates SET gender=$1 WHERE user_id=$2
END
			}
			queries.each { |k,v| Bot::Db.prepare(k,v) }
		end

		def initialize()
			@candidates={}
		end

		def add(user)
			uuid=a=(rand()*1000000000000).to_i
			name=[]
			name.push(user['firstname'].capitalize) if user['firstname']
			name.push(user['laststname'].upcase) if user['lastname']
			return Bot::Db.query("register_candidate",[user['id'],uuid,name.join(' '),user['zipcode'],user['country'],user['city_id'],user['email']])[0]
		end

		def get(candidate_info)
			res=self.search({
				:by=>"uuid",
				:target=>candidate_info['uuid']
			})
			candidate=res.num_tuples.zero? ? self.add(candidate_info) : res[0]
			candidate[:id]=user['user_id']
			@users[user[:id]]=user
			return user
		end

		def set(candidate_id,query)
			Bot::Db.query("set_"+query[:set],[query[:value],candidate_id]) 
			@users[candidate_id][query[:set]]=query[:value]
		end

		def search(query)
			return Bot::Db.query("get_candidate_by_"+query[:by],[query[:target]]) 
		end
	end
end
