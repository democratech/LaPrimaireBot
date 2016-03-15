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
	class Geo
		class << self
			attr_accessor :countries
		end

		def self.load_queries
			queries={
			'get_city_by_zipcode'=><<END,
SELECT c.* FROM cities AS c WHERE c.zipcode=$1
END
			}
			queries.each { |k,v| Bot::Db.prepare(k,v) }
		end

		def search(query)
			return Bot::Db.query("get_"+query[:type]+"_by_"+query[:by],[query[:target]]) 
		end

	end
end

