## Deploying the sat-api-pg to an AWS stack.

### Prerequisites
* [aws-cli](https://aws.amazon.com/cli/)
* [psql](https://www.postgresql.org/docs/9.5/libpq.html)

Create an [ECR repository](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html) to house your OpenResty image (the image will be pushed to this repository as part of the `deploy.sh` step below.

Copy the `/deployment/.sample_env` to `/deployment/.env`. And update accordingly with the values relevant for your project. 

Then...

To create the stack of required AWS resources. Run
```bash
$ cd deployment
$ ./createStack.sh
```

Once your AWS stack has been created you can deploy the database creation/migrations and the updated OpenResty image.
This will create the `sat-api-pg` schemas, users, tables, views and functions in your stack's RDS database.
Prior to deploying these changes you must update the RDS instance's security policy to allow inbound traffic from the IP address of the machine where you are executing the deployment.
This will allow the deployment package to run `psql` commands from your IP address.

To build the deployment cofiguration file from you environment settings. From the `/deployment` directory run
```bash
$ ./createSubZeroConfig.sh
```

To deploy the database migrations and the push the latest OpenResty image to ECR run
```bash
$ ./deploy.sh
```

And finally now that our database is ready and the updated image is in ECR you can bring up an instance of your service by running
```bash
$ ./createStack.sh 1
```
(The 1 indicates a single instance of your service).

To create a new Sqitch migration run 
```bash
$ yarn subzero migrations add --no-diff --note "yournote" yourmigrationname
```
This will create the appropriate files in the `migrations` directory which you
can then modify with your desired changes.
