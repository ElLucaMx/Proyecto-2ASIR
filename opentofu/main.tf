##############################################
# Servidor Web — Debian
##############################################

# Clon de la imagen debian
resource "libvirt_volume" "ServidorWeb-disk" {
  name             = "ServidorWeb.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

# ISO cloud-init de debian
resource "libvirt_cloudinit_disk" "ServidorWeb-cloudinit" {
  name           = "ServidorWeb-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/ServidorWeb-data.yaml")
  network_config = file("${path.module}/cloud-init/ServidorWeb-net.yaml")
}

# Asignar recursos
resource "libvirt_domain" "ServidorWeb" {
  name   = "ej5-server1"
  memory = 1024
  vcpu   = 2

  # Red maria-dhcp
  network_interface {
    network_id     = libvirt_network.maria-dhcp.id
    wait_for_lease = true
  }

  # Red soto-solitario
  network_interface {
    network_id = libvirt_network.ServidorWeb.id
  }

  # Discos
  disk { volume_id = libvirt_volume.ServidorWeb-disk.id }
  cloudinit = libvirt_cloudinit_disk.ServidorWeb-cloudinit.id

  # Consola serie
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

##############################################
# Servidor Base de Datos — Ubuntu
##############################################

# Clon de la imagen ubuntu

# ISO cloud-init de ubuntu

  # Red default

  # Red soto-solitario

  # Consola serie
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
