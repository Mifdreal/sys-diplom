terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.162.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "yandex" {
  service_account_key_file = "${path.module}/key.json"
  cloud_id  = "b1glh9ha307rhar8b0hf"
  folder_id = "b1gu73oahgghafk0j1it"
  zone      = "ru-central1-a"
}