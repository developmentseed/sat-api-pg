## Deploying the sat-api-pg to an AWS stack.

### Prerequisites

- [aws-cli](https://aws.amazon.com/cli/)
- [psql](https://www.postgresql.org/docs/9.5/libpq.html)

### Initial Deployment

1. Create an [ECR repository](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html) to house your OpenResty image. Example name: `sat-api-pg-dev/openresty`
2. Copy the `./deployment/.sample_env` to `./deployment/.env`. Update accordingly with the values relevant for your project.
3. Create the stack of required AWS resources:
   ```bash
   $ cd deployment
   $ ./createStack.sh
   ```
4. Update the newly created RDS instance's security policy to allow inbound traffic from the IP address of the machine where you are executing the deployment. This will allow the deployment package to run `psql` commands from your IP address.
5. Build the deployment configuration file from you environment settings. From the `/deployment` directory run:
   ```bash
   $ ./createSubZeroConfig.sh
   ```
6. Deploy the database migrations and the push the latest OpenResty image to ECR run. This will create the `sat-api-pg` schemas, users, tables, views and functions in your stack's RDS database.
   ```bash
   $ ./deploy.sh
   ```
7. Now that our database is ready and the updated image is in ECR, bring up an instance of your service:
   ```bash
   $ ./createStack.sh 1 # The 1 indicates a single instance of your service
   ```

### Migrations

To create a new Sqitch migration run

```bash
$ yarn subzero migrations add --no-diff --note "yournote" yourmigrationname
```

This will create the appropriate files in the `migrations` directory which you can then modify with your desired changes.
