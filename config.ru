require File.expand_path('../config/environment', __FILE__)

use Rack::Cors do
	allow do
		origins '*'
		resource '*', headers: :any, methods: :get
	end
end

Algolia.init :application_id=>ALGOLIA_ID, :api_key=>ALGOLIA_KEY
Democratech::TelegramBot.client=Telegram::Bot::Client.new(DEBUG ? TG_TEST_TOKEN : TG_LIVE_TOKEN)
Bot.log=Bot::Log.new()
Bot::Navigation.load_addons()
Bot.nav=Bot::Navigation.new()

run Democratech::TelegramBot
