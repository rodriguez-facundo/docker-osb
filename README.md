using https://github.com/mattearnshaw/docker-redmine-osb

`docker-compose up`

# Manually configured (via docker shell):
## Pre-install
* `docker-compose.yml` redmine environment variables (db, email etc.)
* `dockerFiles/aws.credentials`
* `dockerFiles/db.properties`
* `dockerFiles/GeppettoConfiguration.json`
* `dockerFiles/app-config.xml` (simulator.external)
* `dockerFiles/Geppetto.properties` (s3 bucket name)

## Post-install
* importing any existing databases
* change database default password
* OSB git repositories
* `redmine/config/props.yml`
