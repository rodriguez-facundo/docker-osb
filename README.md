(uses https://github.com/mattearnshaw/docker-redmine-osb)

# Manually configured (via docker shell):
## Pre-install
* `docker-compose.yml` redmine environment variables (db, email etc.), SERVER_IP (eg. = http://comodl.org/), GEPPETTO_IP (eg. = http://comodl.org:8080/) note trailing slashes, redmine branch eg. `context: "git://github.com/mattearnshaw/docker-redmine-osb.git#development"`
* `Dockerfile` set desired geppetto branches
* `dockerFiles/aws.credentials`
* `dockerFiles/db.properties`
* `dockerFiles/GeppettoConfiguration.json`
* `dockerFiles/simulator-config.xml` (simulator.external)
* `dockerFiles/persistence-config.xml` (for changing auth redirect URL if necessary)
* `dockerFiles/Geppetto.properties` (s3 bucket name)
* `dockerFiles/startup.sh` set MAXSIZE heap for jvm
* OSB git repositories -> /srv/docker/redmine/myGitRepositories

## Post-install
* importing any existing databases
* change database default password
* `redmine/config/props.yml`

# To-do
* recaptcha plugin (`rm -rf app/views`)

# Useful stuff
* to restart redmine without restarting the docker `supervisorctl; restart unicorn`
