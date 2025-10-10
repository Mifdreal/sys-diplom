resource "yandex_alb_target_group" "web" {
  name = "web-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.private.id
    ip_address = yandex_compute_instance.web[0].network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private.id
    ip_address = yandex_compute_instance.web[1].network_interface[0].ip_address
  }
}
