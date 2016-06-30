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
	class Web
		def initialize
			@cs=Google::Apis::CustomsearchV1::CustomsearchService.new
			@cs.key=CSKEY
			aws=Aws::S3::Resource.new(
				credentials: Aws::Credentials.new(AWS_BOT_KEY,AWS_BOT_SECRET),
				region: AWS_REGION
			)
			@bucket=aws.bucket(AWS_BUCKET)
		end

		def search_image(q)
			Bot.log.info "#{__method__}"
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

		def upload_image(filename)
			Bot.log.info "#{__method__} : #{filename}"
			key=File.basename(filename)
			obj=@bucket.object(key)
			if @bucket.object(key).exists? then
				Bot.log.info("#{key} already exists in S3 bucket. deleting previous object.")
				obj.delete
			end
			Bot.log.info("upload #{key} (from #{filename}) to S3")
			content_type=MimeMagic.by_magic(File.open(filename)).type
			obj.upload_file(filename, acl:'public-read',cache_control:'public, max-age=14400', content_type:content_type)
			return key
		end

		def delete_image(filename)
			Bot.log.info "#{__method__} : #{filename}"
			File.delete(filename) if (!filename.nil? and File.exists?(filename))
			key=File.basename(filename)
			if @bucket.object(key).exists? then
				obj=@bucket.object(key)
				obj.delete
				Bot.log.info("delete #{key} from S3")
			else
				Bot.log.info("#{key} does not exist in S3 bucket")
			end
		end

		def image_url(key)
			return AWS_S3_BUCKET_URL+key
		end
	end
end
