require '../../config/keys.local.rb'
require 'mandrill'
require 'pg'
require 'csv'

DEBUG=false
PGPWD=DEBUG ? PGPWD_TEST : PGPWD_LIVE
PGNAME=DEBUG ? PGNAME_TEST : PGNAME_LIVE
PGUSER=DEBUG ? PGUSER_TEST : PGUSER_LIVE
PGHOST=DEBUG ? PGHOST_TEST : PGHOST_LIVE


def generate_code(size = 6)
	charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
	(0...size).map{ charset.to_a[rand(charset.size)] }.join
end

mandrill=Mandrill::API.new(MANDRILLKEY)
db=PG.connect(
	:dbname=>PGNAME,
	"user"=>PGUSER,
	"password"=>PGPWD,
	"host"=>PGHOST,
	"port"=>PGPORT
)

def email_candidat_trello(db,mandrill)
	message= {  
		:from_name=> "LaPrimaire.org",  
		:subject=> "Préparez-vous : Ouverture de LaPrimaire.org le 4 avril prochain !",  
		:to=>[  
			{  
				:email=> "thib@thib.fr",
				:name=> "Thibauld"
			}  
		],
		:merge_vars=>[
			{
				:rcpt=>"Jacques",
				:vars=>[
					{
						:name=>"UUID",
						:content=>"john"
					},
					{
						:name=>"BETACODE",
						:content=>"doe"
					},
				]
			}
		]
	}
	get_candidates="SELECT candidate_id,name,email FROM candidates WHERE email IS NOT NULL"
	res_candidats=db.exec(get_candidates)
	if not res_candidats.num_tuples.zero? then
		nb_codes=res_candidats.num_tuples
		codes=[]
		query=[]
		idx=1
		nb_codes.to_i.times do
			codes.push(generate_code())
			query.push("($#{idx})")
			idx+=1
		end
		query_str=query.join(',')+" RETURNING *"
		insert_codes="INSERT INTO beta_codes (code) VALUES "+query_str
		res_codes=db.exec_params(insert_codes,codes)
		return "error adding codes" if res_codes.num_tuples.zero? 
		emails={}
		res_candidats.each_with_index do |r,i|
			emails[r['email']]={"UUID"=>r['candidate_id'],"BETACODE"=>codes[i],"NAME"=>r['name']}
		end
	end
	emails.each do |k,v|
		begin
			msg=message
			msg[:to][0][:email]=k
			msg[:to][0][:name]=v["NAME"]
			msg[:merge_vars][0][:rcpt]=k
			msg[:merge_vars][0][:vars][0][:content]=v["UUID"]
			msg[:merge_vars][0][:vars][1][:content]=v["BETACODE"]
			result=mandrill.messages.send_template("laprimaire-org-candidates-part-i-trello",[],message)
			puts "sending email to #{v['NAME']} (#{k}) with UUID #{v['UUID']} and CODE #{v['BETACODE']}"
			sleep(1)
		rescue Mandrill::Error => e
			msg="A mandrill error occurred: #{e.class} - #{e.message}"
			puts msg
		end
	end
end

def email_candidat_formation(db,mandrill)
	get_candidates="SELECT candidate_id,name,email FROM candidates WHERE email IS NOT NULL AND verified"
	res_candidats=db.exec(get_candidates)
	if not res_candidats.num_tuples.zero? then
		emails=[]
		res_candidats.each do |r|
			message= {
				:from_name=> "LaPrimaire.org",  
				:subject=> "Candidats à LaPrimaire.org : réservez votre samedi 21 mai prochain !",  
				:to=>[  {  :email=> "#{r['email']}" }  ]
			}
			emails.push(message)
		end
	end
	emails.each do |k|
		begin
			result=mandrill.messages.send_template("laprimaire-org-candidates-part-ii-formation",[],k)
			puts "sending email to #{k[:to][0][:email]}"
			sleep(0.2)
		rescue Mandrill::Error => e
			msg="A mandrill error occurred: #{e.class} - #{e.message}"
			puts msg
		end
	end
end

def email_candidat_admin(db,mandrill)
	get_candidates="SELECT candidate_id,candidate_key,name,email FROM candidates WHERE email IS NOT NULL AND verified"
	res_candidats=db.exec(get_candidates)
	if not res_candidats.num_tuples.zero? then
		emails=[]
		res_candidats.each do |r|
			message= {
				:to=>[{
					:email=> "#{r['email']}",
					:name=> "#{r['name']}"
				}],
				:merge_vars=>[{
					:rcpt=>"#{r['email']}",
					:vars=>[ {:name=>"CANDIDATE_KEY",:content=>"#{r['candidate_key']}"} ]
				}]
			}
			emails.push(message)
		end
	end
	emails.each do |k|
		begin
			result=mandrill.messages.send_template("laprimaire-org-candidates-part-iii-admin",[],k)
			puts result.inspect
			puts "sending email to #{k[:to][0][:email]}"
			sleep(0.1)
		rescue Mandrill::Error => e
			msg="A mandrill error occurred: #{e.class} - #{e.message}"
			puts msg
		end
	end
end

def email_donateurs_defisc(db,mandrill)
	require 'date'
	message= {
		:to=>[
			{
				:email=> "thib@thib.fr",
				:name=> "Thibauld"
			}  
		],
		:merge_vars=>[
			{
				:vars=>[
					{
						:name=>"DON",
						:content=>"10"
					},
					{
						:name=>"DATE_DON",
						:content=>"12.03.2015"
					},
					{
						:name=>"PRENOM",
						:content=>"Jacques"
					},
					{
						:name=>"MOYEN",
						:content=>"paypal"
					},
				]
			}
		]
	}
	donateurs_csv=CSV.read(ARGV[0])
	donateurs=[] #donateurs
	donateurs_csv.each do |d|
		next if d[0]=='id'
		donateurs.push({
			:id=>d[0],
			:from=>d[1],
			:date=>d[3],
			:amount=>d[4],
			:firstname=>d[6],
			:lastname=>d[7],
			:email=>d[8]
		})
	end
	donateurs.each do |k|
		begin
			from= k[:from]=='stripe' ? 'carte bleue' : k[:from]
			msg=message
			msg[:to][0][:email]=k[:email]
			msg[:to][0][:name]="#{k[:firstname]} #{k[:lastname]}"
			msg[:merge_vars][0][:rcpt]=k[:email]
			msg[:merge_vars][0][:vars][0][:content]=k[:amount]
			msg[:merge_vars][0][:vars][1][:content]=Date.parse(k[:date]).strftime("%d/%m/%Y")
			msg[:merge_vars][0][:vars][2][:content]=k[:firstname]
			msg[:merge_vars][0][:vars][3][:content]=from
			result=mandrill.messages.send_template("laprimaire-org-email-aux-donateurs-i",[],message)
			puts "sending email to #{k[:firstname]} #{k[:lastname]} (#{k[:email]}) pour un don de #{k[:amount]} le #{k[:date]} via #{from}"
			sleep(0.1)
		rescue Mandrill::Error => e
			msg="A mandrill error occurred: #{e.class} - #{e.message}"
			puts msg
		end
	end
end

def email_donateurs_defisc_update(db,mandrill)
	donateurs_csv=CSV.read(ARGV[0])
	emails=[] #donateurs
	donateurs_csv.each do |d|
		next if d[0]=='id'
		message= {
			:to=>[{
				:email=> "#{d[8]}"
			}]
		}
		emails.push(message)
	end
	emails.each do |k|
		begin
			result=mandrill.messages.send_template("laprimaire-org-email-aux-donateurs-ii-bad-news",[],k)
			puts "sending email to #{k[:to][0][:email]} #{result.inspect}"
			sleep(0.1)
		rescue Mandrill::Error => e
			msg="A mandrill error occurred: #{e.class} - #{e.message}"
			puts msg
		end
	end
end

def email_candidat_programme(db,mandrill)
	get_candidates="SELECT candidate_id,candidate_key,name,email FROM candidates WHERE email IS NOT NULL AND verified"
	#get_candidates="SELECT candidate_id,candidate_key,name,email FROM candidates WHERE email IS NOT NULL AND email='tfavre@gmail.com'"
	res_candidats=db.exec(get_candidates)
	if not res_candidats.num_tuples.zero? then
		emails=[]
		res_candidats.each do |r|
			message= {
				:to=>[{
					:email=> "#{r['email']}",
					:name=> "#{r['name']}"
				}]
			}
			emails.push(message)
		end
	end
	emails.each do |k|
		begin
			result=mandrill.messages.send_template("laprimaire-org-candidates-iv-programme",[],k)
			puts "sending email to #{k[:to][0][:email]} #{result.inspect}"
			sleep(0.1)
		rescue Mandrill::Error => e
			msg="A mandrill error occurred: #{e.class} - #{e.message}"
			puts msg
		end
	end
end

def email_candidat_urgent(db,mandrill)
	#get_candidates="SELECT candidate_id,candidate_key,name,email FROM candidates WHERE email IS NOT NULL AND email='tfavre@gmail.com'"
	get_candidates="SELECT candidate_id,candidate_key,name,email FROM candidates WHERE email IS NOT NULL AND verified AND vision is NULL"
	res_candidats=db.exec(get_candidates)
	if not res_candidats.num_tuples.zero? then
		emails=[]
		res_candidats.each do |r|
			message= {
				:to=>[{
					:email=> "#{r['email']}",
					:name=> "#{r['name']}"
				}],
				:merge_vars=>[{
					:rcpt=>"#{r['email']}",
					:vars=>[ {:name=>"CANDIDATE_KEY",:content=>"#{r['candidate_key']}"} ]
				}]
			}
			emails.push(message)
		end
	end
	emails.each do |k|
		begin
			result=mandrill.messages.send_template("laprimaire-org-candidates-part-v-urgent",[],k)
			puts "sending email to #{k[:to][0][:email]} #{result.inspect}"
			sleep(0.1)
		rescue Mandrill::Error => e
			msg="A mandrill error occurred: #{e.class} - #{e.message}"
			puts msg
		end
	end
end
email_candidat_urgent(db,mandrill)
#email_candidat_programme(db,mandrill)
#email_donateurs_defisc_update(db,mandrill)
#email_donateurs_defisc(db,mandrill)
#email_candidat_admin(db,mandrill)
#email_candidat_formation(db,mandrill)
