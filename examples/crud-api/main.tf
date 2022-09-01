locals {
  cloud_id    = "<cloud_id>"
  folder_id   = "<folder_id>"
  oauth_token = "<oauth_token>"
  zone        = "ru-central1-a"
}

module "crud-api" {
  source = "../.."

  folder_id                 = local.folder_id
  api_name                  = "movies-api"
  database_name             = "movies-db"
  service_account_name      = "movies-api-service-account"
  region                    = "ru-central1"
  openapi_spec              = "api.yaml"
  table_specs               = ["file://table.json"]
  database_connector_bucket = "apigw-dynamodb-connector"
  database_connector_object = "apigw-dynamodb-connector-0.0.1.zip"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    null   = {
      source = "registry.terraform.io/hashicorp/null"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = local.oauth_token
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
  zone      = local.zone
}

output "crud_api_domain" {
  value = module.crud-api.api_gateway_domain
}
