# VPC
resource "yandex_vpc_network" "main" {
  name        = "diplom-network"
  description = "Network for diploma project"
}

# Публичная подсеть (для bastion, zabbix, kibana, ALB)
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# Приватная подсеть (для web, elasticsearch) с NAT
resource "yandex_vpc_subnet" "private" {
  name           = "private-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

# Таблица маршрутизации для приватной подсети
resource "yandex_vpc_route_table" "private_rt" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

# NAT Gateway
resource "yandex_vpc_gateway" "nat" {
  name = "nat-gateway"
  shared_egress_gateway {}
}