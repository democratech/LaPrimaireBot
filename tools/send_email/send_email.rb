require '../../config/keys.local.rb'
require 'mandrill'
require 'pg'

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
	puts res_candidats
	puts res_candidats.num_tuples
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
	puts emails
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

