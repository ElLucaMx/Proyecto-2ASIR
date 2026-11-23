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

# ISO cloud-init de Debian Web
resource "libvirt_cloudinit_disk" "ServidorWeb-cloudinit" {
  name           = "ServidorWeb-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/ServidorWeb-data.yaml")
  network_config = file("${path.module}/cloud-init/ServidorWeb-net.yaml")
}

# Asignar recursos
resource "libvirt_domain" "ServidorWeb" {
  name   = "ServidorWeb"
  memory = var.memory_web
  vcpu   = 2

  # Red maria-dhcp (NAT)
  network_interface {
    network_id     = libvirt_network.maria-dhcp.id
    mac            = "52:54:00:b6:d0:a1"
    wait_for_lease = true
  }

  # Red br0 (acceso a la red física)
  network_interface {
    bridge = "br0"
    mac    = "52:54:00:03:65:5e"
  }

  # Red soto-solitario (red aislada)
  network_interface {
    network_id = libvirt_network.soto-solitario.id
    mac        = "52:54:00:36:a7:ea"
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
resource "libvirt_volume" "ServidorDb-disk" {
  name             = "ServidorDb.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_ubuntu
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

# ISO cloud-init de ubuntu
resource "libvirt_cloudinit_disk" "ServidorDb-cloudinit" {
  name           = "ServidorDb-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/ServidorDb-data.yaml")
  network_config = file("${path.module}/cloud-init/ServidorDb-net.yaml")
}

# Asignar recursos
resource "libvirt_domain" "ServidorDb" {
  name   = "ServidorDb"
  memory = var.memory_db
  vcpu   = 2

  # Red soto-solitario
  network_interface {
    network_id = libvirt_network.soto-solitario.id
  }

  # Discos
  disk { volume_id = libvirt_volume.ServidorDb-disk.id }
  cloudinit = libvirt_cloudinit_disk.ServidorDb-cloudinit.id

  # Consola serie
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

##############################################
# Servidor Backup — Debian
##############################################

# Clon de la imagen Debian 13
resource "libvirt_volume" "ServidorAlmacenamiento-disk" {
  name             = "ServidorAlmacenamiento.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

# ISO cloud-init de Debian Almacenamiento
resource "libvirt_cloudinit_disk" "ServidorAlmacenamiento-cloudinit" {
  name           = "ServidorAlmacenamiento-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/ServidorAlmacenamiento-data.yaml")
  network_config = file("${path.module}/cloud-init/ServidorAlmacenamiento-net.yaml")
}

# Asignar recursos
resource "libvirt_domain" "ServidorAlmacenamiento" {
  name   = "ServidorAlmacenamiento"
  memory = var.memory_almacenamiento
  vcpu   = 2

  # Red soto-solitario
  network_interface {
    network_id = libvirt_network.soto-solitario.id
  }

  # Discos
  disk { volume_id = libvirt_volume.ServidorAlmacenamiento-disk.id }
  cloudinit = libvirt_cloudinit_disk.ServidorAlmacenamiento-cloudinit.id

  # Consola serie
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
