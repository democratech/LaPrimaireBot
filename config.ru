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
Democratech::LaPrimaireBot.tg_client=Telegram::Bot::Client.new(ENV['RACK_ENV']=='production' ? TG_LIVE_TOKEN : TG_TEST_TOKEN)
Democratech::LaPrimaireBot.tg_client.enable_botan!(BOTAN_TOKEN) if ENV['RACK_ENV']=='production'
Bot::Navigation.load_addons()
Democratech::LaPrimaireBot.nav=Bot::Navigation.new()
Stripe.api_key=ENV['RACK_ENV']=='production' ? STRLIVE : STRTEST

run Democratech::LaPrimaireBot
