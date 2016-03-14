require File.expand_path('../config/environment', __FILE__)

use Rack::Reloader
use Rack::Cors do
	allow do
		origins '*'
		resource '*', headers: :any, methods: :get
	end
end

DEBUG=(ENV['RACK_ENV']!='production')
PRODUCTION=(ENV['RACK_ENV']=='production')
PGPWD=DEBUG ? PGPWD_TEST : PGPWD_LIVE
PGNAME=DEBUG ? PGNAME_TEST : PGNAME_LIVE
PGUSER=DEBUG ? PGUSER_TEST : PGUSER_LIVE
PGHOST=DEBUG ? PGHOST_TEST : PGHOST_LIVE
puts "connect to database : #{PGNAME} with user : #{PGUSER}"
Mongo::Logger.logger.level = Logger::WARN
Democratech::LaPrimaireBot.mg_client=Mailgun::Client.new(MGUNKEY)
Democratech::LaPrimaireBot.mandrill=Mandrill::API.new(MANDRILLKEY)
Democratech::LaPrimaireBot.db=Mongo::Client.new(DBURL)
Democratech::LaPrimaireBot.tg_client=Telegram::Bot::Client.new(DEBUG ? TG_TEST_TOKEN : TG_LIVE_TOKEN)
Democratech::LaPrimaireBot.tg_client.enable_botan!(BOTAN_TOKEN) if PRODUCTION
Democratech::LaPrimaireBot.mixpanel =Mixpanel::Tracker.new("3cb923f3507e91e8a2d4a4417f70944e") # if PRODUCTION
Bot::Navigation.load_addons()
Democratech::LaPrimaireBot.nav=Bot::Navigation.new()
Stripe.api_key=DEBUG ? STRTEST : STRLIVE
Algolia.init :application_id=>ALGOLIA_ID, :api_key=>ALGOLIA_KEY
Bot::Geo.countries=Algolia::Index.new("countries")
Bot::Candidates.index=Algolia::Index.new("candidates")

run Democratech::LaPrimaireBot
