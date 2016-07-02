#### BOT SETTINGS ####
SECRET="MoNSeCrEt" # LaPrimaireBot API secret
PREFIX="ARaNd0MStrInG" # A secret prefix for your bot webhook, it is a random string
TG_LIVE_TOKEN="000000000:ABCDEFGHiJkLMNoPQrSTuvWYXZ" # Your telegram bot token
TG_TEST_TOKEN="111111111:ABCDEFGHiJkLMNoPQrSTuvWYXZ" # Your test telegram bot token
STATIC_DIR="static/"
TMP_DIR=STATIC_DIR+"tmp/"
CANDIDATS_DIR=STATIC_DIR+"candidats/"
IMAGE_DIR=STATIC_DIR+"images/"
ADMINS=[] # Telegram's ID of the bot admins
BETA_CODES=[]

#### POSTGRESQL (required) ####
PGPORT="5432"
PGHOST_LIVE="127.0.0.1"
PGPWD_LIVE="passwordlive"
PGNAME_LIVE="mydb"
PGUSER_LIVE="user"
PGHOST_TEST="127.0.0.1"
PGPWD_TEST="passwordtest"
PGNAME_TEST="mydb_test"
PGUSER_TEST="user_test"

#### AMAZON WEB SERVICES (required) ####
AWS_BOT_KEY="MY_AWS_KEY"
AWS_BOT_SECRET="MY_AWS_SECRET"
AWS_REGION="eu-central-1"
AWS_BUCKET="laprimaire"
AWS_S3_BUCKET_URL="https://s3.eu-central-1.amazonaws.com/laprimaire/"

#### GOOGLE CUSTOM SEARCH (required) ####
CSKEY = 'MY_GOOGLE_CUSTOM_SEARCH_KEY'
CSID = 'MY_GOOGLE_ID'

#### ALGOLIA (required) ####
ALGOLIA_ID="MY_ALGOLIA_ID"
ALGOLIA_KEY="MY_ALGOLIA_KEY"

#### MIXPANEL (optional) ####
MIXPANEL=false # true if you want to enable Mixpanel emailing support
MIXPANEL_TOKEN="MY_MIXPANEL_TOKEN"

#### MANDRILL (optional) ####
MANDRILL=false # true if you want to enable Mandrill emailing support
MANDRILLKEY="MY_MANDRILL_KEY"

#### SLACK SUPPORT (optional) ####
SLACK=false # true if you want to enable Slack notification support
SLCKHOST="https://hooks.slack.com"
SLCKPATH="/services/HOOKPATH/HOOKPTAH/HOOKENDPOINT"
