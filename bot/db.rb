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
		@@queries_to_prepare=nil

		def self.init
			Db.close
			@@db=PG.connect(:dbname=>PGNAME,"user"=>PGUSER,"sslmode"=>"require","password"=>PGPWD,"host"=>PGHOST)
			if @@queries_to_prepare then
				@@queries_to_prepare.each do |k,v|
					self.prepare(k,v)
				end
				@@queries_to_prepare=nil;
			end
		end

		def self.prepare(name,query)
			if @@db then
				@@db.prepare(name,query)
			else
				if @@queries_to_prepare.nil? then
					@@queries_to_prepare={name=>query}
				else
					@@queries_to_prepare[name]=query
				end
			end
		end

		def self.close
			if @@db then
				@@db.flush
				@@db.close
			end
		end

		def self.query(name,params)
			self.db_init if @@db.status!=PG::CONNECTION_OK
			@@db.exec_prepared(name,params)
		end
	end
end
