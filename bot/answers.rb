# encoding: utf-8

require 'fastimage'

SCREENS={
	:welcome=>{
		:answer=>"/start",
		:text=>WELCOME,
		:callback=>:home,
		:context=>:home,
		:jump_to=>:home
	},
	:home=>{
		:answer=>"#{EMOTICONS[:home]} Accueil",
		:text=>HOME,
		:callback=>:home,
		:context=>:home,
		:kbd=>[:me_candidat,:you_candidat,:new_citizens,:memo],
		:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
	},
	:me_candidat=>{
		:answer=>"#{EMOTICONS[:finger_up]} Etre candidat",
		:text=>NOT_IMPLEMENTED,
		:callback=>:sorry,
		:context=>:me_candidat,
		:jump_to=>:home
	},
	:you_candidat=>{
		:answer=>"#{EMOTICONS[:finger_right]} Proposer un candidat",
		:text=>YOU_CANDIDAT,
		:callback=>:you_candidat,
		:context=>:you_candidat
	},
	:you_candidat_confirm=>{
		:answer=>"#{EMOTICONS[:search]} Rechercher le candidat",
		:text=>YOU_CANDIDAT_CONFIRM,
		:callback=>nil,
		:context=>:you_candidat,
		:kbd=>[:you_candidat_yes,:you_candidat_no],
		:kbd_options=>{:resize_keyboard=>true,:one_time_keyboard=>false,:selective=>true}
	},
	:you_candidat_yes=>{
		:answer=>"#{EMOTICONS[:thumbs_up]} Oui, je confirme mon choix",
		:text=>YOU_CANDIDAT_YES,
		:callback=>:you_candidat_yes,
		:context=>:you_candidat,
		:jump_to=>:home
	},
	:you_candidat_no=>{
		:answer=>"#{EMOTICONS[:thumbs_down]} Non, ce n'est pas la bonne personne",
		:text=>YOU_CANDIDAT_NO,
		:callback=>:you_candidat_no,
		:context=>:you_candidat,
		:jump_to=>:you_candidat
	},
	:you_candidat_not_found=>{
		:text=>YOU_CANDIDAT_NOT_FOUND,
		:callback=>:you_candidat_not_found,
		:context=>:you_candidat,
		:jump_to=>:you_candidat
	},
	:new_citizens=>{
		:answer=>"#{EMOTICONS[:megaphone]} Recruter d'autres citoyens",
		:text=>NOT_IMPLEMENTED,
		:callback=>:sorry,
		:jump_to=>:home
	},
	:memo=>{
		:answer=>"#{EMOTICONS[:memo]} Vous faire un retour",
		:text=>NOT_IMPLEMENTED,
		:callback=>:sorry,
		:jump_to=>:home
	},
	:wtf=>{
		:text=>PAS_COMPRIS,
		:callback=>:wtf,
		:jump_to=>:home
	}
}

class Users
	def initialize()
		@users={}
	end

	def add(user)
		u={
			:current=>:welcome,
			:expected_input=>:answer,
			:expected_input_size=>-1,
			:buffer=>"",
			:new=>true,
			:first_name=>user.first_name,
			:last_name=>user.last_name,
			:id=>user.id,
			:username=>user.username
		}
		@users[u[:id]]=u
	end

	def update(user_id,data)
		data.each do |k,v|
			@users[user_id][k]=v
		end
	end

	def get(user_info)
		user=@users[user_info.id]
		user=self.add(user_info) if user.nil?
		return user
	end
end

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


class Navigation
	def initialize
		@users = Users.new()
		@search = Search.new()
		@answers = {}
		@keyboards = {}
		SCREENS.each do |k,v|
			if (!v[:kbd].nil?) then
				@keyboards[k]=[]
			end
			if (!v[:answer].nil?) then
				@answers[v[:answer]]=k
			end
		end
		@keyboards.each do |k,v|
			t=nil
			size=SCREENS[k][:kbd].length
			t=[] if size>2
			SCREENS[k][:kbd].each_with_index do |u,i|
				item=SCREENS[u][:answer]
				if t.nil? then
					@keyboards[k].push(item)
				else
					idx=i%2
					t[idx]=item
					if idx==1 then
						@keyboards[k].push(t)
						t=[]
					end
				end

			end
		end
	end

	def get(msg)
		res,ans=nil
		user=@users.get(msg.from)
		input=user[:expected_input]
		if input==:answer then
			screen=self.find_by_answer(msg.text)
			screen=self.find_by_name(:wtf) if screen.nil?
			res,ans=get_screen(screen,user,msg)
			jump_to=screen[:jump_to]
			while !jump_to.nil? do
				next_screen=find_by_name(jump_to)
				a,b=get_screen(next_screen,user,msg)
				res+=a unless a.nil?
				ans=b unless b.nil?
				jump_to=next_screen[:jump_to]
			end
		elsif input==:free_text then
			callback="cb_"+user[:cb].to_s
			if self.respond_to?(callback) then
				if user[:expected_input_size]>0 then
					input_size=user[:expected_input_size]-1
					buffer=user[:buffer]+msg.text
					screen=self.find_by_name(user[:cb])
					user_update={:expected_input_size=>input_size,:buffer=>buffer}
					user_update[:cb]=nil if input_size==0
					@users.update(user[:id],user_update)
					res,ans=self.method(callback).call(msg,user,screen) if input_size==0
					screen=self.find_by_name(user[:current])
					jump_to=screen[:jump_to]
					while !jump_to.nil? do
						next_screen=find_by_name(jump_to)
						a,b=get_screen(next_screen,user,msg)
						res+=a unless a.nil?
						ans=b unless b.nil?
						jump_to=next_screen[:jump_to]
					end

				end
			end
		else
			puts "something is not right in your code dude..."
		end
		return res,ans
	end

	def get_screen(screen,user,msg)
		res,ans=nil
		return nil,nil if screen.nil?
		callback="cb_"+screen[:callback].to_s unless screen[:callback].nil?
		previous=caller_locations(1,1)[0].label
		@users.update(user[:id],{:current=>screen[:id]})
		if !callback.nil? && previous!=callback && self.respond_to?(callback)
			res,ans=self.method(callback).call(msg,user,screen)
		else
			res,ans=self.format_answer(screen,user)
		end
		return res,ans
	end

	def find_by_name(name)
		screen=SCREENS[name]
		screen[:id]=name
		return screen
	end

	def find_by_answer(answer)
		screen_id=@answers[answer]
		screen=SCREENS[screen_id] 
		screen[:id]=screen_id unless screen.nil?
		return screen
	end

	def format_answer(screen,user)
		res=screen[:text] % [first_name: user[:first_name],last_name: user[:last_name],id: user[:id],username: user[:username],media:screen[:media]] unless screen.nil?
		ans=@keyboards[screen[:id]].nil? ? nil : Telegram::Bot::Types::ReplyKeyboardMarkup.new(
			keyboard:@keyboards[screen[:id]],
			resize_keyboard:screen[:kbd_options][:resize_keyboard],
			one_time_keyboard:screen[:kbd_options][:one_time_keyboard],
			selective:screen[:kbd_options][:selective]
		)
		return res,ans
	end

	def cb_welcome(msg,user,screen)
		puts "cb:welcome"
		@users.update(user[:id],{:new=>false})
		return self.get_screen(screen,user,msg)
	end

	def cb_you_candidat(msg,user,screen)
		puts "cb:you_candidat"
		@users.update(
			user[:id],
			{
				:expected_input=>:free_text,
				:expected_input_size=>1,
				:cb=>:you_candidat_confirm
			}
		)
		return self.get_screen(screen,user,msg)
	end

	def cb_you_candidat_confirm(msg,user,screen)
		puts "cb:you_candidat_confirm"
		candidat=user[:buffer]
		user_update={
			:buffer=>"",
			:expected_input=>:answer,
			:expected_input_length=>-1,
		}
		@users.update(user[:id],user_update)
		img,type = @search.image(candidat)
		return self.get_screen(self.find_by_name(:you_candidat_not_found),user,msg) if img.nil?
		output_img='image'+user[:id].to_s+"."+type
		open(output_img,'wb') { |file| file << open(img.link).read }
		screen=self.find_by_name(:you_candidat_confirm)
		screen[:media]="image:"+output_img
		return self.get_screen(self.find_by_name(:you_candidat_confirm),user,msg)
	end

end
