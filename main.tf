variable "webhookurl" {
  description = "Slack webhook url to post to."
  type = string
}

variable "imgurl" {
  description = "URL of the image you're posting (could be your GitHub repo)."
  type = string
  default = "https://raw.githubusercontent.com/pfandzelter/sir-wednesday/master/frog.png"
}

resource "aws_lambda_function" "sir-wednesday" {
  function_name    = "sir-wednesday"
  filename         = "frog.zip"
  handler          = "frog"
  source_code_hash = filebase64sha256("frog.zip")
  role             = aws_iam_role.sir-wednesday-role.arn
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 2

  environment {
    variables = {
      WEBHOOK_URL = var.webhookurl,
      IMG_URL = var.imgurl
    }
  }
}

resource "aws_iam_role" "sir-wednesday-role" {
  name               = "sir-wednesday"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow"
  }
}
POLICY
}

resource "aws_iam_role_policy_attachment" "basic-exec-role" {
  role       = aws_iam_role.sir-wednesday-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.sir-wednesday-role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# remember that we want to start this once every wednesday
resource "aws_cloudwatch_event_rule" "sir-wednesday-cron" {
  name                = "sir-wednesday-cron"
  schedule_expression = "cron(0 9 ? * WED *)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  target_id = "runLambda"
  rule      = aws_cloudwatch_event_rule.sir-wednesday-cron.name
  arn       = aws_lambda_function.sir-wednesday.arn
}

resource "aws_lambda_permission" "cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sir-wednesday.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sir-wednesday-cron.arn
}