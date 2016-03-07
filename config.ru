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
Democratech::LaPrimaireBot.pg=PG.connect(:dbname=>PGNAME,"user"=>PGUSER,"sslmode"=>"require","password"=>PGPWD,"host"=>PGHOST)
Democratech::LaPrimaireBot.tg_client=Telegram::Bot::Client.new(TOKEN)
Bot::Navigation.load_addons()
Democratech::LaPrimaireBot.nav=Bot::Navigation.new()
Stripe.api_key=STRTEST

run Democratech::LaPrimaireBot
