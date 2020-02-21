# Sir Wednesday

AWS Lambda function that posts the royal wednesday frog every wednesday. Written in Go, deployed by Terraform.

To deploy:

```
$ aws configure
$ make
```

You will need AWS access keys, a URL for an incoming webhook for Slack and an AWS region where you'd like to deploy this.

Depending on your timezone, you may want to adapt the cron schedule for the Lambda function.

![It may be Wednesday, my dudes!](./frog.png)