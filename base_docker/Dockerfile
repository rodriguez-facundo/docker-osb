FROM ubuntu:xenial-20180705

LABEL maintainer="Facundo Rodriguez <facundo@metacell.us>"

# Set user name
ENV USER=virgo

# Software versions
ENV VIRGO_RELEASE=3.6.4 \
  MAVEN_VERSION=3.3.9 \
  NEURON_VERSION=7.6.2

# Set local paths
ENV HOME=/home/$USER \
  MAVEN_HOME=/opt/maven \
  SERVER_HOME=/home/$USER \
  GEPPETTO_HOME=/home/$USER/geppetto

# Set PATH
ENV PATH=$PATH:$MAVEN_HOME/bin:/usr/local/nrn/x86_64/bin

# Software download urls
ENV MAVEN_HTTP=http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  VIRGO_HTTP=http://www.eclipse.org/downloads/download.php?file=/virgo/release/VP/$VIRGO_RELEASE.RELEASE/virgo-tomcat-server-$VIRGO_RELEASE.RELEASE.zip&r=1 \
  NEURON_HTTP=https://neuron.yale.edu/ftp/neuron/versions/v7.6/$NEURON_VERSION/nrn-$NEURON_VERSION.tar.gz \
  JNEUROML_HTTP=git://github.com/NeuroML/jNeuroML.git
  
# Create new user
RUN useradd -ms /bin/bash virgo

# Set new user permissions
RUN mkdir -p /etc/sudoers.d \
      $MAVEN_HOME \
      $SERVER_HOME \
      $GEPPETTO_HOME \
      /opt/geppetto \
      /opt/OSB \
      /tmp/nrn &&\
    echo "$USER:x:1000:1000:OSB,,,:$HOME:/bin/bash" >> /etc/passwd && \
    echo "$USER:x:1000:" >> /etc/group && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    chown $USER:$USER -R $HOME
    # chown root:root /usr/bin/sudo &&\
    # chmod 4755 /usr/bin/sudo

# Install requirements and clean up
RUN apt-get -qq update --fix-missing &&\
    apt-get -yq install \
      bsdtar \
      curl \
      g++ \
      gcc \
      git \
      lib32z1-dev \
      libncurses-dev \
      libpython2.7-dev \
      libreadline5 \
      libreadline-dev \
      lsof \
      mpich \
      autoconf \
      make \
      python2.7 \
      python-pip \
      software-properties-common \
      sshfs \
      wget &&\
    add-apt-repository ppa:openjdk-r/ppa  && \
    apt-get upgrade -y && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# Symlink for OSB.sh script
RUN ln -s /usr/bin/python2.7 /usr/bin/python | true
# USER root

# Install maven
RUN wget -qO- $MAVEN_HTTP | tar xzf - -C $MAVEN_HOME --strip-components 1 && mvn --version

# Install virgo
RUN curl -L $VIRGO_HTTP | bsdtar -xzf - -C $SERVER_HOME --strip-components 1

# Install NEURON
RUN wget -qO- $NEURON_HTTP | tar xzf - -C /tmp/nrn --strip-components 1 &&\
    cd /tmp/nrn &&\
    ./configure \
      --without-iv \
      --with-nrnpython=/usr/bin/python2.7 &&\
    make &&\
    make install &&\
    nrniv --version &&\
    rm -rf /tmp/nrn

# Install python packages
RUN pip install --upgrade pip &&\
    python -m pip install \
      pynn \
      netpyne \
      pyneuroml

# Install jNeuroML
RUN cd /opt/geppetto &&\
    git clone $JNEUROML_HTTP neuroml_dev/jNeuroML &&\
    cd neuroml_dev/jNeuroML &&\
    python getNeuroML.py &&\
    rm -rf .git