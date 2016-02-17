require File.expand_path('../config/environment', __FILE__)

use Rack::Reloader
use Rack::Cors do
	allow do
		origins '*'
		resource '*', headers: :any, methods: :get
	end
end

Mongo::Logger.logger.level = Logger::WARN
Democratech::Bot.mg_client=Mailgun::Client.new(MGUNKEY)
Democratech::Bot.mandrill=Mandrill::API.new(MANDRILLKEY)
Democratech::Bot.db=Mongo::Client.new(DBURL)
Democratech::Bot.tg_client=Telegram::Bot::Client.new(TOKEN)
Stripe.api_key=STRTEST

run Democratech::Bot
