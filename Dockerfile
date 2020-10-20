FROM centos:7

ARG FDB_VERSION=6.2.27

RUN yum update -y && \
    yum install https://www.foundationdb.org/downloads/${FDB_VERSION}/rhel7/installers/foundationdb-clients-${FDB_VERSION}-1.el7.x86_64.rpm \
    https://www.foundationdb.org/downloads/${FDB_VERSION}/rhel7/installers/foundationdb-server-${FDB_VERSION}-1.el7.x86_64.rpm \
    openssl -y && \
    yum clean all && \
    rm -rf /var/lib/foundationdb/data/* && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/foundationdb/private.key -out /etc/foundationdb/cert.crt -subj "/C=RU/ST=SPB/L=SPB/O=OW/OU=RND/CN=docker/emailAddress=test@example.com" && \
    cat /etc/foundationdb/cert.crt /etc/foundationdb/private.key > /etc/foundationdb/fdb.pem

RUN echo "docker:docker@127.0.0.1:4500:tls" > /etc/foundationdb/fdb.cluster

EXPOSE 4500

CMD fdbserver --listen_address public --public_address 0.0.0.0:4500:tls \
    --datadir /var/lib/foundationdb/data --logdir /var/log/foundationdb \
    --locality_zoneid=`hostname` --locality_machineid=`hostname` \
    --tls_verify_peers="Check.Valid=0"
