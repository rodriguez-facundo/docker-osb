using https://github.com/mattearnshaw/docker-redmine-osb

`docker-compose build --build-arg GEPPETTO_IP=http://opensourcebrain.org:8080/ --build-arg SERVER_IP=http://opensourcebrain.org/ redmine`

# Manually configured (via docker shell):
## Pre-install
* `docker-compose.yml` redmine environment variables (db, email etc.)
* `Dockerfile` set desired geppetto branches
* `dockerFiles/aws.credentials`
* `dockerFiles/db.properties`
* `dockerFiles/GeppettoConfiguration.json`
* `dockerFiles/simulator-config.xml` (simulator.external)
* `dockerFiles/persistence-config.xml` (for changing auth redirect URL if necessary)
* `dockerFiles/Geppetto.properties` (s3 bucket name)
* OSB git repositories -> /srv/docker/redmine/myGitRepositories

## Post-install
* importing any existing databases
* change database default password
* `redmine/config/props.yml`

# Useful stuff
* to restart redmine without restarting the docker `supervisorctl; restart unicorn`
