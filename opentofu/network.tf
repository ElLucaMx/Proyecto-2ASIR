# Red DHCP maria
resource "libvirt_network" "maria-dhcp" {
  name      = "maria-dhcp"
  mode      = "nat"
  domain    = "example.com"
  addresses = ["172.19.1.0/24"]
  dhcp { enabled = true }
  dns { enabled = true }
  autostart = true
}


# Red soto solitario
resource "libvirt_network" "soto-solitario" {
  name      = "soto-solitario"
  mode      = "none"
  autostart = true
}
