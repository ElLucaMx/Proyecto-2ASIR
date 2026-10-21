##############################################
# Servidor Web — Debian
##############################################

# Clon de la imagen debian

# ISO cloud-init de debian

  # Red default

  # Red soto-solitario

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
