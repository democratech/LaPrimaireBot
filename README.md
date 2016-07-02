[![OpenCollective](https://opencollective.com/laprimaire/badge/backers.svg)](https://opencollective.com/laprimaire#support)

![LaPrimaire logo](https://s3.eu-central-1.amazonaws.com/laprimaire/laprimaire-small-logo.png)
# LaPrimaireBot

This is the code of LaPrimaire's [Telegram Bot](https://web.laprimaire.org). It uses the [Giskard Bot Engine](https://github.com/telegraph-ai/giskard) and rely on a PostgreSQL database. The bot is served through the [unicorn web server](http://unicorn.bogomips.org/). To better understand how LaPrimaireBot works, please refer to the [Giskard Bot Engine](https://github.com/telegraph-ai/giskard).

## Setup

### Register your Telegram bot
You need to create your Telegram Bot by following [these instructions](https://core.telegram.org/bots#3-how-do-i-create-a-bot) provided by Telegram.

### Clone the repository
To setup LaPrimaireBot on your local computer, first clone the repo locally and install the dependencies:

```console
$ git clone git://github.com/democratech/LaPrimaireBot.git
$ cd LaPrimaireBot
$ bundle install
```
If you don't have the `bundle` command, make sure you have the latest version of ruby (`brew update && brew install ruby`) and then install the bundle command with `gem install bundler`.

### Configure the database
Then, you need to setup your PostgreSQL database. You will need PostgreSQL 9.4 or above. If you are using Ubuntu 14.04 as your dev environment, postgresql-9.4 is not included by default so you should use [postgresql apt repository](https://www.postgresql.org/download/linux/ubuntu/) to install it easily.

Once PostgreSQL is up and running, go ahead and [create a new database role](https://www.postgresql.org/docs/9.1/static/sql-createrole.html) called 'laprimaire' and a new database called 'laprimaire_sandbox' :
```console
$ sudo -s
# su postgres
$ psql
postgres=# CREATE USER laprimaire WITH PASSWORD 'yourpassword';
postgres=# CREATE DATABASE laprimaire_sandbox;
postgres=# GRANT ALL PRIVILEGES ON DATABASE laprimaire_sandbox TO laprimaire;
```

Verify you are able to connect to your newly created database :
```console
$ psql -h localhost -W -U laprimaire laprimaire_sandbox
Password for user laprimaire: 
psql (9.5.3, server 9.5.1)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

laprimaire_sandbox=>
```

Now you are ready to import the sample data that you will find in the [democratech/tools repository](https://github.com/democratech/tools/tree/master/sample_data) :
```console
$ tar xvfz laprimaire_sandbox.sql.tgz
$ psql -h localhost -W -U laprimaire laprimaire_sandbox < laprimaire_sandbox.sql
```

Check that the data has been correctly imported :
```console
$ psql -h localhost -W -U laprimaire laprimaire_sandbox
Password for user laprimaire: 
psql (9.5.3, server 9.5.1)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

laprimaire_sandbox=> \d
                     List of relations
 Schema |           Name            |   Type   |   Owner    
--------+---------------------------+----------+------------
 public | candidates                | table    | laprimaire
 public | candidates_views          | table    | laprimaire
 public | cities                    | table    | laprimaire
 public | cities_city_id_seq        | sequence | laprimaire
 public | citizens                  | table    | laprimaire
 public | countries                 | table    | laprimaire
 public | donateurs                 | table    | laprimaire
 public | donateurs_donateur_id_seq | sequence | laprimaire
 public | supporters                | table    | laprimaire
 public | toutes_candidates         | table    | laprimaire
 public | users                     | table    | laprimaire
(11 rows)

laprimaire_sandbox=>
```

### Create your local config file
With the database setup, you can copy the example configuration file and adapt it to your local settings :
```console
$ cp config/key.rb config/keys.local.rb
$ cat config/keys.local.rb
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
```

### Start the bot
You are now ready to launch the app and test that everything works fine :
```console
$ bundle exec unicorn -c config/unicorn.conf.rb
```

### Setup your webhook development environment
Developing with webhooks can be tricky because it requires Telegram to be able to send queries to your bot instance. If, like 99% developers, you develop on your local PC, Telegram will not be able to send you requests. You should consider using [ngrok](https://ngrok.com/), a true life-saving tool, to easily create secure tunnels to your localhost, thus allowing Telegram to contact your localhost. You should consider purchasing a licence because it is cheap yet super powerful but, for testing purposes, the free version will do: ```ngrok http 8080```

### Declare your webhook endpoint to your Telegram bot
You can use ```curl``` to do it in a straightforward manner:
```
curl -s -X POST https://api.telegram.org/bot<TGTOKEN>/setWebhook?url=<yoursubdomain>.ngrok.io/<WEBHOOK_PREFIX>
```

### Say 'Hi' to your bot
You should now be able to talk to your bot through Telegram and get answers. Troubleshooting potential errors should be easy thanks to ngrok.

## Contributing

1. [Fork it](http://github.com/democratech/pages/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Authors

So far, pages is being developed and maintained by
* [Thibauld Favre](https://twitter.com/thibauld)
* Feel free to contribute by checking the [issues opened](https://github.com/democratech/pages/issues)... we're waiting for you :)

## Backers

Love our work and community? Help us keep it alive by donating funds to cover project expenses!<br />
[[Become a backer](https://opencollective.com/laprimaire)]

  <a href="https://opencollective.com/laprimaire/backers/0/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/0/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/1/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/1/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/2/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/2/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/3/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/3/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/4/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/4/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/5/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/5/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/6/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/6/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/7/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/7/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/8/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/8/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/9/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/9/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/10/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/10/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/11/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/11/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/12/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/12/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/13/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/13/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/14/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/14/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/15/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/15/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/16/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/16/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/17/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/17/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/18/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/18/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/19/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/19/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/20/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/20/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/21/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/21/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/22/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/22/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/23/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/23/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/24/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/24/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/25/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/25/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/26/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/26/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/27/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/27/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/28/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/28/avatar">
  </a>
  <a href="https://opencollective.com/laprimaire/backers/29/website" target="_blank">
    <img src="https://opencollective.com/laprimaire/backers/29/avatar">
  </a>


## License

* LaPrimaireBot is released under the [Apache 2 license](https://github.com/democratech/LaPrimaireBot/blob/master/LICENSE)
* Giskard is released under the [Apache 2 license](https://github.com/telegraph-ai/giskard/blob/master/LICENSE)
* Telegram-bot-ruby is [open-source](https://github.com/atipugin/telegram-bot-ruby)
