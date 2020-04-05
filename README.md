
# SendChinatownLoveAPI



## Setup
- Ruby x 
- Rails 6x 
- [Docker-Compose](https://docs.docker.com/compose/install/)


For ubuntu try using ... 
https://gorails.com/setup/ubuntu/19.10

## on machine

TBD 


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