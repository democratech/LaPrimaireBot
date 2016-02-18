# encoding: utf-8

module Bot
	class Search
		def initialize
			@cs=Google::Apis::CustomsearchV1::CustomsearchService.new
			@cs.key=CSKEY
		end

		def image(q)
			res=@cs.list_cses(q,cx:CSID,cr:'countryFR', gl:'fr', hl:'fr', file_type:'.jpg', googlehost:'google.fr', img_type:'photo', search_type:'image', num:5)
			if !res.items.nil? then
				res.items.each do |img|
					type=FastImage.type(img.link)
					if !type.nil? then
						return img,type.to_s
					end
				end
			end
			return nil
		end
	end
end
