resource "yandex_alb_backend_group" "web" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    target_group_ids = [yandex_alb_target_group.web.id]
    port             = 80

    healthcheck {
      timeout  = "5s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}
