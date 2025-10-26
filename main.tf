resource "aws_iam_role" "lambda_role" {
    name                    = "lambda-role"
    assume_role_policy      = jsonencode({
        Version             = "2012-10-17"
        Statement           = [{
            Action          = "sts:AssumeRole"
            Principal       = { 
                Service     = "lambda.amazonaws.com" 
            }
            Effect          = "Allow"
            Sid             = ""
        }]
    })
}

resource "aws_lambda_function" "lambda_test" {
    function_name           = "lambda-test"
    handler                 = "lambda_function.handler"
    runtime                 = "python3.11"
    role                    = aws_iam_role.lambda_role.arn
    filename                = "function.zip"
}