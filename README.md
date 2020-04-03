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

`git subtree push --prefix api heroku master`

or if pipelines already setup, push naturally to branches
