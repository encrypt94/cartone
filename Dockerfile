FROM phusion/passenger-ruby21

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

#Install Java
RUN \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer

#Install elasticsearch
RUN \
  cd /tmp && \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.tar.gz && \
  tar xvzf elasticsearch-1.3.2.tar.gz && \
  rm -f elasticsearch-1.3.2.tar.gz && \
  mv /tmp/elasticsearch-1.3.2 /elasticsearch

VOLUME ["/data"]

#Run elasticsearch as daemon with runit
RUN mkdir /etc/service/elasticsearch
ADD ./scripts/elasticsearch.sh /etc/service/elasticsearch/run

ADD . /home/webapp

RUN \
    cd /home/webapp && \
    bundle install && \
    rake install && \
    cp ./scripts/c-crawler.sh /etc/cron.hourly/c-crawler.sh && \
    cp ./scripts/c-cleaner.sh /etc/cron.daily/c-cleaner.sh

EXPOSE 4567

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
