require File.expand_path('../config/environment', __FILE__)

use Rack::Cors do
	allow do
		origins '*'
		resource '*', headers: :any, methods: :get
	end
end

DEBUG=(ENV['RACK_ENV']!='production')
PRODUCTION=(ENV['RACK_ENV']=='production')
require 'pp' if DEBUG
TYPINGSPEED= DEBUG ? 200 : 70
TYPINGSPEED_SLOW= DEBUG ? 200 : 60
MAX_CANDIDATES_PROPOSAL=10
MAX_CANDIDATES_SUPPORT=5
RESET_WORDS=['/start','start','/accueil','accueil','/reset','reset','/retour','retour','/sortir','sortir','/menu','menu']
IGNORE_CONTEXT=["api","help"]
PGPWD=DEBUG ? PGPWD_TEST : PGPWD_LIVE
PGNAME=DEBUG ? PGNAME_TEST : PGNAME_LIVE
PGUSER=DEBUG ? PGUSER_TEST : PGUSER_LIVE
PGHOST=DEBUG ? PGHOST_TEST : PGHOST_LIVE
puts "connect to database : #{PGNAME} with user : #{PGUSER}"
Democratech::LaPrimaireBot.mandrill=Mandrill::API.new(MANDRILLKEY)
Democratech::LaPrimaireBot.tg_client=Telegram::Bot::Client.new(DEBUG ? TG_TEST_TOKEN : TG_LIVE_TOKEN)
Democratech::LaPrimaireBot.tg_client.enable_botan!(BOTAN_TOKEN) if PRODUCTION
Democratech::LaPrimaireBot.mixpanel =Mixpanel::Tracker.new("3cb923f3507e91e8a2d4a4417f70944e") if PRODUCTION
Bot::Navigation.load_addons()
Democratech::LaPrimaireBot.nav=Bot::Navigation.new()
Algolia.init :application_id=>ALGOLIA_ID, :api_key=>ALGOLIA_KEY
Bot::Geo.countries=Algolia::Index.new("countries")
index_candidats=DEBUG ? "candidates_test" : "candidates"
puts "using index #{index_candidats}" 
Bot::Candidates.index=Algolia::Index.new(index_candidats)

run Democratech::LaPrimaireBot
