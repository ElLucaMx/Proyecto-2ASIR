output "ips_servidores" {
  description = "Direcciones IP de los servidores"

  value = {
    web            = libvirt_domain.ServidorWeb.network_interface[0].addresses[0]
    web_br0        = try(libvirt_domain.ServidorWeb.network_interface[1].addresses[0], "No detectada")
    bd             = libvirt_domain.ServidorDb.network_interface[0].addresses[0]
    almacenamiento = libvirt_domain.ServidorAlmacenamiento.network_interface[0].addresses[0]
  }
}
