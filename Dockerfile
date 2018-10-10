FROM slarson/org.geppetto.docker

ENV SERVER_HOME=/home/developer/virgo/
ENV MAVEN_OPTS=-Dhttps.protocols=TLSv1.2
ENV EMBEDDER_URL=
ENV GEPPETTO_IP=
ENV SERVER_IP=
RUN git clone https://github.com/OpenSourceBrain/geppetto-osb.git

RUN mv geppetto-osb workspace/org.geppetto.frontend/src/main/webapp/extensions/ && \
sed 's/geppetto-default\/ComponentsInitialization":\ true/geppetto-default\/ComponentsInitialization":\ false/g' workspace/org.geppetto.frontend/src/main/webapp/GeppettoConfiguration.json | sed -e 's/geppetto-osb\/ComponentsInitialization":\ false/geppetto-osb\/ComponentsInitialization":\ true/g' > workspace/org.geppetto.frontend/src/main/webapp/NEWGeppettoConfiguration.json && \
mv workspace/org.geppetto.frontend/src/main/webapp/NEWGeppettoConfiguration.json workspace/org.geppetto.frontend/src/main/webapp/GeppettoConfiguration.json

RUN cd workspace/org.geppetto && mvn --quiet clean install
RUN cd workspace/org.geppetto/utilities/source_setup && python update_server.py

#RUN useradd -ms /bin/bash virgo
