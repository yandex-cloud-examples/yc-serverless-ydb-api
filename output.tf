output "service_account_id" {
  value = yandex_iam_service_account.service_account.id
}

output "database_endpoint" {
  value = yandex_ydb_database_serverless.database.document_api_endpoint
}

output "database_path" {
  value = yandex_ydb_database_serverless.database.database_path
}

output "database_connector_id" {
  value = yandex_function.database_connector.id
}

output "api_gateway_domain" {
  value = "https://${yandex_api_gateway.api_gateway.domain}"
}
