variable "folder_id" {
  type        = string
  description = "Identifier of folder in Yandex Cloud"
}

variable "api_name" {
  type        = string
  description = "Name of API"
}

variable "database_name" {
  type        = string
  description = "Name of Database"
}

variable "service_account_name" {
  type        = string
  description = "Name of Service Account"
}

variable "region" {
  type        = string
  description = "Region in Yandex Cloud"
}

variable "database_connector_bucket" {
  type        = string
  description = "Bucket name with the apigw-dynamodb-connector zip archive"
}

variable "database_connector_object" {
  type        = string
  description = "Object name of the apigw-dynamodb-connector zip archive"
}

variable "openapi_spec" {
  type        = string
  description = "Path to OpenAPI specification for API Gateway"
}

variable "table_specs" {
  type        = set(string)
  description = "Paths to DynamoDB-compatible table specifications"
}
