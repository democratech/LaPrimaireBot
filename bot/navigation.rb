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

TYPINGSPEED=80

module Bot
	class Navigation
		# loads all screens
		def self.load_addons
			Dir[File.expand_path('../../bot/addons/*.rb', __FILE__)].sort.each do |f|
				require f
			end
		end

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
						@answers[v1[:answer]]={} if @answers[v1[:answer]].nil?
						@answers[v1[:answer]][k]=k1
					end
				end
			end
			@keyboards.each do |k,v|
				t=nil
				n1,n2=self.nodes(k).map &:to_sym
				size=@screens[n1][n2][:kbd].length
				t=[] if size>2
				@screens[n1][n2][:kbd].each_with_index do |u,i|
					m1,m2=self.nodes(u).map &:to_sym
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
				@keyboards[k].push(t) if not (t.nil? or t.empty?)
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

		def to_callback(path)
			path.split('/',2).join('_')
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
				callback=self.to_callback(user[:callback].to_s)
				if self.respond_to?(callback) then
					if user[:expected_input_size]>0 then
						input_size=user[:expected_input_size]-1
						buffer=user[:buffer]+msg.text
						screen=self.find_by_name(user[:callback])
						user_update={:expected_input_size=>input_size,:buffer=>buffer}
						user_update[:callback]=nil if input_size==0
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
			callback=self.to_callback(screen[:callback].to_s) unless screen[:callback].nil?
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

		def find_by_answer(answer,ctx=nil)
			tmp=@answers[answer]
			return nil if tmp.nil?
			if tmp.length==1
				ctx,screen_id=tmp.flatten
			else
				screen_id=tmp[ctx.to_sym]
			end
			STDERR.puts "Something looks wrong here" if screen_id.nil?
			screen=@screens[ctx.to_sym][screen_id] 
			screen[:id]=self.path([ctx,screen_id]) unless screen.nil?
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

		def home_welcome(msg,user,screen)
			@users.update(user[:id],{:new=>false})
			return self.get_screen(screen,user,msg)
		end
	end
end
