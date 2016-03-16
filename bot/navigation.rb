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
	class Navigation
		# loads all screens
		def self.load_addons
			Dir[File.expand_path('../../bot/addons/*.rb', __FILE__)].sort.each do |f|
				require f
			end
		end

		def initialize
			@users = Bot::Users.new()
			@web = Bot::Web.new()
			@geo = Bot::Geo.new()
			@candidates = Bot::Candidates.new()
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
						raise "Conflict of answers detected in add-on \"#{k}\" : \"#{v1[:answer]}\"" if not @answers[v1[:answer]][k].nil?
						@answers[v1[:answer]][k]=k1
					end
				end
			end
			@keyboards.each do |k,v|
				t=nil
				n1,n2=self.nodes(k).map &:to_sym
				size=@screens[n1][n2][:kbd].length
				@screens[n1][n2][:kbd].each_with_index do |u,i|
					m1,m2=self.nodes(u).map &:to_sym
					item=@screens[m1][m2][:answer]
					@keyboards[k].push(item)
				end
			@answers.freeze
			@screens.freeze
			@keyboards.freeze
			end
		end

		def path(nodes)
			nodes.join('/') unless nodes.nil?
		end

		def nodes(path)
			path.split('/',2).map &:to_sym unless path.nil?
		end

		def context(path)
			path.split('/',2)[0] unless path.nil?
		end

		def to_callback(path)
			path.split('/',2).join('_') unless path.nil?
		end

		def get(msg,update_id)
			res,options=nil
			user=@users.get(msg.from,msg.date)
			# we check that this message has not already been answered (i.e. telegram sending a msg we already processed)
			return nil,nil if @users.already_answered(user[:id],update_id)
			session=user['session']
			@users.next_answer(user[:id],'free_text',1,msg.text) if update_id==-1
			puts "user read session : #{user}" if DEBUG
			input=session['expected_input']
			session['current']="home/welcome" if msg.text=='/start'
			if (input=='answer' or msg.text=="/start") then # we expect the user to have used the proposed keyboard to answer
				screen=self.find_by_answer(msg.text,self.context(session['current']))
				if not screen.nil? then
					res,options=get_screen(screen,user,msg)
					user['session']=@users.get_session(user[:id])
					current=user['session']['current']
					screen=self.find_by_name(current) if screen[:id]!=current
					jump_to=screen[:jump_to]
					while !jump_to.nil? do
						next_screen=find_by_name(jump_to)
						a,b=get_screen(next_screen,user,msg)
						user['session']=@users.get_session(user[:id])
						res="" unless res
						res+=a unless a.nil?
						options.merge!(b) unless b.nil?
						jump_to=next_screen[:jump_to]
					end
				else
					res,options=self.dont_understand(user,msg)
				end
			else # we expect the user to have answered by typing text manually
				callback=self.to_callback(session['callback'].to_s)
			        if input=='free_text' and self.respond_to?(callback) then
					if session['expected_input_size']>0 then
						input_size=session['expected_input_size']-1
						session=@users.update_session(user[:id],{'buffer'=>session['buffer']+msg.text})
						screen=self.find_by_name(session['callback'])
						session_update={'expected_input_size'=>input_size}
						session_update['callback']=nil if input_size==0
						session=@users.update_session(user[:id],session_update)
						user['session']=session
						res,options=self.method(callback).call(msg,user,screen) if input_size==0
						screen=self.find_by_name(session['current'])
						jump_to=screen[:jump_to]
						while !jump_to.nil? do
							next_screen=find_by_name(jump_to)
							user['session']=@users.get_session(user[:id])
							a,b=get_screen(next_screen,user,msg)
							res+=a unless a.nil?
							options.merge!(b) unless b.nil?
							jump_to=next_screen[:jump_to]
						end

					end
				end
			end
			res,options=self.dont_understand(user,msg,true) if res.nil? # something is fishy
			puts "user save session : #{@users.get_session(user[:id])}" if DEBUG
			@users.save_user_session(user[:id])
			return res,options
		end

		def dont_understand(user,msg,reset=false)
			# dedicated method to not affect user session
			puts "dont_understand: #{msg}" if DEBUG
			Democratech::LaPrimaireBot.tg_client.track('dont_understand',user[:id],msg.text) if PRODUCTION
			screen=self.find_by_name("system/dont_understand")
			res,options=self.format_answer(screen,user)
			if reset then
				screen=self.find_by_name("system/something_wrong")
				a,b=get_screen(screen,user,msg)
				res+=a unless a.nil?
				options=b unless b.nil?
				@users.next_answer(user[:id],'answer')
				screen=self.find_by_answer("/start")
				a,b=get_screen(screen,user,msg)
				res+=a unless a.nil?
				options=b unless b.nil?
				jump_to=screen[:jump_to]
				while !jump_to.nil? do
					next_screen=find_by_name(jump_to)
					a,b=get_screen(next_screen,user,msg)
					res+=a unless a.nil?
					options=b unless b.nil?
					jump_to=next_screen[:jump_to]
				end
			end
			return res,options
		end

		def get_screen(screen,user,msg)
			puts "get_screen: #{screen}" if DEBUG
			Democratech::LaPrimaireBot.tg_client.track(screen[:id],user[:id],screen) if PRODUCTION
			res,options=nil
			return nil,nil if screen.nil?
			callback=self.to_callback(screen[:callback].to_s) unless screen[:callback].nil?
			previous=caller_locations(1,1)[0].label
			@users.update_session(user[:id],{'current'=>screen[:id]})
			if !callback.nil? && previous!=callback && self.respond_to?(callback)
				res,options=self.method(callback).call(msg,user,screen.clone)
			else
				res,options=self.format_answer(screen.clone,user)
			end
			return res,options
		end

		def find_by_name(name)
			puts "find_by_name: #{name}" if DEBUG
			n1,n2=self.nodes(name)
			screen=@screens[n1][n2]
			if screen then
				screen[:id]=name 
				screen=screen.clone
			end
			return screen
		end

		def find_by_answer(answer,ctx=nil)
			puts "find_by_answer: #{answer} context: #{ctx}" if DEBUG
			tmp=@answers[answer]
			return nil if tmp.nil?
			if tmp.length==1
				ctx,screen_id=tmp.flatten
			else
				screen_id=tmp[ctx.to_sym]
			end
			STDERR.puts "Something looks wrong here" if screen_id.nil?
			screen=@screens[ctx.to_sym][screen_id] 
			if screen then
				screen[:id]=self.path([ctx,screen_id])
				screen=screen.clone
			end
			return screen
		end

		def format_answer(screen,user)
			puts "format_answer: #{screen[:id]}" if DEBUG
			res=screen[:text] % {firstname: user['firstname'],lastname: user['lastname'],id: user[:id],username: user['username']} unless screen.nil? or screen[:text].nil?
			options={}
			kbd=@keyboards[screen[:id]].clone if @keyboards[screen[:id]]
			if screen[:kbd_del] then
				screen[:kbd_del].each do |k|
					n1,n2=self.nodes(k)
					kbd.delete(@screens[n1][n2][:answer])
				end
			end
			screen[:kbd_add].each { |k| kbd.push(k) } if screen[:kbd_add]
			if not kbd.nil? then
				if kbd.length>1 and not screen[:kbd_vertical] then # display keyboard on several rows
					newkbd=[]
					row=[]
					kbd.each_with_index do |r,i|
						row.push(r)
						if (i%2)==0 then
							newkbd.push(row)
							row=[]
						end
					end
					newkbd.push(row) if row
					kbd=newkbd
				end
				options[:kbd]=Telegram::Bot::Types::ReplyKeyboardMarkup.new(
					keyboard:kbd,
					resize_keyboard:screen[:kbd_options][:resize_keyboard],
					one_time_keyboard:screen[:kbd_options][:one_time_keyboard],
					selective:screen[:kbd_options][:selective]
				)

			end
			options[:disable_web_page_preview]=true if screen[:disable_web_page_preview]
			options[:groupsend]=true if screen[:groupsend]
			options[:parse_mode]=screen[:parse_mode] if screen[:parse_mode]
			options[:keep_kbd]=true if screen[:keep_kbd]
			return res,options
		end
	end
end
