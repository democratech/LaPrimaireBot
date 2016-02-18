# encoding: utf-8
require_relative 'users.rb'
require_relative 'search.rb'

module Bot
	class Navigation
		def initialize
			@users = Bot::Users.new()
			@search = Bot::Search.new()
			@answers = {}
			@keyboards = {}
			@screens=Bot.screens
			@screens.each do |k,v|
				v.each do |k1,v1|
					if (!v1[:kbd].nil?) then
						@keyboards[self.path([k,k1])]=[]
					end
					if (!v1[:answer].nil?) then
						#@answers[self.path([k,v1[:answer]])]=self.path([k,k1])
						@answers[v1[:answer]]={} if @answers[v1[:answer]].nil?
						@answers[v1[:answer]][k]=k1
					end
				end
			end
			@keyboards.each do |k,v|
				t=nil
				n1,n2=self.nodes(k)
				size=@screens[n1][n2][:kbd].length
				t=[] if size>2
				@screens[n1][n2][:kbd].each_with_index do |u,i|
					m1,m2=self.nodes(u)
					item=@screens[m1][m2][:answer]
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

		def path(nodes)
			nodes.join('/')
		end

		def nodes(path)
			path.split('/',2).map &:to_sym
		end

		def context(path)
			path.split('/',2)[0]
		end

		def get(msg)
			res,ans=nil
			user=@users.get(msg.from)
			input=user[:expected_input]
			if input==:answer then
				screen=self.find_by_answer(msg.text,self.context(user[:current]))
				screen=self.find_by_name("home/wtf") if screen.nil?
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
				STDERR.puts "something is not right in your code dude..."
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
			n1,n2=self.nodes(name)
			screen=@screens[n1][n2]
			screen[:id]=name
			return screen
		end

		def find_by_answer(answer,ctx)
			screen_id=@answers[answer][ctx.to_sym]
			screen=@screens[ctx.to_sym][screen_id] 
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
	end
end

