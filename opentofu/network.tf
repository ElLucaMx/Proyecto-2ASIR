# Red soto solitario
resource "libvirt_network" "soto-solitario" {
  name      = "soto-solitario"
  mode      = "none"
  autostart = true
}
