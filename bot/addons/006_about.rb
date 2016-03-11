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

module About
	def self.included(base)
		puts "loading Home add-on" if DEBUG
		messages={
			:fr=>{
				:about=>{
					:intro=><<-END,
A propos de LaPrimaire.org
END
					:menu=><<-END,
Que voulez-vous faire ?
END
				}
			}
		}
		screens={
			:about=>{
				:intro=>{
					:text=>messages[:fr][:about][:intro],
					:callback=>"about/intro",
					:jump_to=>"about/menu"
				},
				:menu=>{
					:text=>messages[:fr][:about][:menu],
					:jump_to=>"about/intro"
				},
				:laprimaire=>{
					:answer=>"#{Bot.emoticons[:info]} A propos de LaPrimaire.org",
					:text=>messages[:fr][:about][:menu],
					:jump_to=>"about/intro"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
		Bot.addMenu({:home=>{:menu=>{:kbd=>"about/laprimaire"}}})
	end

	def about_intro(msg,user,screen)
		puts "about_intro" if DEBUG
		return self.get_screen(screen,user,msg)
	end
end

include About
