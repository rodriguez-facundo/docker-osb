FROM ubuntu:xenial-20180705 AS add-apt-repositories

USER root
# update maven: 
COPY dockerFiles/apache-maven-3.3.9-bin.tar.gz /tmp/apache-maven-3.3.9-bin.tar.gz
RUN cd /opt/ \
&& tar -zxvf /tmp/apache-maven-3.3.9-bin.tar.gz
RUN chmod -R 777 /opt
RUN apt-get update --fix-missing && apt-get install -y make gcc libncurses-dev software-properties-common sshfs git curl bsdtar && \
    add-apt-repository ppa:openjdk-r/ppa  && \
    apt-get upgrade -y && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV PATH=/opt/apache-maven-3.3.9/bin/:$PATH

RUN useradd -ms /bin/bash virgo
USER virgo
# Geppetto:
ENV BRANCH_BASE=development
ENV BRANCH_DEFAULT=master
ENV BRANCH_ORG_GEPPETTO=$BRANCH_DEFAULT
ENV BRANCH_ORG_GEPPETTO_FRONTEND=$BRANCH_DEFAULT
ENV BRANCH_ORG_GEPPETTO_CORE=$BRANCH_DEFAULT
ENV BRANCH_ORG_GEPPETTO_MODEL=$BRANCH_DEFAULT
ENV BRANCH_ORG_GEPPETTO_MODEL_SWC=$BRANCH_DEFAULT
ENV BRANCH_ORG_GEPPETTO_MODEL_NEUROML=$BRANCH_DEFAULT
ENV BRANCH_ORG_GEPPETTO_PERSISTENCE=$BRANCH_DEFAULT
ENV BRANCH_ORG_GEPPETTO_SIMULATION=$BRANCH_DEFAULT
ENV BRANCH_ORG_GEPPETTO_SIMULATOR_EXTERNAL=$BRANCH_DEFAULT
ENV BRANCH_GEPPETTO_OSB=$BRANCH_DEFAULT

# Persistence Config
RUN mkdir -p /home/virgo/geppetto/
COPY dockerFiles/aws.credentials /home/virgo/geppetto/aws.credentials
COPY dockerFiles/db.properties /home/virgo/geppetto/db.properties

RUN cd /home/virgo && git clone https://github.com/OpenSourceBrain/OSB_Samples

RUN mkdir -p /opt/geppetto
ENV SERVER_HOME=/home/virgo/
RUN cd /opt/geppetto && \
echo cloning required modules: && \
git clone https://github.com/openworm/org.geppetto.git -b $BRANCH_BASE && \
cd org.geppetto && git checkout $BRANCH_ORG_GEPPETTO || true
RUN cd /opt/geppetto && \
git clone https://github.com/openworm/org.geppetto.frontend.git -b $BRANCH_BASE && \
cd org.geppetto.frontend && git checkout $BRANCH_ORG_GEPPETTO_FRONTEND || true 
RUN cd /opt/geppetto && \
git clone https://github.com/OpenSourceBrain/geppetto-osb.git -b $BRANCH_BASE && \
cd geppetto-osb && git checkout $BRANCH_GEPPETTO_OSB || true 
RUN cd /opt/geppetto && \
git clone https://github.com/openworm/org.geppetto.core.git -b $BRANCH_BASE && \
cd org.geppetto.core && git checkout $BRANCH_ORG_GEPPETTO_CORE || true 
RUN cd /opt/geppetto && \
git clone https://github.com/openworm/org.geppetto.model.git -b $BRANCH_BASE && \
cd org.geppetto.model && git checkout $BRANCH_ORG_GEPPETTO_MODEL || true 
RUN cd /opt/geppetto && \
git clone https://github.com/openworm/org.geppetto.persistence.git -b $BRANCH_BASE && \
cd org.geppetto.persistence && git checkout $BRANCH_ORG_GEPPETTO_PERSISTENCE || true 
RUN cd /opt/geppetto && \
git clone https://github.com/openworm/org.geppetto.model.swc.git -b $BRANCH_BASE && \
cd org.geppetto.model.swc && git checkout $BRANCH_ORG_GEPPETTO_MODEL_SWC || true 
RUN cd /opt/geppetto && \
git clone https://github.com/openworm/org.geppetto.model.neuroml.git -b $BRANCH_BASE && \
cd org.geppetto.model.neuroml && git checkout $BRANCH_ORG_GEPPETTO_MODEL_NEUROML || true 
RUN cd /opt/geppetto && \
git clone https://github.com/openworm/org.geppetto.simulation.git -b $BRANCH_BASE && \
cd org.geppetto.simulation && git checkout $BRANCH_ORG_GEPPETTO_SIMULATION || true 
RUN cd /opt/geppetto && \
git clone https://github.com/openworm/org.geppetto.simulator.external.git -b $BRANCH_BASE && \
cd org.geppetto.simulator.external && git checkout $BRANCH_ORG_GEPPETTO_SIMULATOR_EXTERNAL || true 
RUN cd /opt/geppetto && \
mv geppetto-osb org.geppetto.frontend/src/main/webapp/extensions/

#Setup config:
COPY dockerFiles/pom.xml /opt/geppetto/org.geppetto/pom.xml.temp
COPY dockerFiles/geppetto.plan /opt/geppetto/org.geppetto/geppetto.plan
COPY dockerFiles/GeppettoConfiguration.json /opt/geppetto/org.geppetto.frontend/src/main/webapp/GeppettoConfiguration.json
COPY dockerFiles/Geppetto.properties /opt/geppetto/org.geppetto.core/src/main/resources/Geppetto.properties
COPY dockerFiles/simulator-config.xml /opt/geppetto/org.geppetto.simulator.external/src/main/java/META-INF/spring/app-config.xml
COPY dockerFiles/persistence-config.xml /opt/geppetto/org.geppetto.persistence/src/main/java/META-INF/spring/app-config.xml
RUN mkdir -p /opt/OSB
COPY dockerFiles/startup.sh /opt/OSB/startup.sh
USER root
RUN chmod -R 777 /opt/geppetto | true
RUN chmod +x /opt/OSB/*.sh | true
USER virgo

RUN echo Updating Modules... && \
cd /opt/geppetto/org.geppetto && \
VERSION=$(cat pom.xml | grep version | sed -e 's/\///g' | sed -e 's/\ //g' | sed -e 's/\t//g' | sed -e 's/<version>//g') && \
echo "$VERSION" && \
mv pom.xml.temp pom.xml && \
sed -i "s@%VERSION%@${VERSION}@g" pom.xml && \
sed -i "s@%VERSION%@${VERSION}@g" geppetto.plan

ENV MAVEN_OPTS=-Dhttps.protocols=TLSv1.2
#RUN git clone https://github.com/OpenSourceBrain/geppetto-osb.git

#RUN mv geppetto-osb workspace/org.geppetto.frontend/src/main/webapp/extensions/ 
RUN sed 's/geppetto-default\/ComponentsInitialization":\ true/geppetto-default\/ComponentsInitialization":\ false/g' /opt/geppetto/org.geppetto.frontend/src/main/webapp/GeppettoConfiguration.json | sed -e 's/geppetto-osb\/ComponentsInitialization":\ false/geppetto-osb\/ComponentsInitialization":\ true/g' | sed -e 's/embedderURL":\ \["\/"\]/embedderURL":\ ["http:\/\/0.0.0.0:3000"]/' | sed -e 's/embedded":\ false/embedded":\ true/' > /opt/geppetto/org.geppetto.frontend/src/main/webapp/NEWGeppettoConfiguration.json && \
mv /opt/geppetto/org.geppetto.frontend/src/main/webapp/NEWGeppettoConfiguration.json /opt/geppetto/org.geppetto.frontend/src/main/webapp/GeppettoConfiguration.json

RUN curl -L 'http://www.eclipse.org/downloads/download.php?file=/virgo/release/VP/3.6.4.RELEASE/virgo-tomcat-server-3.6.4.RELEASE.zip&mirror_id=580&r=1' | bsdtar --strip-components 1 -C /home/virgo -xzf -
EXPOSE 8080
USER root
RUN chmod u+x /home/virgo/bin/*.sh
RUN chown -R virgo:virgo /home/virgo
USER virgo
VOLUME /home/virgo

# Build Geppetto:
RUN cd /opt/geppetto/org.geppetto && mvn -Dhttps.protocols=TLSv1.2 -Dmaven.test.skip clean install
#RUN cd workspace/org.geppetto && mvn --quiet clean install
USER root
RUN apt update && apt upgrade && apt-get -y install python2.7 wget make gcc lsof libreadline5 libreadline-dev lib32z1-dev libpython2.7-dev mpich autoconf python-pip
RUN ln -s /usr/bin/python2.7 /usr/bin/python
USER virgo
RUN cd /opt/geppetto/org.geppetto/utilities/source_setup && python2.7 update_server.py
RUN cd /opt/geppetto && git clone git://github.com/NeuroML/jNeuroML.git neuroml_dev/jNeuroML && cd neuroml_dev/jNeuroML && python getNeuroML.py
RUN cd /tmp && wget "https://neuron.yale.edu/ftp/neuron/versions/v7.6/7.6.2/nrn-7.6.2.tar.gz" && tar xvfz nrn-7.6.2.tar.gz
USER root
RUN cd /tmp/nrn-7.6 && ./configure --without-iv --with-nrnpython=/usr/bin/python2.7 && make && make install
RUN pip install --upgrade pip && python -m pip install pynn netpyne pyneuroml
USER virgo

ENTRYPOINT ["/opt/OSB/startup.sh"]
#RUN useradd -ms /bin/bash virgo
