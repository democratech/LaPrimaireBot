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
