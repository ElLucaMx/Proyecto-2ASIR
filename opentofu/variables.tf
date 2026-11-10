# Pool donde se van a almacenar los discos creados
variable "libvirt_pool_name" {
  type        = string
  description = "Nombre del pool default."
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

# Imagen base Alpine para ServidorAlmacenamiento
variable "base_image_alpine" {
  type        = string
  description = "Nombre de la imagen base Alpine en el pool."
  default     = "alpine-base.qcow2"
}

# Memoria RAM servidor ServidorWeb
variable "memory_web" {
  type        = number
  description = "Memoria RAM del servidor web."
  default     = 1024
}

# Memoria RAM ServidorBaseDatos
variable "memory_db" {
  type        = number
  description = "Memoria RAM del servidor de base de datos."
  default     = 1024
}

# Memoria RAM ServidorAlmacenamiento
variable "memory_almacenamiento" {
  type        = number
  description = "Memoria RAM del servidor de almacenamiento."
  default     = 1024
}
