# SendChinatownLoveAPI

## Setup
- Ruby x
- Rails 6x
- [Docker-Compose](https://docs.docker.com/compose/install/)


For ubuntu try using ...
https://gorails.com/setup/ubuntu/19.10

1. Download rails, gem install rails — brew install gem
2. brew install postgresql
3. Install heroku cli
4. bundle install --path vendor/bundle
5. rails db:create
6. rails db:migrate
7. heroku local web -> localhost:5000
8. test: heroku local:run bundle exec rspec

## on machine

### Installation
- Download Ruby 2.6.6
- rvm install ruby-X.X.X
If you don't have rvm, gem install rvm:
`\curl -sSL https://get.rvm.io | bash -s stable --ruby`
- Download postgres
`brew install postgresql`
- cd to ruby/ and run `bundle install`. You might have to `gem install bundler`
- Download the local deveopment `.env` file (the secret sauce) and place it in your ruby/ (mac os might give you
a warning about hiding files that begin with '.')
https://drive.google.com/drive/u/2/folders/1vDEWSwn2UFaGXBNCyt0qe60vOa5j6wfH

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

#### Development
- `rails generate model <ModelName>`
- `rails generate controller <ControllerName>`
- `rails generate migration <MigrationName>`

### Troubleshooting

If you're getting errors related to your local environment variables not being set, you probably need to download the new version of .env
https://drive.google.com/drive/u/2/folders/1vDEWSwn2UFaGXBNCyt0qe60vOa5j6wfH

Anytime a new migration is created, you'll have to run `rails db:migrate` for your local dev environment, and `rails db:migrate RAILS_ENV=test` for your local test environment

## containerized
requires
- docker
- docker-compose

```
docker volume create --name=postgres-data-volume
cd api && docker-compose up
# navigate to localhost:3000
```
accessing rail CLI after `docker-compose` is running.

```
docker exec -it api_web_1 bash
# now inside docker container example of commands that can be run

bundle exec rake db:create
bundle exec rake db:migrate

bundle exec rails g model Todo title:string created_by:string
```


## deployment

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
