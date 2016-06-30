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
	class Db
		@@db=nil
		@@queries={}

		def self.init
			pgpwd=DEBUG ? PGPWD_TEST : PGPWD_LIVE
			pgname=DEBUG ? PGNAME_TEST : PGNAME_LIVE
			pguser=DEBUG ? PGUSER_TEST : PGUSER_LIVE
			pghost=DEBUG ? PGHOST_TEST : PGHOST_LIVE
			Bot.log.debug "connect to database : #{pgname} with user : #{pguser}"
			@@db=PG.connect(
				"dbname"=>pgname,
				"user"=>pguser,
				"password"=>pgpwd,
				"host"=>pghost, 
				"port"=>PGPORT
			)
		end

		def self.load_queries
			Bot::Users.load_queries
			Bot::Geo.load_queries
			Bot::Candidates.load_queries
		end

		def self.begin
			@@db.exec("BEGIN;")
		end

		def self.commit
			@@db.exec("COMMIT;")
		end

		def self.rollback
			@@db.exec("ROLLBACK;")
		end

		def self.prepare(name,query)
			@@queries[name]=query
		end

		def self.close
			@@db.close()
		end

		def self.query(name,params)
			Bot.log.info "db query: #{name} / values: #{params}"
			@@db.exec_params(@@queries[name],params)
		end
	end
end
