resource "yandex_iam_service_account" "service_account" {
  name        = var.service_account_name
  description = "Service account for working with ${var.database_name}"
}

resource "yandex_resourcemanager_folder_iam_binding" "service_account_ydb_editor_binding" {
  folder_id = var.folder_id
  members   = ["serviceAccount:${yandex_iam_service_account.service_account.id}"]
  role      = "ydb.editor"
}

resource "yandex_resourcemanager_folder_iam_binding" "service_account_functions_invoker_binding" {
  folder_id = var.folder_id
  members   = ["serviceAccount:${yandex_iam_service_account.service_account.id}"]
  role      = "serverless.functions.invoker"
}

resource "yandex_iam_service_account_static_access_key" "service_account_static_key" {
  service_account_id = yandex_iam_service_account.service_account.id
}

resource "yandex_ydb_database_serverless" "database" {
  name        = var.database_name
  folder_id   = var.folder_id
  description = "Yandex Database for storing data in ${var.api_name}"
}

resource "null_resource" "database_table" {
  for_each = var.table_specs
  provisioner "local-exec" {
    command = <<-EOF
export AWS_ACCESS_KEY_ID=${yandex_iam_service_account_static_access_key.service_account_static_key.access_key}
export AWS_SECRET_ACCESS_KEY=${yandex_iam_service_account_static_access_key.service_account_static_key.secret_key}
export AWS_DEFAULT_REGION=${var.region}
aws dynamodb create-table --cli-input-json ${each.key} --endpoint ${yandex_ydb_database_serverless.database.document_api_endpoint}
EOF
  }
}

resource "yandex_function" "database_connector" {
  name               = "apigw-dynamodb-connector"
  user_hash          = uuid()
  folder_id          = var.folder_id
  description        = "Function for integration API Gateway with Yandex Database throw DynamoDB API"
  runtime            = "nodejs16-preview"
  entrypoint         = "apigw-dynamodb-connector.handler"
  memory             = 128
  execution_timeout  = 300
  package {
    bucket_name = var.database_connector_bucket
    object_name = var.database_connector_object
  }
  service_account_id = yandex_iam_service_account.service_account.id
  environment        = {
    AWS_ACCESS_KEY_ID     = "FAKE_AWS_ACCESS_KEY_ID"
    AWS_SECRET_ACCESS_KEY = "FAKE_AWS_SECRET_ACCESS_KEY"
    REGION                = var.region
  }
}

data "template_file" "openapi_spec" {
  template = file(var.openapi_spec)
  vars     = {
    FUNCTION_ID        = yandex_function.database_connector.id
    DATABASE_ENDPOINT  = yandex_ydb_database_serverless.database.document_api_endpoint
    SERVICE_ACCOUNT_ID = yandex_iam_service_account.service_account.id
  }
}

resource "yandex_api_gateway" "api_gateway" {
  name        = var.api_name
  folder_id   = var.folder_id
  spec        = data.template_file.openapi_spec.rendered
  description = "API Gateway of the ${var.api_name}"
}
