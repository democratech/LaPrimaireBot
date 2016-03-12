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
	class Web
		def initialize
			@cs=Google::Apis::CustomsearchV1::CustomsearchService.new
			@cs.key=CSKEY
		end

		def search_image(q)
			res=@cs.list_cses(q,cx:CSID,cr:'countryFR', gl:'fr', hl:'fr', googlehost:'google.fr', img_type:'face', search_type:'image', num:5, safe:'high')
			images=[]
			if !res.items.nil? then
				res.items.each do |img|
					type=FastImage.type(img.link)
					if !type.nil? then
						images.push([img,type.to_s])
					end
				end
			end
			return images
		end
	end
end
