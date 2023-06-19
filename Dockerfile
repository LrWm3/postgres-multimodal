ARG PG_VERSION=12
ARG APACHE_AGE_VERSION=1.3.0
ARG TIMESCALE_VERSION=2.11

FROM timescale/timescaledb-ha:pg${PG_VERSION}-ts${TIMESCALE_VERSION}-oss

ARG PG_VERSION
ARG APACHE_AGE_VERSION
ARG TIMESCALE_VERSION

# Switch to root user to install apache age
USER root

# Install apache age
RUN apt-get update && apt-get install -y git curl build-essential libreadline-dev zlib1g-dev flex bison make software-properties-common gpg-agent
RUN apt update && apt install -y postgresql-server-dev-${PG_VERSION}

# wget https://github.com/apache/age/releases/download/PG13%2Fv${APACHE_AGE_VERSION}-rc0/apache-age-${APACHE_AGE_VERSION}-src.tar.gz to local dir
RUN curl -LJO https://github.com/apache/age/releases/download/PG${PG_VERSION}%2Fv${APACHE_AGE_VERSION}-rc1/apache-age-${APACHE_AGE_VERSION}-src.tar.gz
RUN tar -xvzf apache-age-${APACHE_AGE_VERSION}-src.tar.gz
RUN cd apache-age-${APACHE_AGE_VERSION} && make PG_CONFIG=/usr/lib/postgresql/${PG_VERSION}/bin/pg_config install

# Soft-link to allow non-super users to run age
RUN ln -s /usr/lib/postgresql/${PG_VERSION}/lib/age.so /usr/lib/postgresql/${PG_VERSION}/lib/plugins/age.so

# PostgresML

# fixme - clean up this, could install a lot earlier.
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update
RUN apt-get install -y python3.10 python3-pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
RUN update-alternatives --config python3
RUN curl -LJO https://raw.githubusercontent.com/postgresml/postgresml/master/pgml-extension/requirements.txt
RUN pip3 install --upgrade --force-reinstall setuptools wheel
ENV export SETUPTOOLS_USE_DISTUTILS stdlib
RUN pip3 install -r requirements.txt

RUN echo "deb [trusted=yes] https://apt.postgresml.org $(lsb_release -cs) main" | tee -a /etc/apt/sources.list
RUN apt-get update && apt-get install -y postgresql-pgml-${PG_VERSION}
# fixme - probably don't need
RUN apt install timescaledb-toolkit-postgresql-${PG_VERSION}

# Back to postgres user
USER postgres

# PostgresML requires shared_preload_libraries updated
COPY config/postgresql.conf /etc/postgresql.conf
COPY config/pgml.control /usr/share/postgresql/12/extension/pgml.control
# Remaining set-up steps once running:
# CREATE EXTENSION age;
# SET search_path = ag_catalog, "$user", public;

# Users will require the following permissions:
# - GRANT USAGE ON SCHEMA ag_catalog TO db_user;
# Additionally, every connection which requires age will need to run "LOAD 'age';"

# ref: https://age.apache.org/age-manual/master/intro/setup.html
