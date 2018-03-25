FROM debian:jessie

ARG GRAFANA_VERSION="latest"
ARG GF_URL=https://s3-us-west-2.amazonaws.com/grafana-releases/release
# instead of copying the binaries, change PATH so that the binaries are only in one place
ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    # Remove ENV variables from run.sh and have them defined here
    GF_PATHS_PROVISIONING=/etc/grafana/provisioning \
    GF_PATHS_PLUGINS=/var/lib/grafana/plugins \
    GF_PATHS_LOGS=/var/log/grafana \
    GF_PATHS_HOME=/usr/share/grafana \
    GF_PATHS_DATA=/var/lib/grafana \
    GF_PATHS_CONFIG=/etc/grafana/grafana.ini
RUN apt-get update && apt-get install -qq -y wget tar sqlite libfontconfig curl ca-certificates && \
    mkdir -p $GF_PATHS_HOME && \
    # extract directly in target dir, exclude tools as they are 65MB in size.
    wget -qO- $GF_URL/grafana-$GRAFANA_VERSION.linux-x64.tar.gz |tar xfvz - --strip-components=1 --exclude=tools -C $GF_PATHS_HOME && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/grafana/provisioning/datasources && \
    mkdir -p /etc/grafana/provisioning/dashboards && \
    mkdir -p /var/lib/grafana/plugins && \
    mkdir -p /var/log/grafana && \
    cp $GF_PATHS_HOME/conf/sample.ini /etc/grafana/grafana.ini && \
    cp $GF_PATHS_HOME/conf/ldap.toml /etc/grafana/ldap.toml && \
    chown -R nobody:nogroup /var/lib/grafana && \
    chown -R nobody:nogroup $GF_PATHS_HOME && \
    chown -R nobody:nogroup /var/log/grafana
# also create log-dir, in case someone want to write log files
VOLUME ["/var/lib/grafana", "/var/log/grafana"]
EXPOSE 3000
COPY ./run.sh /run.sh
USER nobody
CMD [ "/run.sh" ]
