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
		class << self
			attr_accessor :index
		end

		def self.load_queries
			queries={
			'register_candidate'=><<END,
INSERT INTO candidates (candidate_id,name,photo) VALUES ($1,$2,$3) RETURNING *
END
			'delete_candidate'=><<END,
DELETE FROM candidates WHERE candidate_id=$1 RETURNING *
END
			'register_candidate_from_user'=><<END,
INSERT INTO candidates (user_id,candidate_id,name,zipcode,country,city_id,email,accepted,date_accepted) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *
END
			'add_supporter_to_candidate'=><<END,
INSERT INTO supporters (user_id,candidate_id) VALUES ($1,$2)
END
			'remove_supporter_from_candidate'=><<END,
DELETE FROM supporters WHERE user_id=$1 AND candidate_id=$2
END
			'get_candidate_by_candidate_id'=><<END,
SELECT z.*,c.firstname,c.lastname FROM candidates AS z LEFT JOIN citizens AS c ON (c.user_id=z.user_id) WHERE z.candidate_id=$1
END
			'get_candidates_supported_by_user_id'=><<END,
SELECT z.*,s.* FROM candidates AS z INNER JOIN supporters AS s ON (s.candidate_id=z.candidate_id) WHERE s.user_id=$1
END
			'set_gender'=><<END,
UPDATE candidates SET gender=$1 WHERE candidate_id=$2
END
			}
			queries.each { |k,v| Bot::Db.prepare(k,v) }
		end

		def initialize()
			@candidates={}
		end

		def add(candidat,skip_index=false)
			uuid=candidat['candidate_id'] ? candidat['candidate_id'] : ((rand()*1000000000000).to_i).to_s
			profile_pic=uuid+File.extname(candidat['photo'])
			Bot::Candidates.index.add_object({"objectID"=>uuid,"candidate_id"=>uuid,"name"=>candidat['name'],"photo"=>profile_pic}) unless skip_index
			return Bot::Db.query("register_candidate",[uuid,candidat['name'],profile_pic])[0]
		end

		def delete(candidate_id)
			Bot::Candidates.index.delete_object(candidate_id)
			res=Bot::Db.query("delete_candidate",[candidate_id])
			return res.num_tuples.zero? ? nil : res[0]
		end

		def add_current_user(user)
			uuid=a=(rand()*1000000000000).to_i
			name=[]
			name.push(user['firstname'].capitalize) if user['firstname']
			name.push(user['laststname'].upcase) if user['lastname']
			return Bot::Db.query("register_candidate_from_user",[user['id'],uuid,name.join(' '),user['zipcode'],user['country'],user['city_id'],user['email'],true,Time.now()])[0]
		end

		def get(candidate_info)
			res=self.search({
				:by=>"candidate_id",
				:target=>candidate_info['candidate_id']
			})
			candidate=res.num_tuples.zero? ? self.add(candidate_info) : res[0]
			candidate[:id]=candidate['candidate_id']
			return candidate
		end

		def set(candidate_id,query)
			Bot::Db.query("set_"+query[:set],[query[:value],candidate_id]) 
		end

		def supported_by(user_id)
			return Bot::Db.query("get_candidates_supported_by_user_id",[user_id])
		end

		def add_supporter(user_id,candidate_id)
			return Bot::Db.query("add_supporter_to_candidate",[user_id,candidate_id])
		end

		def remove_supporter(user_id,candidate_id)
			return Bot::Db.query("remove_supporter_from_candidate",[user_id,candidate_id])
		end

		def search_index(name)
			return Bot::Candidates.index.search(name,{hitsPerPage:1})
		end

		def search(query)
			return Bot::Db.query("get_candidate_by_"+query[:by],[query[:target]]) 
		end
	end
end
