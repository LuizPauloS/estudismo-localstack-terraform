## Premissas

1. Docker Instalado
2. Terraform Instalado
3. Python Instalado (obs: usado para testar o código da lambda)
4. AWS CLI Instalado e devidamente configurado

## Executar Ambiente

1. Inicie o LocalStack:

```
   docker run --rm -it -p 4566:4566 localstack/localstack
```

2. Incie o Terraform:

```
   terraform init
```

Resultado:

```
    Initializing the backend...
    Initializing provider plugins...
    - Reusing previous version of hashicorp/aws from the dependency lock file
    - Using previously-installed hashicorp/aws v5.100.0

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
```

3. Valide o código Terraform

```
    terraform validate
```

Resultado:

```
    Success! The configuration is valid.
```

4. Aplicar Terraform (Criar recursos)

```
   terraform apply -auto-approve
```

Resultado:

```
    Terraform detected the following changes made outside of Terraform since the last "terraform apply" which may have affected this plan:

    # aws_iam_role.lambda_role has been deleted
    - resource "aws_iam_role" "lambda_role" {
        - arn                   = "arn:aws:iam::000000000000:role/lambda-role" -> null
            id                    = "lambda-role"
            name                  = "lambda-role"
            # (11 unchanged attributes hidden)
        }


    Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the following plan may include actions to undo or respond to these changes.

    ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # aws_iam_role.lambda_role will be created
    + resource "aws_iam_role" "lambda_role" {
        + arn                   = (known after apply)
        + assume_role_policy    = jsonencode(
                {
                + Statement = [
                    + {
                        + Action    = "sts:AssumeRole"
                        + Effect    = "Allow"
                        + Principal = {
                            + Service = "lambda.amazonaws.com"
                            }
                        + Sid       = ""
                        },
                    ]
                + Version   = "2012-10-17"
                }
            )
        + create_date           = (known after apply)
        + force_detach_policies = false
        + id                    = (known after apply)
        + managed_policy_arns   = (known after apply)
        + max_session_duration  = 3600
        + name                  = "lambda-role"
        + name_prefix           = (known after apply)
        + path                  = "/"
        + tags_all              = (known after apply)
        + unique_id             = (known after apply)

        + inline_policy (known after apply)
        }

    # aws_lambda_function.lambda_test will be created
    + resource "aws_lambda_function" "lambda_test" {
        + architectures                  = (known after apply)
        + arn                            = (known after apply)
        + code_sha256                    = (known after apply)
        + filename                       = "function.zip"
        + function_name                  = "lambda-test"
        + handler                        = "lambda_function.handler"
        + id                             = (known after apply)
        + invoke_arn                     = (known after apply)
        + last_modified                  = (known after apply)
        + memory_size                    = 128
        + package_type                   = "Zip"
        + publish                        = false
        + qualified_arn                  = (known after apply)
        + qualified_invoke_arn           = (known after apply)
        + reserved_concurrent_executions = -1
        + role                           = (known after apply)
        + runtime                        = "python3.11"
        + signing_job_arn                = (known after apply)
        + signing_profile_version_arn    = (known after apply)
        + skip_destroy                   = false
        + source_code_hash               = (known after apply)
        + source_code_size               = (known after apply)
        + tags_all                       = (known after apply)
        + timeout                        = 3
        + version                        = (known after apply)

        + ephemeral_storage (known after apply)

        + logging_config (known after apply)

        + tracing_config (known after apply)
        }

    Plan: 2 to add, 0 to change, 0 to destroy.
    aws_iam_role.lambda_role: Creating...
    aws_iam_role.lambda_role: Creation complete after 0s [id=lambda-role]
    aws_lambda_function.lambda_test: Creating...
    aws_lambda_function.lambda_test: Creation complete after 6s [id=lambda-test]

    Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

5. Listar Lambdas Criadas

```
    aws lambda list-functions \
        --endpoint-url http://localhost:4566 \
        --profile <PROFILE_NAME>
```

Resultado:

```
{
    "Functions": [
        {
            "FunctionName": "lambda-test",
            "FunctionArn": "arn:aws:lambda:sa-east-1:000000000000:function:lambda-test",
            "Runtime": "python3.11",
            "Role": "arn:aws:iam::000000000000:role/lambda-role",
            "Handler": "lambda_function.handler",
            "CodeSize": 279,
            "Description": "",
            "Timeout": 3,
            "MemorySize": 128,
            "LastModified": "2025-10-26T21:07:34.459549+0000",
            "CodeSha256": "eWq3HvxYs6/94lqv5XJ93vuJ/N8Wi/3IRQUb6QsRYfI=",
            "Version": "$LATEST",
            "TracingConfig": {
                "Mode": "PassThrough"
            },
            "RevisionId": "64224d6d-76d8-4169-8419-ab06554c8c20",
            "PackageType": "Zip",
            "Architectures": [
                "x86_64"
            ],
            ...
        }
    ]
}
```

6. Invocar Lambda

```
    aws lambda invoke \
        --function-name lambda-test \
        --endpoint-url http://localhost:4566 \
        --profile <PROFILE_NAME> \
        lambda-test-output.json
```

Resultado:

```
    {
        "StatusCode": 200,
        "ExecutedVersion": "$LATEST"
    }   
```

O arquivo de nome ***lambda-test-output.json*** deve ser criado na raiz do projeto com o seguinte json:

```
    {"statusCode": 200, "body": "Hello from Lambda!"}
```    