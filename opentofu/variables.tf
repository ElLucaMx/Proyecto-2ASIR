# Pool donde se van a almacenar los discos creados
variable "libvirt_pool_name" {
  type        = string
  description = "Nombre del pool de almacenamiento libvirt."
  default     = "default"
}

# Imagen base Debian para ServidorWeb
variable "base_image_debian" {
  type        = string
  description = "Nombre de la imagen base Debian en el pool."
  default     = "debian13-base.qcow2"
}

# Imagen base Ubuntu para ServidorBaseDatos
variable "base_image_ubuntu" {
  type        = string
  description = "Nombre de la imagen base Ubuntu en el pool."
  default     = "ubuntu2604-base.qcow2"
}
