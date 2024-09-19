data "archive_file" "python-lambda-package" {  
  type = "zip"  
  source_file = "../src/lambda_authorizer.py" 
  output_path = "authorizer.zip"
}

resource "aws_lambda_function" "lambda-authorizer" {
    function_name       = "Authorizer"
    filename            = "authorizer.zip"
    source_code_hash    = data.archive_file.python-lambda-package.output_base64sha256
    role                = var.networking.fiap_role
    runtime             = "python3.9"
    handler             = "lambda_authorizer.lambda_handler"
    timeout             = 10

    environment {
      variables = {
        fastfood_aws_access_key_id = var.fastfood_aws_access_key_id
        fastfood_aws_secret_access_key = var.fastfood_aws_secret_access_key
      }
   }
}