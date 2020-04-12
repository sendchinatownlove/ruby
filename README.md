
# SendChinatownLoveAPI



## Setup
- Ruby x
- Rails 6x
- [Docker-Compose](https://docs.docker.com/compose/install/)


For ubuntu try using ...
https://gorails.com/setup/ubuntu/19.10

## on machine

### Installation
- Download Ruby 2.6.3
- rvm install ruby-X.X.X
If you don't have rvm, gem install rvm:
`\curl -sSL https://get.rvm.io | bash -s stable --ruby`
- Download postgres
`brew install postgresql`
- Run `bundle install`. You might have to `gem install bundler`
- Download the local deveopment `.env` file and place it in your ruby/
https://drive.google.com/drive/u/2/folders/1vDEWSwn2UFaGXBNCyt0qe60vOa5j6wfH

### Create and migrate database
- Create and migrate your DB:
`rails db:create && rails db:migrate`

### Useful commands
Run the server: `heroku local:run rails server`
Run the server on port 3001: `heroku local:run rails server -p 3001`
You'll need to do this if you're getting cors errors from the frontend. Stop your frontend server, start the rails server on 3001, then start the local server again from port 3000 using `yarn start`
Run all tests: `heroku local:run bundle exec rspec`
Run specific tests: `heroku local:run bundle exec rspec -e "<insert string from test description>"`
Run console: `heroku local:run rails console`

#### Development
`rails generate model <ModelName>`
`rails generate controller <ControllerName>`
`rails generate migration <MigrationName>`

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

```
This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

```