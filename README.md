# sat-api-pg

## A Postgres backed STAC API.

[sat-api-pg OpenAPI Docs](http://devseed.com/sat-api-pg-swagger/)

Built on the foundation of the excellent

[PostgREST](https://postgrest.com) - Postgres REST API backends.

[PostgREST Starter Kit](https://github.com/subzerocloud/postgrest-starter-kit) - Starter Kit and tooling for authoring REST API backends with PostgREST.

## Purpose

To provide the community a Postgres backed reference implementation of the [STAC API specification](https://github.com/radiantearth/stac-spec/tree/dev/api-spec).
Postgres's flexibility and ecosystem of geospatial functionality provide a great
foundation for building spatial APIs and we hope the community can expand on this work to drive STAC development forward.

## Project Layout

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
* [Yarn](https://yarnpkg.com/lang/en/)

In the root folder of the application, install the necessary js libs.
```bash
$ yarn
```

The root folder of the application contains `.sample_env` with development environment settings.  Rename this file by running
```bash
$ cp .sample_env .env
```

In the root folder of application, run the docker-compose command
```bash
$ docker-compose up -d
```

The API server will become available at the following endpoint:

- REST [http://localhost:8080](http://localhost:8080)

Try a simple request
```bash
$ curl http://localhost:8080/collections/landsat-8-l1/items
```

To remove the docker compose stack run
```bash
$ docker-compose stop
```
Followed by
```bash
$ docker-compose rm
```

## Development workflow and debugging

In the root of your project run.
```bash
$ yarn subzero dashboard
```
After this step you can view the logs of all the stack components (SQL queries will also be logged) and
if you edit a sql / conf / lua file in your project, the changes will immediately be applied.


## Testing
Conformance with the [STAC API specification](https://github.com/radiantearth/stac-spec/tree/dev/api-spec) and extensions can be understood by reviewing the integration tests available at `/tests/rest`.
To run tests, the `docker-compose` stack must be running.

```bash
yarn test                   # Run all tests (db, rest)
yarn test_db                # Run pgTAP tests
yarn test_rest               # Run integration tests
```

## Deployment
For AWS deployment steps see [deployment/README.md](deployment/README.md).

## Contributing
This project was initiated as part of [Development Seed's](https://developmentseed.org/) wider work in helping to build the [STAC API specification](https://github.com/radiantearth/stac-spec/tree/dev/api-spec)
and open sourced to to the community to help drive contributions and new functionality.  New contributions are welcomed and you can contact
[@sharkinsspatial](https://github.com/sharkinsspatial) or info@developmentseed.org for additional support or assistance with customization.
Anyone and everyone is welcome to contribute.

## STAC alignment
This API implementation closely follows the [STAC API specification](https://github.com/radiantearth/stac-spec/tree/dev/api-spec).  Becase the STAC API specifcation is under active development there are some current differences between the STAC specification [v0.8.0](https://github.com/radiantearth/stac-spec/releases/tag/v0.8.0).  For more details on capabilities see [sat-api-pg OpenAPI Docs](http://devseed.com/sat-api-pg-swagger/).
Notable differences

 - Though the [search extension](https://github.com/radiantearth/stac-spec/tree/master/api-spec/extensions/search) is not currently implemented much of the same behavior can be acheived via the use of http headers.  When using the `next` and `limit` parameters, responses will contain a `Content-Range` header which shows the current range of the response.  To obtain the total number of items found the request can specify the `Prefer: count=exact` header and the full count will be available in the `Content-Range` response header.  Be aware that this exact count can be slow for very large tables.  For increased performance we will soon release support for the `Prefer: count=planned` header to provide an estimated count.  Note that the accuracy of this count depends on how up-to-date are the PostgreSQL statistics tables.

 - The API contains a generic `/items` endpoint which supports access to items across parent collections.  The rationale for this is tied to the insert extension described below.

 - The [transaction](https://github.com/radiantearth/stac-spec/tree/master/api-spec/extensions/transaction) is not currently implemented but insert behavior using http POST is enabled for `items` and `collections`.  Authentication for insert operations is handled via the `Authorization` header with JWT tokens.  To make an authenticated request the client must include an Authorization HTTP header with the value `Bearer <jwt>`. Tokens can be generated using the `JWT_SECRET` from the `.env` file by running
 
 ```bash
 $ node generateToken.js 
 ```

  Due to permissions on the base table where records are stored insert requests must also set the header `Prefer: return=minimal`.
