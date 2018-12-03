using https://github.com/mattearnshaw/docker-redmine-osb

`docker-compose up`

# Manually configured (via docker shell):
## Pre-install
* `docker-compose.yml` redmine environment variables (db, email etc.)
* `dockerFiles/aws.credentials`
* `dockerFiles/db.properties`
* `dockerFiles/GeppettoConfiguration.json`
* `dockerFiles/simulator-config.xml` (simulator.external)
* `dockerFiles/persistence-config.xml` (for changing auth redirect URL if necessary)
* `dockerFiles/Geppetto.properties` (s3 bucket name)

## Post-install
* importing any existing databases
* change database default password
* OSB git repositories
* `redmine/config/props.yml`
* config sendmail in redmine

# Useful stuff
* to restart redmine without restarting the docker `supervisorctl; restart unicorn`
