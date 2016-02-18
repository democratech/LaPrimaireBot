require File.expand_path('../config/environment', __FILE__)

use Rack::Reloader
use Rack::Cors do
	allow do
		origins '*'
		resource '*', headers: :any, methods: :get
	end
end

Mongo::Logger.logger.level = Logger::WARN
Democratech::LaPrimaireBot.mg_client=Mailgun::Client.new(MGUNKEY)
Democratech::LaPrimaireBot.mandrill=Mandrill::API.new(MANDRILLKEY)
Democratech::LaPrimaireBot.db=Mongo::Client.new(DBURL)
Democratech::LaPrimaireBot.tg_client=Telegram::Bot::Client.new(TOKEN)
Stripe.api_key=STRTEST

run Democratech::LaPrimaireBot
