data "yandex_compute_image" "ubuntu_web" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "web" {
  count       = 2
  name        = "web-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"  # приватная подсеть

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_web.id
      size     = 10
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    # без внешнего IP
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  # Provisioner для установки nginx и сайта
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface[0].ip_address
      private_key = file("~/.ssh/id_ed25519")
      bastion_host = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
      bastion_user = "ubuntu"
    }
  }

  depends_on = [
    yandex_compute_instance.bastion
  ]
}