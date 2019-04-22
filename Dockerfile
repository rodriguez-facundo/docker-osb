FROM base

LABEL maintainer="Facundo Rodriguez <facundo@metacell.us>"

# Is this ENV required while the container is ruinning?
ENV MAVEN_OPTS=-Dhttps.protocols=TLSv1.2

# Geppetto
ENV BRANCH_BASE=development \
    BRANCH_DEFAULT=master

ENV BRANCH_ORG_GEPPETTO=$BRANCH_DEFAULT \
    BRANCH_ORG_GEPPETTO_FRONTEND=$BRANCH_DEFAULT \
    BRANCH_ORG_GEPPETTO_CORE=$BRANCH_DEFAULT \
    BRANCH_ORG_GEPPETTO_MODEL=$BRANCH_DEFAULT \
    BRANCH_ORG_GEPPETTO_MODEL_SWC=$BRANCH_DEFAULT \
    BRANCH_ORG_GEPPETTO_MODEL_NEUROML=$BRANCH_DEFAULT \
    BRANCH_ORG_GEPPETTO_PERSISTENCE=$BRANCH_DEFAULT \
    BRANCH_ORG_GEPPETTO_SIMULATION=$BRANCH_DEFAULT \
    BRANCH_ORG_GEPPETTO_SIMULATOR_EXTERNAL=$BRANCH_DEFAULT \
    BRANCH_GEPPETTO_OSB=$BRANCH_DEFAULT

USER virgo
WORKDIR $GEPPETTO_HOME

# Persistence Config
COPY dockerFiles/aws.credentials $GEPPETTO_HOME/aws.credentials
COPY dockerFiles/db.properties $GEPPETTO_HOME/db.properties

# Copy samples
RUN git clone https://github.com/OpenSourceBrain/OSB_Samples &&\
    rm -rf .git

# Clone Geppetto repositories
RUN /bin/echo -e "\e[1;35mCloning required modules\e[0m"

RUN git clone https://github.com/openworm/org.geppetto.git -b $BRANCH_BASE && \
    cd org.geppetto &&\
    git checkout $BRANCH_ORG_GEPPETTO &&\
    rm -rf .git \
    || true

RUN git clone https://github.com/openworm/org.geppetto.frontend.git -b $BRANCH_BASE && \
    cd org.geppetto.frontend &&\
    git checkout $BRANCH_ORG_GEPPETTO_FRONTEND &&\
    rm -rf .git \
    || true

RUN cd org.geppetto.frontend/src/main/webapp/extensions &&\
    git clone https://github.com/OpenSourceBrain/geppetto-osb.git -b $BRANCH_BASE && \
    cd geppetto-osb &&\
    git checkout $BRANCH_GEPPETTO_OSB &&\
    rm -rf .git \
    || true

RUN git clone https://github.com/openworm/org.geppetto.core.git -b $BRANCH_BASE && \
    cd org.geppetto.core &&\
    git checkout $BRANCH_ORG_GEPPETTO_CORE &&\
    rm -rf .git \
    || true

RUN git clone https://github.com/openworm/org.geppetto.model.git -b $BRANCH_BASE && \
    cd org.geppetto.model &&\
    git checkout $BRANCH_ORG_GEPPETTO_MODEL &&\
    rm -rf .git \
    || true

RUN git clone https://github.com/openworm/org.geppetto.persistence.git -b $BRANCH_BASE && \
    cd org.geppetto.persistence &&\
    git checkout $BRANCH_ORG_GEPPETTO_PERSISTENCE &&\
    rm -rf .git \
    || true

RUN git clone https://github.com/openworm/org.geppetto.model.swc.git -b $BRANCH_BASE && \
    cd org.geppetto.model.swc &&\
    git checkout $BRANCH_ORG_GEPPETTO_MODEL_SWC &&\
    rm -rf .git \
    || true

RUN git clone https://github.com/openworm/org.geppetto.model.neuroml.git -b $BRANCH_BASE && \
    cd org.geppetto.model.neuroml &&\
    git checkout $BRANCH_ORG_GEPPETTO_MODEL_NEUROML &&\
    rm -rf .git \
    || true

RUN git clone https://github.com/openworm/org.geppetto.simulation.git -b $BRANCH_BASE && \
    cd org.geppetto.simulation &&\
    git checkout $BRANCH_ORG_GEPPETTO_SIMULATION &&\
    rm -rf .git \
    || true

RUN git clone https://github.com/openworm/org.geppetto.simulator.external.git -b $BRANCH_BASE && \
    cd org.geppetto.simulator.external &&\
    git checkout $BRANCH_ORG_GEPPETTO_SIMULATOR_EXTERNAL &&\
    rm -rf .git \
    || true

#Setup config:
COPY --chown=virgo:virgo dockerFiles/pom.xml $GEPPETTO_HOME/org.geppetto/pom.xml.temp
COPY --chown=virgo:virgo dockerFiles/geppetto.plan $GEPPETTO_HOME/org.geppetto/geppetto.plan
COPY --chown=virgo:virgo dockerFiles/GeppettoConfiguration.json $GEPPETTO_HOME/org.geppetto.frontend/src/main/webapp/GeppettoConfiguration.json
COPY --chown=virgo:virgo dockerFiles/Geppetto.properties $GEPPETTO_HOME/org.geppetto.core/src/main/resources/Geppetto.properties
COPY --chown=virgo:virgo dockerFiles/simulator-config.xml $GEPPETTO_HOME/org.geppetto.simulator.external/src/main/java/META-INF/spring/app-config.xml
COPY --chown=virgo:virgo dockerFiles/persistence-config.xml $GEPPETTO_HOME/org.geppetto.persistence/src/main/java/META-INF/spring/app-config.xml
COPY --chown=virgo:virgo dockerFiles/startup.sh /opt/OSB/startup.sh

RUN chmod +x /opt/OSB/*.sh | true


# Update modules
RUN /bin/echo -e "\e[1;35mUpdating modules\e[0m"
RUN cd $GEPPETTO_HOME/org.geppetto && \
    VERSION=$(cat pom.xml | grep version | sed -e 's/\///g' | sed -e 's/\ //g' | sed -e 's/\t//g' | sed -e 's/<version>//g') && \
    echo "$VERSION" && \
    mv pom.xml.temp pom.xml && \
    sed -i "s@%VERSION%@${VERSION}@g" pom.xml && \
    sed -i "s@%VERSION%@${VERSION}@g" geppetto.plan

# Build Geppetto:
RUN cd $GEPPETTO_HOME/org.geppetto &&\
    mvn -Dhttps.protocols=TLSv1.2 -Dmaven.test.skip clean install

RUN cd $GEPPETTO_HOME/org.geppetto/utilities/source_setup &&\
    python2.7 update_server.py

EXPOSE 8080
VOLUME $HOME
WORKDIR $HOME

# ENTRYPOINT ["/opt/OSB/startup.sh"]
