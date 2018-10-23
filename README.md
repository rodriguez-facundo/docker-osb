using https://github.com/mattearnshaw/docker-redmine-osb

`docker-compose up`

# Manually configured (via docker shell):
## Pre-install
* `dockerFile/aws.credentials`
* `dockerFile/db.properties`
* `dockerFile/GeppettoConfiguration.json`
* `simulator.external` app-config.xml
* `org.geppetto.core/src/main/resources/Geppetto.properties` Amazon S3 bucket info
##Post-install
* importing any existing databases
* change database default password
* OSB git repositories
