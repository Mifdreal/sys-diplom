data "yandex_compute_image" "kibana" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.kibana.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
