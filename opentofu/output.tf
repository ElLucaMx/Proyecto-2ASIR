output "ips_servidores" {
  description = "Direcciones IP de los servidores separadas por redes"

  value = {
    maria-dhcp = {
      web = libvirt_domain.ServidorWeb.network_interface[0].addresses[0]
    }

    br0 = {
      web = libvirt_domain.ServidorWeb.network_interface[1].addresses[0]
    }

    soto-solitario = {
      web             = "10.0.0.1"
      bd              = "10.0.0.2"
      almacenamiento  = "10.0.0.3"
    }
  }
}
