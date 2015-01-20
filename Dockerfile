# ELK Dockerfile by MO 
#
# VERSION 0.1
FROM ubuntu:14.04.1
MAINTAINER MO

# Setup env and apt
ENV DEBIAN_FRONTEND noninteractive
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
RUN apt-get update -y
RUN apt-get dist-upgrade -y

# Get and install packages 
RUN apt-get install -y apache2 supervisor wget openjdk-7-jdk openjdk-7-jre-headless && \ 
    cd /root/ && \
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.deb && \
    wget https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb && \
    wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz && \
    dpkg -i elasticsearch-1.4.2.deb && \
    dpkg -i logstash_1.4.2-1-2c0f5a1_all.deb && \
    tar -xzf kibana-3.1.2.tar.gz && mv kibana-3.1.2/* /var/www/html/ && \
    rm -rf kibana-3.1.2

# Setup user, groups and configs
RUN addgroup --gid 2000 tpot && \
    adduser --system --no-create-home --shell /bin/bash --uid 2000 --disabled-password --disabled-login --gid 2000 tpot && \
    sed -i 's#elasticsearch: "http://"+window.location.hostname+":9200",#elasticsearch: "http://"+window.location.hostname+"/elasticsearch/",#' /var/www/html/config.js && \
    a2enmod proxy proxy_http
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf 
ADD logstash.conf /etc/logstash/conf.d/logstash.conf
ADD suricata.json /var/www/html/app/dashboards/default.json

# Clean up 
RUN apt-get remove wget -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/*.deb /root/*.tar.gz

# Start ELK
CMD ["/usr/bin/supervisord"]