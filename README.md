# SendChinatownLoveAPI

## Setup 🔧
- Ruby x
- Rails 6x
- [Docker-Compose](https://docs.docker.com/compose/install/)

For ubuntu try using ...
https://gorails.com/setup/ubuntu/19.10

1. Download rails, gem install rails — brew install gem
1. brew install postgresql
1. Install heroku cli
1. bundle install --path vendor/bundle
1. rails db:create
1. rails db:migrate
1. heroku local web -> localhost:5000
1. test: heroku local:run bundle exec rspec

## on machine

### Installation
- Download Ruby 2.6.6
- rvm install ruby-X.X.X
If you don't have rvm, gem install rvm:
`\curl -sSL https://get.rvm.io | bash -s stable --ruby`
- Download postgres
`brew install postgresql`
- cd to ruby/ and run `bundle install`. You might have to `gem install bundler`
- Create a `.env` file (the secret sauce) by running this command `cp .env.example .env`
- Follow the following guide to fill the .env file in
https://docs.google.com/document/d/1UPNCwjWS_T7XT5AXsewphu6NvNdV7TQLSJub-RBRAG0/edit?ts=5ec88e82


### Create and migrate database
- Run the server (see below) and create and migrate your DB:
`rails db:create && rails db:migrate`
If you see an error like
`Couldn't create 'myapp_development' database. Please check your configuration.
rails aborted!
PG::ConnectionBad: could not connect to server: No such file or directory`, try running `brew services restart postgresql` [source](https://stackoverflow.com/questions/19828385/pgconnectionbad-could-not-connect-to-server-connection-refused)

If you get a migration error like `PG::UndefinedTable: ERROR:` or `PG::NotNullViolation`, try running `rails db:environment:set RAILS_ENV=development` --> `rails db:reset` --> `rails db:migrate`

### Useful commands
- Run the server: `heroku local web`
  If you see an error that looks like `No such file or directory @ rb_sysopen - tmp/pids/puma.pid`, run:

  `mkdir tmp`

  `mkdir tmp/pids`

  [source](https://stackoverflow.com/questions/52862529/no-such-file-or-directory-rb-sysopen-tmp-pids-puma-pid)

- Run the server on port 3001: `heroku local web -p 3001`
You'll need to do this if you're getting cors errors from the frontend. Stop your frontend server, start the rails server on 3001, then start the local server again from port 3000 using `yarn start`
- Run all tests: `heroku local:run bundle exec rspec`
- Run specific tests: `heroku local:run bundle exec rspec -e "<insert string from test description>"`
- Run console: `heroku local:run rails console`
- Run local migrations in prod `heroku run rake db:migrate` (do this after submitting a change with a local migration)
- Install annotate [`gem install annotate`](https://github.com/ctran/annotate_models)
- Annotate models `annotate --models`
- Annotate everything `annotate`

#### Development
- `rails generate model <ModelName>`
- `rails generate controller <ControllerName>`
- `rails generate migration <MigrationName>`

### Enabling Webhooks locally

For you to work with webhooks, you need a domain for square to send events to. To do this without a hosted service,
you can forward your localhost port using something like [ngrok](https://ngrok.com/) or [localhost.run](https://localhost.run/).
This also enables you to share your local environment in pull requests for additional validations.

1. Setup localhost.run or ngrok or any derivatives to forward your localhost port to the web.
1. Make the port forwarder point to your local port. localhost.run cmd: `ssh -R 80:localhost:5000 ssh.localhost.run`
1. Go to: https://developer.squareup.com/apps
1. Go to the webhooks pane and create a sandbox api to point to domain created above.
1. Enable the following events:
    * refund.created
    * refund.updated
    * payment.updated
1. Edit `.env` file.
    1. Edit `SQUARE_WEBHOOK_SIGNATURE_KEY` to the signature key from when you created the webhooks.
    1. Edit `RAILS_WEBHOOK_URL` to your domain + webhooks url. For instance `https://example.com/webhooks`. This is used for validating requests.

### Seeding Gift Cards

First evaluate which seller the gift cards are going to go towards, how many are needed, and who is going to distribute the gift cards.

Run the command below

_**NOTE:** A dollar is 100. If you wish to seed $5, put 500 as the amount._

```sh
heroku run -a {HEROKU APP} 'rake gift_cards:create -s {SELLER_ID} -m {DISTRIBUTOR_EMAIL} -q {QUANTITY} -a {AMOUNT}'
```

#### Reference Links

* https://dev.to/giorgosk/expose-your-local-web-server-to-the-world-using-localhost-run-or-serveo-net-l83

### Troubleshooting

If you're getting errors related to your local environment variables not being set, you probably need to create a .env file
https://docs.google.com/document/d/1UPNCwjWS_T7XT5AXsewphu6NvNdV7TQLSJub-RBRAG0/edit?ts=5ec88e82

Anytime a new migration is created, you'll have to run `rails db:migrate` for your local dev environment, and `rails db:migrate RAILS_ENV=test` for your local test environment

## containerized
Running a containerized version of the app requires Docker and Docker Compose. In addition, some updates will be required to the `config/database.yml` file for the app to work within Docker. You may also need to enable Square webhooks in order for some pages, so reference the [Enabling Webhooks](##Enabling-Webhooks-locally) section.

```
docker volume create --name=postgres-data-volume
cd <scl-be directory> && docker-compose up
```
accessing rail CLI after `docker-compose` is running.

```
# Replace <scl-be directory name> with the name of the direcotry that you cloned the repo into
docker exec -it <scl-be directory name>_web_1 bash

# now inside docker container example of commands that can be run
bundle exec rake db:create
bundle exec rake db:migrate

bundle exec rake db:seed

bundle exec rails g model Todo title:string created_by:string
```


## deployment 🚀

install [heroku-cli](https://devcenter.heroku.com/articles/heroku-cli)

After `heroku login` and you are added the project
if you setup your heroku app, you should have a remote added; if not explicitly run

git remote add heroku https://git.heroku.com/sendchinatownlove.git`
`git subtree push --prefix api heroku master`

or if pipelines already setup, push naturally to branches


### DNS & SSL
Follow instructions to enable DNS. `https://devcenter.heroku.com/articles/custom-domains`


heroku comes with auto-ssl for all hobby and up dynos

run
`heroku certs:auto:enable`
