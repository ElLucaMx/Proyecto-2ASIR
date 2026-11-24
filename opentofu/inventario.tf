# Genera el inventario de Ansible (fichero "hosts") a partir de las IP del escenario
resource "local_file" "inventario" {
  filename        = "${path.module}/../ansible/hosts"
  file_permission = "0644"
  content = templatefile("${path.module}/inventario.tftpl", {
    ip_web            = try(libvirt_domain.ServidorWeb.network_interface[0].addresses[0], "")
    ip_db             = "10.0.0.2"
    ip_almacenamiento = "10.0.0.3"
  })
}
