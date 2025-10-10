resource "yandex_compute_snapshot_schedule" "daily_backup" {
  name                = "daily-backup"
  retention_period    = "168h"
  schedule_policy {
    expression = "0 3 * * *"
  }

  snapshot_spec {
    description = "Автоматический бэкап диска"
  }

  disk_ids = [
    "fhm3icfpjibqopcgocjn", # bastion
    "fhmor2n9bgs5cpbmh15o", # zabbix
    "fhmm98257hmuiajjq7vj", # kibana
    "epd8jhehlt1eh55cra0m", # elasticsearch
    "epdl6v5glrpedag7v38i", # web-1
    "epdf6v7jmlp6h0elu72o", # web-2
  ]
}