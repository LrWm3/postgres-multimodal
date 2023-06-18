# postgres-multimodal

This repository contains a simple multi-modal example of PostgreSQL, showcasing various extensions and functionalities. 

It includes an example Liquibase changelog file to demonstrate how to configure Liquibase to manage database migrations using sql files found in a local directory.

The multi-modal image is based off of timescaledbs' wonderful timescaledb-ha image [dockerhub](https://hub.docker.com/r/timescale/timescaledb-ha), [github](https://github.com/timescale/timescaledb-docker-ha/), which contains all of the extensions except for apache age, and is compatible with the [timescaledb high-availability helm chart](https://github.com/timescale/helm-charts/blob/main/charts/timescaledb-single/README.md).

## Contents

- [docker-compose.yaml](./docker-compose.yaml): The Docker Compose configuration file that sets up the PostgreSQL container and runs the Liquibase container to migrate.
- [Dockerfile](./Dockerfile): The Dockerfile used to build the PostgreSQL container. It installs Apache Age and sets up the necessary configurations to allow non super users to interact with it.
- [migrations/root.changelog.xml](./migrations/root.changelog.xml): The Liquibase changelog file that includes SQL scripts for database migrations.
- [migrations/sql/00010_initial_database_setup.sql](./migrations/sql/00010_initial_database_setup.sql): SQL script for initializing the database with various extensions and configurations.
- [README.md](./README.md): This readme file providing an overview of the repository.

## Usage

To play with 'postgres-multimodal' locally, follow these steps:

1. Make sure you have Docker installed on your system.
2. Clone this repository: `git clone https://github.com/your-username/postgres-multimodal.git`.
3. Navigate to the cloned directory: `cd postgres-multimodal`.
4. Start the Docker containers: `docker-compose up -d`.
5. Wait for the containers to build and be up and running. PostgreSQL will be available on port 5432.
6. Connect to the PostgreSQL database using your preferred client or command-line tool.
   - Host: localhost
   - Port: 5432
   - Database: postgres
   - Username: postgres
   - Password: password

Once connected, you can interact with the database and explore the various extensions and functionalities provided by this multi-modal example.

## Features

The PostgreSQL image built in this example includes the following extensions to enable multi-modal behavior:

- [postgis](https://postgis.net): Enables geospatial capabilities.
- [timescaledb](https://www.timescale.com/): Provides support for time-series data.
- [pgvector](https://github.com/pgvector/pgvector): Supports vector-based operations used for similarity and semantic search.
- [apache age](https://age.apache.org/): Enables graph and Cypher functionality used to enable graph database functionality found in database like Neo4j.
- [hll](https://github.com/citusdata/postgresql-hll): Enables the HyperLogLog extension, used to efficiently count large amounts of distinct values.

Several other minor extensions are also enabled by default.

- "uuid-ossp": Allows generating UUIDs.
- pg_trgm: Offers trigram-based similarity matching.
- pgcrypto: Provides cryptographic functions.

Liquibase is used to run the database migrations specified in the `root.changelog.xml` file against the PostgreSQL container. The `migrations/sql/00010_initial_database_setup.sql` file contains SQL statements for initializing the database with extensions and configurations. Additional migration files may be added to the `migrations/sql` directory to extend the behavior.

### Apache AGE

To leverage the graph features of Apache AGE, the following two commands must be run per session.

```
-- Required
LOAD 'age';

-- Optional, but recommended
SET search_path = ag_catalog, "$user", public;
```

For more information on Apache AGE, see the official [Apache Age Documentation](https://age.apache.org/age-manual/master/intro/setup.html).

## Contributing

Contributions to this repository are welcome. If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This repository is licensed under the [Apache 2.0 License](./LICENSE).
