require_relative '../../config/keys.local.rb'
require 'uri'
require 'net/http'
require 'json'
require 'pg'
require 'openssl'

DEBUG=true
PGPWD=DEBUG ? PGPWD_TEST : PGPWD_LIVE
PGNAME=DEBUG ? PGNAME_TEST : PGNAME_LIVE
PGUSER=DEBUG ? PGUSER_TEST : PGUSER_LIVE
PGHOST=DEBUG ? PGHOST_TEST : PGHOST_LIVE
WEBHOOK=DEBUG ? WEBHOOK_TEST : WEBHOOK_LIVE

def send_command(data)
	uri = URI.parse(WEBHOOK)
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	request = Net::HTTP::Post.new("/command")
	request.add_field("Secret-Key",SECRET)
	request.add_field('Content-Type', 'application/json')
	request.body = JSON.dump(data)
	http.request(request)
end

nb=ARGV[0]
read_waiting_list="SELECT user_id FROM waiting_list ORDER BY registered ASC LIMIT $1"
db=PG.connect(:dbname=>PGNAME,"user"=>PGUSER,"password"=>PGPWD,"host"=>PGHOST, "port"=>PGPORT)
db.prepare('read_waiting_list',read_waiting_list)
res=db.exec_prepared('read_waiting_list',[nb.to_s])
if not res.num_tuples.zero? then
	res.each do |r|
		data={
			"update_id"=> -1,
			"message"=> {
				"message_id"=> 0,
				"from"=> {
					"id"=> r['user_id'],
					"first_name"=> r['firstname'],
					"last_name"=> r['lastname'],
					"username"=> r['username']
				},
				"chat"=> {
					"id"=> r['user_id'],
					"first_name"=> r['firstname'],
					"last_name"=> r['lastname'],
					"username"=> r['username'],
					"type"=> "private"
				},
				"date"=> Time.now().to_i,
				"text"=> "api/access_granted"
			}
		}
		send_command(data)
		sleep(3)
	end
end




