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
SELECT y.candidate_id, y.name, y.gender, y.verified, y.nb_days_added,y.nb_days_verified, count(y.user_id) as nb_supporters
  FROM (
	  SELECT z.candidate_id,z.name,z.gender,s.user_id,z.verified,date_part('day',now()-z.date_added) as nb_days_added,date_part('day',now() - z.date_verified) as nb_days_verified
          FROM candidates AS z
          INNER JOIN supporters AS s
	  ON (s.candidate_id = z.candidate_id)
	  WHERE s.user_id = $1
  ) as y
  INNER JOIN supporters AS x
  ON (x.candidate_id = y.candidate_id)
  GROUP BY y.candidate_id,y.name,y.gender,y.verified,y.nb_days_added,y.nb_days_verified
  ORDER BY y.verified ASC, nb_supporters DESC
END
			'get_citizens_supported_by_user_id'=><<END,
SELECT y.candidate_id, y.name, y.gender, count(y.user_id) as nb_supporters
  FROM (
	  SELECT z.candidate_id,z.name,z.gender,s.user_id
          FROM candidates AS z
          INNER JOIN supporters AS s
	  ON (s.candidate_id = z.candidate_id)
	  WHERE s.user_id = $1 AND (NOT z.verified OR z.verified IS NULL)
  ) as y
  INNER JOIN supporters AS x
  ON (x.candidate_id = y.candidate_id)
  GROUP BY y.candidate_id,y.name,y.gender
  ORDER BY nb_supporters DESC
END

			'set_gender'=><<END,
UPDATE candidates SET gender=$1 WHERE candidate_id=$2
END
			'get_stats_by_user_id'=><<END,
SELECT count(c.user_id) as total, sum(
	       case
	       when verified then 1
	       else 0
	       end
       ) AS verified, count(cv.user_id) AS viewed
  FROM candidates AS c
  LEFT JOIN candidates_views AS cv
    ON (
	       cv.candidate_id = c.candidate_id
	   AND cv.user_id=$1
       )
 WHERE c.user_id IS NOT null;
END
			'get_verified_candidate_by_id'=><<END,
SELECT ca.*, z.nb_views, z.nb_soutiens, z.mon_soutien
  FROM candidates as ca
 INNER JOIN (
		SELECT c.candidate_id, (
			       case
			       when cv.nb_views is null then 0
			       else cv.nb_views
			       end
		       ) as nb_views, count(s.user_id) as nb_soutiens, (
			       case
			       when s2.user_id is not null then true
			       else false
			       end
		       ) as mon_soutien
		  FROM candidates as c
		  LEFT JOIN candidates_views as cv
		    ON (
			       cv.candidate_id=c.candidate_id
			   AND cv.user_id=$2
		       )
		  LEFT JOIN supporters as s
		    ON ( s.candidate_id=c.candidate_id)
		  LEFT JOIN supporters as s2
		    ON (
			       s2.candidate_id=c.candidate_id
			   AND s2.user_id=$2
		       )
		 WHERE c.verified AND c.candidate_id=$1
		 GROUP BY c.candidate_id, cv.nb_views, s2.user_id
       ) as z
    ON (z.candidate_id = ca.candidate_id)
END
			'get_candidate_by_id'=><<END,
SELECT ca.*, z.nb_views, z.nb_soutiens, z.mon_soutien
  FROM candidates as ca
 INNER JOIN (
		SELECT c.candidate_id, (
			       case
			       when cv.nb_views is null then 0
			       else cv.nb_views
			       end
		       ) as nb_views, count(s.user_id) as nb_soutiens, (
			       case
			       when s2.user_id is not null then true
			       else false
			       end
		       ) as mon_soutien
		  FROM candidates as c
		  LEFT JOIN candidates_views as cv
		    ON (
			       cv.candidate_id=c.candidate_id
			   AND cv.user_id=$2
		       )
		  LEFT JOIN supporters as s
		    ON ( s.candidate_id=c.candidate_id)
		  LEFT JOIN supporters as s2
		    ON (
			       s2.candidate_id=c.candidate_id
			   AND s2.user_id=$2
		       )
		 WHERE c.candidate_id=$1
		 GROUP BY c.candidate_id, cv.nb_views, s2.user_id
       ) as z
    ON (z.candidate_id = ca.candidate_id)
END
			'get_next_candidate_by_user_id'=><<END,
SELECT ca.*, z.nb_views, z.nb_soutiens, z.mon_soutien
  FROM candidates as ca
 INNER JOIN (
		SELECT c.candidate_id, (
			       case
			       when cv.nb_views is null then 0
			       else cv.nb_views
			       end
		       ) as nb_views, count(s.user_id) as nb_soutiens, (
			       case
			       when s2.user_id is not null then true
			       else false
			       end
		       ) as mon_soutien
		  FROM candidates as c
		  LEFT JOIN candidates_views as cv
		    ON (
			       cv.candidate_id=c.candidate_id
			   AND cv.user_id=$1
		       )
		  LEFT JOIN supporters as s
		    ON ( s.candidate_id=c.candidate_id)
		  LEFT JOIN supporters as s2
		    ON (
			       s2.candidate_id=c.candidate_id
			   AND s2.user_id=$1
		       )
		 WHERE c.verified
		 GROUP BY c.candidate_id, cv.nb_views, s2.user_id
       ) as z
    ON (z.candidate_id = ca.candidate_id)
    ORDER BY z.nb_views ASC, z.nb_soutiens DESC
END
			'update_views_by_user_id'=><<END,
UPDATE candidates_views SET nb_views=nb_views+1, last_view=now() WHERE candidate_id=$1 AND user_id=$2
END
			'add_viewer_for_candidate_id'=><<END,
INSERT INTO candidates_views (candidate_id,user_id) VALUES ($1,$2) RETURNING *
END
			'search_candidate_by_name'=><<END,
SELECT c.* FROM candidates AS c WHERE c.name ~* $1 AND c.verified LIMIT $2
END
			'does_viewer_exists'=><<END,
SELECT * FROM candidates_views WHERE candidate_id=$1 AND user_id=$2
END
			}
			queries.each { |k,v| Bot::Db.prepare(k,v) }
		end

		def initialize()
			index_candidats=DEBUG ? "search_test" : "search"
			Bot.log.info "using index #{index_candidats}"
			@index=Algolia::Index.new(index_candidats)
			@citizens_idx=Algolia::Index.new('citizens')
			@candidates_idx=Algolia::Index.new('candidates')
		end

		def add(candidat,skip_index=false)
			uuid=candidat['candidate_id'] ? candidat['candidate_id'] : ((rand()*1000000000000).to_i).to_s
			profile_pic="#{uuid}"+File.extname(candidat['photo'])
			@index.add_object({"objectID"=>uuid,"candidate_id"=>uuid,"name"=>candidat['name'],"photo"=>profile_pic}) unless skip_index
			return Bot::Db.query("register_candidate",[uuid,candidat['name'],profile_pic])[0]
		end

		def delete(candidate_id)
			@index.delete_object(candidate_id)
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

		def find(candidate_id,user_id)
			#res=Bot::Db.query("get_verified_candidate_by_id",[candidate_id,user_id])
			res=Bot::Db.query("get_candidate_by_id",[candidate_id,user_id])
			return nil if res.num_tuples.zero?
			candidate=res[0]
			self.add_viewer(candidate['candidate_id'].to_i,user_id) if candidate['nb_views'].to_i==0
			self.increment_view_count(candidate['candidate_id'].to_i,user_id)
			return candidate
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

		def proposed_by(user_id)
			return Bot::Db.query("get_citizens_supported_by_user_id",[user_id])
		end

		def add_supporter(user_id,candidate_id)
			res=Bot::Db.query("get_candidate_by_id",[candidate_id,user_id])
			return nil if res.num_tuples.zero?
			candidate=res[0]
			res=self.supported_by(user_id)
			if not res.num_tuples.zero? then
				res.each do |r|
					# citizen already supports this candidate
					return if r['candidate_id'].to_i==candidate_id.to_i
				end
			end
			nb_candidates_supported=0;
			nb_citizens_supported=0;
			if not res.num_tuples.zero? then
				res.each do |r|
					if r['verified'].to_b then
						nb_candidates_supported+=1;
					else
						nb_citizens_supported+=1;
					end
				end
			end
			if candidate['verified'].to_b then
				return if nb_candidates_supported>4
			else
				return if nb_citizens_supported>4
			end
			return Bot::Db.query("add_supporter_to_candidate",[user_id,candidate_id])
		end

		def remove_supporter(user_id,candidate_id)
			return Bot::Db.query("remove_supporter_from_candidate",[user_id,candidate_id])
		end

		def search_index(name)
			return @index.search(name,{hitsPerPage:1})
		end

		def search_candidate(name,limit=6)
			return @candidates_idx.search(name,{hitsPerPage:1})
		end

		def search(query)
			return Bot::Db.query("get_candidate_by_"+query[:by],[query[:target]]) 
		end

		def add_viewer(candidate_id,user_id)
			res=Bot::Db.query('does_viewer_exists',[candidate_id,user_id])
			view=nil
			view=Bot::Db.query('add_viewer_for_candidate_id',[candidate_id,user_id]) if res.num_tuples.zero?
			return view
		end

		def increment_view_count(candidate_id,user_id)
			return Bot::Db.query('update_views_by_user_id',[candidate_id,user_id])
		end

		def next_candidate(user_id)
			res=Bot::Db.query('get_next_candidate_by_user_id',[user_id])
			nb_views=res[0]['nb_views'].to_i
			idx=0
			candidates={}
			random=[]
			res.each_with_index do |r,i|
				break if r['nb_views'].to_i>nb_views
				candidates[r['candidate_id']]=r
				random.push(r['candidate_id'])
			end
			candidate=candidates[random[rand(random.length)]]
			self.add_viewer(candidate['candidate_id'].to_i,user_id) if candidate['nb_views'].to_i==0
			self.increment_view_count(candidate['candidate_id'].to_i,user_id)
			return candidate
		end

		def stats(user_id)
			res=Bot::Db.query('get_stats_by_user_id',[user_id])
			return nil if res.num_tuples.zero?
			return {
				'total'=>res[0]['total'],
				'verified'=>res[0]['verified'],
				'viewed'=>res[0]['viewed']
			}
		end
	end
end
