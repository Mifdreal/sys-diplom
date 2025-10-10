data "yandex_compute_image" "zabbix" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.zabbix.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      # Добавляем официальный репозиторий Zabbix
      "wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb",
      "sudo dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb",
      "sudo apt-get update",
      # Устанавливаем сервер, агент и веб-фронтенд
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent",
      # Настройка базы данных Zabbix
      "sudo systemctl start mysql",
      "sudo mysql -e \"CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;\"",
      "sudo mysql -e \"CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix_password';\"",
      "sudo mysql -e \"GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'; FLUSH PRIVILEGES;\"",
      "sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pzabbix_password zabbix",
      # Включаем и запускаем сервисы
      "sudo systemctl enable zabbix-server zabbix-agent apache2",
      "sudo systemctl start zabbix-server zabbix-agent apache2"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface[0].nat_ip_address
      private_key = file("~/.ssh/id_ed25519")
    }
  }

}
