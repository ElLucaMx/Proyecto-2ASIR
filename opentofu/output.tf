output "ips_servidores" {
  description = "Direcciones IP de las máquinas en la red NAT (maria-dhcp)"
  value = {
    web = libvirt_domain.ServidorWeb.network_interface[0].addresses[0]
    bd  = libvirt_domain.ServidorDb.network_interface[0].addresses[0]
  }
}
