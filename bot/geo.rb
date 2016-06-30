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
	class Geo
		def self.load_queries
			queries={
			'get_city_by_zipcode'=><<END,
SELECT c.* FROM cities AS c WHERE c.zipcode=$1
END
			}
			queries.each { |k,v| Bot::Db.prepare(k,v) }
		end

		def initialize
			@countries=Algolia::Index.new("countries")
		end

		def search_city(query)
			Bot.log.info "#{__method__}"
			return Bot::Db.query("get_city_by_zipcode",[query[:target]]) 
		end

		def search_country(country,options)
			Bot.log.info "#{__method__}"
			return @countries.search(country,options)
		end
	end
end
