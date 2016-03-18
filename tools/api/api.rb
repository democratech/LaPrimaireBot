require_relative '../../config/keys.local.rb'
require 'csv'
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

ctx,cmd=ARGV[0].split(':') if ARGV[0]
value=ARGV[1]
if ctx.nil? or cmd.nil? then
	puts <<END
* reallow:search
* reallow:user_id <id>
* reset:user_id <id>
* grantaccess:search <lastname>
* grantaccess:nb <nb>
* grantaccess:user_id <id>
* blockaddcandidate:search
* blockaddcandidate:user_id <id>
* blockcandidatereview:user_id <id>
* banuser:user_id <id>
* unblock:user_id <id>
* betacodes:gen <nb>
* betacodes:search
END
	exit
end

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

def generate_code(size = 6)
	charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
	(0...size).map{ charset.to_a[rand(charset.size)] }.join
end

data2=<<END
{
	"update_id": -1,
	"message": {
		"message_id": 0,
		"from": {
			"id": "%{user_id}",
			"first_name": "%{firstname}",
			"last_name": "%{lastname}",
			"username": "%{username}"
		},
		"chat": {
			"id": "%{user_id}",
			"first_name": "%{firstname}",
			"last_name": "%{lastname}",
			"username": "%{username}",
			"type": "private"
		},
		"date": %{date},
		"text": "%{cmd}"
	}
}
END

db=PG.connect(
	:dbname=>PGNAME,
	"user"=>PGUSER,
	"password"=>PGPWD,
	"host"=>PGHOST,
	"port"=>PGPORT
)

case ctx
when 'reallow'
	case cmd
	when 'search'
		search_not_allowed_users=<<END
SELECT user_id,firstname,lastname,registered,settings::json#>'{blocked,not_allowed}' AS not_allowed
FROM citizens 
WHERE settings::json#>>'{blocked,not_allowed}'='true'
ORDER BY registered ASC
END
		res=db.exec_params(search_not_allowed_users,[])
		if not res.num_tuples.zero? then
			res.each do |r|
				puts "(#{r['registered']}) #{r['firstname']} #{r['lastname']} : #{r['user_id']}"
			end
		end
	when 'user_id'
		get_user_from_waiting_list=<<END
SELECT user_id,firstname,lastname,username
FROM citizens
WHERE user_id=$1
ORDER BY registered ASC
END
		res=db.exec_params(get_user_from_waiting_list, [value])
		if not res.num_tuples.zero? then
			send_command(JSON.parse(data2 % {
				cmd:"api/allow_user",
				user_id:res[0]['user_id'],
				firstname:res[0]['firstname'],
				lastname:res[0]['lastname'],
				username:res[0]['username'],
				date:Time.now().to_i
			}))
		end
	end
when 'grantaccess'
	case cmd
	when 'search'
		search_waiting_list="SELECT user_id,firstname,lastname,registered FROM waiting_list WHERE lastname ILIKE $1 ORDER BY registered ASC"
		res=db.exec_params(search_waiting_list,[value])
		if not res.num_tuples.zero? then
			res.each do |r|
				puts "(#{r['registered']}) #{r['firstname']} #{r['lastname']} : #{r['user_id']}"
			end
		end
	when 'nb'
		read_waiting_list="SELECT user_id FROM waiting_list ORDER BY registered ASC LIMIT $1"
		res=db.exec_params('read_waiting_list',[value])
		if not res.num_tuples.zero? then
			res.each do |r|
				send_command(JSON.parse(data2 % {
					cmd:"api/access_granted",
					user_id:r['user_id'],
					firstname:r['firstname'],
					lastname:r['lastname'],
					username:r['username'],
					date:Time.now().to_i
				}))
				sleep(1)
			end
		end
	when 'user_id'
		get_user_from_waiting_list="SELECT user_id FROM waiting_list WHERE user_id=$1 ORDER BY registered ASC"
		res=db.exec_params(get_user_from_waiting_list, [value])
		if not res.num_tuples.zero? then
			send_command(JSON.parse(data2 % {
				cmd:"api/access_granted",
				user_id:res[0]['user_id'],
				firstname:res[0]['firstname'],
				lastname:res[0]['lastname'],
				username:res[0]['username'],
				date:Time.now().to_i
			}))
		end
	end
when 'blockaddcandidate'
	case cmd
	when 'search'
		search_biggest_candidates_proposers="SELECT user_id,firstname,lastname,registered,settings::json#>>'{actions,nb_candidates_proposed}' AS nb_proposed FROM citizens ORDER BY nb_proposed DESC LIMIT 50"
		res=db.exec(search_biggest_candidates_proposers)
		if not res.num_tuples.zero? then
			res.each do |r|
				puts "[#{r['registered']}] #{r['firstname']} #{r['lastname']} (#{r['user_id']}) : #{r['nb_proposed']}"
			end
		end
	when 'user_id'
		get_user_from_waiting_list="SELECT user_id FROM citizens WHERE user_id=$1"
		res=db.exec_params(get_user_from_waiting_list, [value])
		if not res.num_tuples.zero? then
			send_command(JSON.parse(data2 % {
				cmd:"api/block_candidate_proposals",
				user_id:res[0]['user_id'],
				firstname:res[0]['firstname'],
				lastname:res[0]['lastname'],
				username:res[0]['username'],
				date:Time.now().to_i
			}))
		end
	end
when 'banuser'
	case cmd
	when 'user_id'
		get_user="SELECT user_id FROM citizens WHERE user_id=$1"
		res=db.exec_params(get_user, [value])
		if not res.num_tuples.zero? then
			send_command(JSON.parse(data2 % {
				cmd:"api/ban_user",
				user_id:res[0]['user_id'],
				firstname:res[0]['firstname'],
				lastname:res[0]['lastname'],
				username:res[0]['username'],
				date:Time.now().to_i
			}))
		end
	end
when 'unblock'
	case cmd
	when 'user_id'
		get_user="SELECT user_id FROM citizens WHERE user_id=$1"
		res=db.exec_params(get_user, [value])
		if not res.num_tuples.zero? then
			send_command(JSON.parse(data2 % {
				cmd:"api/unblock_user",
				user_id:res[0]['user_id'],
				firstname:res[0]['firstname'],
				lastname:res[0]['lastname'],
				username:res[0]['username'],
				date:Time.now().to_i
			}))
		end
	end
when 'blockcandidatereview'
	case cmd
	when 'user_id'
		get_user="SELECT user_id FROM citizens WHERE user_id=$1"
		res=db.exec_params(get_user, [value])
		if not res.num_tuples.zero? then
			send_command(JSON.parse(data2 % {
				cmd:"api/block_candidate_reviews",
				user_id:res[0]['user_id'],
				firstname:res[0]['firstname'],
				lastname:res[0]['lastname'],
				username:res[0]['username'],
				date:Time.now().to_i
			}))
		end
	end
when 'betacodes'
	case cmd
	when 'search'
		get_codes="SELECT * FROM beta_codes"
		res=db.exec(get_codes)
		if not res.num_tuples.zero? then
			res.each do |r|
				puts "#{r['code']}"
			end
		end
	when 'gen'
		codes=[]
		query=[]
		idx=1
		value.to_i.times do
			codes.push(generate_code())
			query.push("($#{idx})")
			idx+=1
		end
		query_str=query.join(',')+" RETURNING *"
		insert_codes="INSERT INTO beta_codes (code) VALUES "+query_str
		res=db.exec_params(insert_codes, codes)
		if not res.num_tuples.zero? then
			res.each do |r|
				puts "#{r['code']}"
			end
		end
	end
when 'reset'
	case cmd
	when 'user_id'
		get_user="SELECT user_id FROM citizens WHERE user_id=$1"
		res=db.exec_params(get_user, [value])
		if not res.num_tuples.zero? then
			send_command(JSON.parse(data2 % {
				cmd:"api/reset_user",
				user_id:res[0]['user_id'],
				firstname:res[0]['firstname'],
				lastname:res[0]['lastname'],
				username:res[0]['username'],
				date:Time.now().to_i
			}))
		end
	end
when 'shit'
	case cmd
	when 'shit'
		insert_user="UPDATE candidates SET photo=$1 WHERE candidate_id=$2;"
		f=CSV.read('candidats_index.csv')
		photos={}
		f.each do |r|
			db.exec_params(insert_user,[r[3],r[0]]) if r[3]
		end
	end
end