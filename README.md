# sat-api-pg

A Postgres backed STAC API.

Built with the help of the excellent
[PostgREST](https://postgrest.com) - Postgres REST API backends.
[PostgREST Starter Kit](https://github.com/subzerocloud/postgrest-starter-kit) - Starter Kit and tooling for authoring REST API backends with PostgREST.

## Purpose

Provide a Postgres backed reference implementation of the STAC API specification.


```bash
.
├── db                        # Database schema source files and tests
│   └── src                   # Schema definition
│       ├── api               # Api entities avaiable as REST endpoints
│       ├── data              # Definition of source tables that hold the data
│       ├── libs              # A collection modules of used throughout the code
│       ├── authorization     # Application level roles and their privileges
│       ├── sample_data       # A few sample rows
│       └── init.sql          # Schema definition entry point
├── openresty                 # Reverse proxy configurations and Lua code
│   ├── lualib
│   │   └── user_code         # Application Lua code
│   ├── nginx                 # Nginx files
│   │   ├── conf              # Configuration files
│   │   └── html              # Static frontend files
│   ├── Dockerfile            # Dockerfile definition for production
│   └── entrypoint.sh         # Custom entrypoint
├── tests                     # Tests for all the components
│   ├── db                    # pgTap tests for the db
│   └── rest                  # REST interface tests
├── docker-compose.yml        # Defines Docker services, networks and volumes
└── .env                      # Project configurations

```

## Installation 

### Prerequisites
* [Docker](https://www.docker.com)
* [Node.js](https://nodejs.org/en/)

```bash
$ yarn
```

In the root folder of application, run the docker-compose command

```bash
$ docker-compose up -d
```

The API server will become available at the following endpoint:

- REST [http://localhost:8080/rest/](http://localhost:8080/rest/)

Try a simple request

```bash
curl http://localhost:8080/rest/todos?select=id,todo
```


## Development workflow and debugging

Execute `subzero dashboard` in the root of your project.<br />
After this step you can view the logs of all the stack components (SQL queries will also be logged) and
if you edit a sql/conf/lua file in your project, the changes will immediately be applied.


## Testing

The starter kit comes with a testing infrastructure setup.
You can write pgTAP tests that run directly in your database, useful for testing the logic that resides in your database (user privileges, Row Level Security, stored procedures).
Integration tests are written in JavaScript.

Here is how you run them

```bash
yarn test                   # Run all tests (db, rest)
yarn test_db                # Run pgTAP tests
yar test_rest               # Run integration tests
```

## Deployment
* [Amazon ECS+RDS](http://docs.subzero.cloud/production-infrastructure/aws-ecs-rds/)
* [Amazon Fargate+RDS](http://docs.subzero.cloud/production-infrastructure/aws-fargate-rds/)

## Contributing
This project was initiated as part of [Development Seed's](https://developmentseed.org/) wider work in building the stac-spec
and open sourced to to the community to help drive contributions and new functionality.  New contributions are welcomed and you can contact
[@sharkinsspatial](https://github.com/sharkinsspatial) or info@developmentseed.org for additional support or assistance with customization.
Anyone and everyone is welcome to contribute.

